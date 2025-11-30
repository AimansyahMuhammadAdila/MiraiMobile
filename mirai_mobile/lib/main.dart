import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mirai_mobile/providers/auth_provider.dart';
import 'package:mirai_mobile/providers/booking_provider.dart';
import 'package:mirai_mobile/providers/ticket_provider.dart';
import 'package:mirai_mobile/services/api_service.dart';
import 'package:mirai_mobile/services/storage_service.dart';
import 'package:mirai_mobile/utils/app_theme.dart';
import 'package:mirai_mobile/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService().init();
  ApiService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'MiraiMobile',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
