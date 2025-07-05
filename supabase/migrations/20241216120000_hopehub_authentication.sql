-- Location: supabase/migrations/20241216120000_hopehub_authentication.sql
-- HopeHub Missing Person Alert System - Authentication & Core Module

-- 1. Types and Core Tables
CREATE TYPE public.user_role AS ENUM ('admin', 'moderator', 'user');
CREATE TYPE public.report_status AS ENUM ('active', 'found', 'closed', 'investigating');
CREATE TYPE public.report_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- Critical intermediary table for auth relationships
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    role public.user_role DEFAULT 'user'::public.user_role,
    is_verified BOOLEAN DEFAULT false,
    avatar_url TEXT,
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Missing person reports table
CREATE TABLE public.missing_person_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    person_name TEXT NOT NULL,
    person_age INTEGER NOT NULL CHECK (person_age >= 0 AND person_age <= 150),
    last_seen_location TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    contact_phone TEXT,
    status public.report_status DEFAULT 'active'::public.report_status,
    priority public.report_priority DEFAULT 'medium'::public.report_priority,
    case_id TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Comments/updates on missing person reports
CREATE TABLE public.report_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID REFERENCES public.missing_person_reports(id) ON DELETE CASCADE,
    commenter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    is_official BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_missing_person_reports_reporter_id ON public.missing_person_reports(reporter_id);
CREATE INDEX idx_missing_person_reports_status ON public.missing_person_reports(status);
CREATE INDEX idx_missing_person_reports_created_at ON public.missing_person_reports(created_at DESC);
CREATE INDEX idx_missing_person_reports_case_id ON public.missing_person_reports(case_id);
CREATE INDEX idx_report_comments_report_id ON public.report_comments(report_id);
CREATE INDEX idx_report_comments_created_at ON public.report_comments(created_at DESC);

-- 3. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missing_person_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_comments ENABLE ROW LEVEL SECURITY;

-- 4. Safe Helper Functions
CREATE OR REPLACE FUNCTION public.is_profile_owner(profile_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = profile_uuid AND up.id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin_or_moderator()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role IN ('admin', 'moderator')
)
$$;

CREATE OR REPLACE FUNCTION public.is_report_owner(report_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.missing_person_reports mpr
    WHERE mpr.id = report_uuid AND mpr.reporter_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_report(report_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.missing_person_reports mpr
    WHERE mpr.id = report_uuid AND (
        mpr.status = 'active' OR 
        mpr.reporter_id = auth.uid() OR
        public.is_admin_or_moderator()
    )
)
$$;

-- Function to generate unique case ID
CREATE OR REPLACE FUNCTION public.generate_case_id()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    case_prefix TEXT := 'HH';
    case_year TEXT := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;
    case_number TEXT;
    new_case_id TEXT;
    counter INTEGER := 1;
BEGIN
    LOOP
        case_number := LPAD(counter::TEXT, 4, '0');
        new_case_id := case_prefix || case_year || case_number;
        
        -- Check if case ID already exists
        IF NOT EXISTS (
            SELECT 1 FROM public.missing_person_reports 
            WHERE case_id = new_case_id
        ) THEN
            RETURN new_case_id;
        END IF;
        
        counter := counter + 1;
        
        -- Safety check to prevent infinite loop
        IF counter > 9999 THEN
            RAISE EXCEPTION 'Unable to generate unique case ID for year %', case_year;
        END IF;
    END LOOP;
END;
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, phone_number, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'phone_number',
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role)
    );
    RETURN NEW;
END;
$$;

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Triggers for updating timestamps
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_missing_person_reports_updated_at
    BEFORE UPDATE ON public.missing_person_reports
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Trigger to auto-generate case ID
CREATE OR REPLACE FUNCTION public.set_case_id()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.case_id IS NULL OR NEW.case_id = '' THEN
        NEW.case_id := public.generate_case_id();
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER set_missing_person_case_id
    BEFORE INSERT ON public.missing_person_reports
    FOR EACH ROW EXECUTE FUNCTION public.set_case_id();

