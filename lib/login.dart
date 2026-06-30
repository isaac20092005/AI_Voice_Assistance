import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assist.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();

  static Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged') ?? false;
  }
}

class _LoginState extends State<Login> {

  bool _isLoading = false;
  final uname = TextEditingController();
  final pass = TextEditingController();
  List<dynamic> credential = []; 

  @override
  void initState() {
    super.initState();
    check(); 
  }

  Future<void> check() async {
    try {
      final res = await http.get(Uri.parse("http://pgw.whf.bz/get.php")); 
      if (res.statusCode == 200) {
        setState(() {
          credential = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print("Error fetching credentials: $e");
    }
  }

  Future<void> slocal(String lang) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('logged', true);
  await prefs.setString('lang', lang); 
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Personal Assistant", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30)),
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.tealAccent,
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 5)
            ]
          ),
          height: MediaQuery.of(context).size.height / 1.9,
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            children: [
              const SizedBox(height: 25),
              const Text("Login", style: TextStyle(fontSize: 30)),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: uname,
                  decoration: InputDecoration(
                    labelText: "User Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: pass,
                  obscureText: true, 
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                  ),
                ),
              ),
              const SizedBox(height: 60),
              MaterialButton(
  color: Colors.blueAccent,
  textColor: Colors.white,
  elevation: 10,
  minWidth: 200,
  height: 50,
  
  onPressed: _isLoading 
      ? null 
      : () async {
          setState(() {
            _isLoading = true; 
          });

          
          final matchingUser = credential.firstWhere(
            (user) => user['uname'] == uname.text && user['pass'] == pass.text,
            orElse: () => {},
          );

          
          
if (matchingUser.isNotEmpty) {
  String userLang = matchingUser['lang'] ?? 'en-IN'; 
  await slocal(userLang); 

  if (mounted) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => assist()));
  }
} else {
            
            setState(() {
              _isLoading = false; 
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid Username or Password")),
            );
          }
        },
  
  child: _isLoading 
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
      : const Text("LOGIN"),
)
            ],
          ),
        ),
      ),
    );
  }
}