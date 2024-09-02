
import 'package:authentication/User.dart';
import 'package:authentication/pages/Login.dart';
import 'package:authentication/pages/SingUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget{
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState ();
}

class _AdminState extends State<Admin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(CupertinoIcons.back),
        color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("NFC",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.cyan.shade600,
      ),
      body: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40,),
          Container(
              alignment: Alignment.center,
              height: 150,
              child: Image.asset("assets/images/hamrah.png")
          ),
          Container(
            alignment: Alignment.center,
            height: 80,
            child: const Text("Hamrah Aval",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 100,),
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("SignUp",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(width: 10,),
                      Icon(Icons.app_registration,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}