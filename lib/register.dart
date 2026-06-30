import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  bool _isLoading = false;
  final uname = TextEditingController();
  final pass = TextEditingController();
  
  var items = ['English', 'Hindi', 'Tamil', 'Malayalam', 'Telugu'];
  String dropdownvalue = "English";

  Map<String, String> langl = {
    'English': 'en-IN',
    'Hindi': 'hi-IN',
    'Tamil': 'ta-IN',
    'Malayalam': 'ml-IN',
    'Telugu': 'te-IN',
  };

  Future<void> save(String uname, String pass, String lang) async {
    try {
      await http.post(Uri.parse("http://pgw.whf.bz/register.php"), body: {"uname": uname, "pass": pass, "lang": lang});
    } catch (e) {
      print("Error registering online: $e");
    }
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
          height: MediaQuery.of(context).size.height / 1.8,
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            children: [
              const SizedBox(height: 25),
              const Text("Register", style: TextStyle(fontSize: 30)),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 25),
              Row(
                children: [
                  const Text("   Choose Language:      ", style: TextStyle(fontSize: 15)),
                  DropdownButton<String>(
                    value: dropdownvalue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: items.map((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              MaterialButton(
  color: Colors.blueAccent,
  elevation: 10,
  minWidth: 200,
  height: 50,
  onPressed: _isLoading 
      ? null 
      : () async {
          setState(() {
            _isLoading = true; 
          });

          try {
            String language = langl[dropdownvalue]!;

            
            await save(uname.text, pass.text, language);

            if (mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
            }
          } catch (e) {
            
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registration failed: $e")),
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
      : const Text("REGISTER", style: TextStyle(color: Colors.white, fontSize: 17)),
),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {

                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                },
                child: const Text("Already a User  -  LOGIN", style: TextStyle(fontSize: 20)),
              )
            ],
          ),
        ),
      ),
    );
  }
}