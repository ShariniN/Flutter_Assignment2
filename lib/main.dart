import 'package:assignment1/screens/onboarding_screen.dart';
import 'package:assignment1/screens/login.dart';
import 'package:assignment1/services/api_service.dart';
import 'package:assignment1/services/cart_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment1/providers/connectivity_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider<CartManager>(
          create: (context) {
            final apiService = ApiService();
            final cartManager = CartManager(apiService);
            cartManager.loadCart().catchError((error) {
              print('Cart load failed: $error');
            });
            return cartManager;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Electronics Store',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.grey[100],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.grey[900],
        ),
        themeMode: ThemeMode.system,
        home: OnboardingScreen(),
        routes: {
          '/login': (context) => AuthScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
