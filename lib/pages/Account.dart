
import 'package:authentication/User.dart';
import 'package:authentication/pages/Login.dart';
import 'package:authentication/pages/SingUp.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget{
  final User user;
  const Account({super.key,required this.user});

  @override
  State<Account> createState() => _AccountState (user: user);
}

class _AccountState extends State<Account> {
  _AccountState({required this.user});
  User user;
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.cyan.shade600,
      ),
    );
  }


}