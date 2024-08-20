
import 'package:authentication/pages/Login.dart';
import 'package:authentication/pages/SingUp.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      const MaterialApp(
          debugShowCheckedModeBanner:false,
          home: Login()
    )
  );
}
