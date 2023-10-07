import 'package:app_test/Utils/Colors.dart';
import 'package:flutter/material.dart';

ButtonStyle borderedButtonStyle = ButtonStyle(
  elevation: MaterialStateProperty.all(0),
  backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 165, 30, 170)),
  shape: MaterialStateProperty.all(RoundedRectangleBorder(
    side: BorderSide(color: AppColors.primary),
    borderRadius: BorderRadius.circular(10),
  ))
);
