// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:app_test/Pages/containers/container1.dart';
import 'package:app_test/Utils/constants.dart';
import 'package:app_test/Widgets/navbar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              NavBar(),
              Container1()
            ],
          ),

        )),
    );
  }
}
