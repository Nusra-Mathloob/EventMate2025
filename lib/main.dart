import 'package:event2025/features/profile/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart'; // DISABLED FOR DEVELOPMENT
import 'core/constants/app_colors.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/browse/views/browse_events_tab_screen.dart';
import 'features/events/views/my_events_screen.dart';
import 'features/favourites/views/favourites_screen.dart';
import 'features/favourites/controllers/favourites_controller.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase DISABLED for development - working on UI features
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize global controllers
  Get.put(FavouritesController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default, can be changed if GoogleFonts is used
      ),
      // Skip auth and go directly to home screen for development
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/browse', page: () => const BrowseEventsTabScreen()),
        GetPage(name: '/my-events', page: () => const EventListScreen()),
        GetPage(name: '/favourites', page: () => const FavouritesScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}
