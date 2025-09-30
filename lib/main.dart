import 'package:assignment1/screens/onboarding_screen.dart';
import 'package:assignment1/services/cart_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartManager(),
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
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}