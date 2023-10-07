// ignore_for_file: prefer_const_constructors

import 'package:app_test/Pages/Home.dart';
import 'package:app_test/Utils/Colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User-manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 213, 255)),
        useMaterial3: true,
        primaryColor: AppColors.primary),
      home: Home(),
    );
  }
}