-- 5. RLS Policies
CREATE POLICY "users_own_profile"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_profile_owner(id))
WITH CHECK (public.is_profile_owner(id));

CREATE POLICY "public_read_active_reports"
ON public.missing_person_reports
FOR SELECT
TO public
USING (status = 'active');

CREATE POLICY "authenticated_read_all_accessible_reports"
ON public.missing_person_reports
FOR SELECT
TO authenticated
USING (public.can_access_report(id));

CREATE POLICY "users_manage_own_reports"
ON public.missing_person_reports
FOR ALL
TO authenticated
USING (public.is_report_owner(id))
WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "admins_manage_all_reports"
ON public.missing_person_reports
FOR ALL
TO authenticated
USING (public.is_admin_or_moderator())
WITH CHECK (public.is_admin_or_moderator());

CREATE POLICY "public_read_comments"
ON public.report_comments
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.missing_person_reports mpr
        WHERE mpr.id = report_id AND mpr.status = 'active'
    )
);

CREATE POLICY "authenticated_add_comments"
ON public.report_comments
FOR INSERT
TO authenticated
WITH CHECK (commenter_id = auth.uid());

CREATE POLICY "users_manage_own_comments"
ON public.report_comments
FOR ALL
TO authenticated
USING (commenter_id = auth.uid())
WITH CHECK (commenter_id = auth.uid());

-- 6. Complete Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user1_uuid UUID := gen_random_uuid();
    user2_uuid UUID := gen_random_uuid();
    report1_uuid UUID := gen_random_uuid();
    report2_uuid UUID := gen_random_uuid();
    report3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@hopehub.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Hope Hub Admin", "phone_number": "+1-555-0001", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'maria.johnson@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Maria Johnson", "phone_number": "+1-555-0123", "role": "user"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'david.chen@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "David Chen", "phone_number": "+1-555-0456", "role": "user"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create missing person reports
    INSERT INTO public.missing_person_reports (
        id, reporter_id, person_name, person_age, last_seen_location, description, 
        image_url, contact_phone, status, priority, case_id, created_at
    ) VALUES
        (report1_uuid, user1_uuid, 'Sarah Johnson', 8, 'Central Park, New York',
         'Last seen wearing a blue dress and white sneakers. Has brown hair in pigtails.',
         'https://images.pexels.com/photos/1462637/pexels-photo-1462637.jpeg?auto=compress&cs=tinysrgb&w=400',
         '+1-555-0123', 'active'::public.report_status, 'high'::public.report_priority, 
         'HH202400001', now() - interval '2 hours'),
        (report2_uuid, user2_uuid, 'Michael Chen', 12, 'Riverside Elementary School, California',
         'Wearing red backpack and black jacket. Has short black hair and glasses.',
         'https://images.pexels.com/photos/1674752/pexels-photo-1674752.jpeg?auto=compress&cs=tinysrgb&w=400',
         '+1-555-0456', 'active'::public.report_status, 'medium'::public.report_priority,
         'HH202400002', now() - interval '5 hours'),
        (report3_uuid, user1_uuid, 'Emma Rodriguez', 6, 'Sunset Mall, Texas',
         'Wearing pink t-shirt and denim shorts. Has long curly brown hair with a red hair band.',
         'https://images.pexels.com/photos/1416736/pexels-photo-1416736.jpeg?auto=compress&cs=tinysrgb&w=400',
         '+1-555-0789', 'found'::public.report_status, 'medium'::public.report_priority,
         'HH202400003', now() - interval '1 day');

    -- Create some comments
    INSERT INTO public.report_comments (report_id, commenter_id, comment_text, is_official, created_at) VALUES
        (report1_uuid, admin_uuid, 'Police have been notified. Case number: NYPD-2024-001', true, now() - interval '1 hour'),
        (report2_uuid, user1_uuid, 'I saw someone matching this description near the library', false, now() - interval '30 minutes');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 7. Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@example.com' OR email LIKE '%@hopehub.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.report_comments WHERE commenter_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.missing_person_reports WHERE reporter_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;