import 'package:flutter/material.dart';
import 'register.dart';
import 'assist.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool loggedIN = await Login.checkLogin();

  runApp(
    MaterialApp(
      home: loggedIN ? assist() : Register(),
      debugShowCheckedModeBanner: false,
    ),
  );
}