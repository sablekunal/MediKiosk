import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/inactivity_timer.dart';
import 'features/demographics/presentation/screens/welcome_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MediKioskApp(),
    ),
  );
}

class MediKioskApp extends StatelessWidget {
  const MediKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800), // Standard tablet landscape resolution
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'MediKiosk',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, widget) {
            return InactivityWatchdog(
              timeout: const Duration(seconds: 90),
              onTimeout: () {
                // Reset navigation to Welcome Screen on timeout
                rootNavigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              // Wrap with PopScope to disable back button gestures for kiosk hardening
              child: PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  if (didPop) return;
                  // Handle custom back logic if needed, otherwise do nothing to lock navigation
                },
                child: widget!,
              ),
            );
          },
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
