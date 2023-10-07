// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:app_test/Utils/Colors.dart';
import 'package:app_test/Utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: MobileNavBar(),
      desktop: DesktopNavBar(),
      );
  }

  // MOBILE //

  Widget MobileNavBar(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu),
          navLogo()
        ]),
    );
  }

  // DESKTOP //

  Widget DesktopNavBar(){
    return Container(
      color: Colors.blueGrey,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navLogo(),
          Row(
            children: [
              navButton('Jelszó módosítás'),
              navButton('Felhasználó készítés'),
              navButton('Hiba bejelentés'),
              navButton('Mittomen'),

            ],
          ),
          Container(
            height: 45,
            child: ElevatedButton(
              style: borderedButtonStyle,
              onPressed: (){},
              child: Text('Logout',
              style: TextStyle(color: AppColors.primary),),
            ),
          )
      ]),
    );
  }

  Widget navButton(String text){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black,
      child: TextButton(
        onPressed: (){}, child: Text(text, 
      style: TextStyle(
        color: Colors.white,
        fontSize: 18
      ),)),
    );
  }

  Widget navLogo(){
    return Container(
      width: 110,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/logo.png'))
      ),
    );
  }
}