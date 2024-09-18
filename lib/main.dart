import 'package:authentication/pages/AdminSignUp.dart';
import 'package:flutter/material.dart';
import 'package:authentication/pages/Login.dart';
import 'package:authentication/pages/SpecialCardSignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isAdminSet = await checkAdminStatus();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isAdminSet ? const Login() : const AdminSignUp(),
    ),
  );
}

Future<bool> checkAdminStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isAdminSet') ?? false;
}
