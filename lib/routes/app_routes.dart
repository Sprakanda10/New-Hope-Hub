import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/create_post_screen/create_post_screen.dart';
import '../presentation/main_feed_screen/main_feed_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String createPostScreen = '/create-post-screen';
  static const String mainFeedScreen = '/main-feed-screen';
  static const String profileScreen = '/profile-screen';
  static const String registrationScreen = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    createPostScreen: (context) => const CreatePostScreen(),
    mainFeedScreen: (context) => const MainFeedScreen(),
    profileScreen: (context) => const ProfileScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    // TODO: Add your other routes here
  };
}
