import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/auth_dto.dart';
import 'package:sportsy_front/screens/games_list_page.dart';
import 'package:sportsy_front/screens/register_screen.dart';
import '../modules/services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

enum AuthMode { login, register }

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthMode _selectedMode = AuthMode.login;

  void _submit() {
    AuthService.login(
      LoginDto(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    ).then((response) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "nie wiem xd"),));
      print(response.data);
    }).catchError((error) {
      print("Error during registration: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AuthMode>(
                  segments: const <ButtonSegment<AuthMode>>[
                    ButtonSegment<AuthMode>(
                      value: AuthMode.login,
                      label: Text("Login"),
                      icon: Icon(Icons.login),
                    ),
                    ButtonSegment<AuthMode>(
                      value: AuthMode.register,
                      label: Text("Register"),
                      icon: Icon(Icons.app_registration),
                    ),
                  ],
                  selected: <AuthMode>{_selectedMode},
                  onSelectionChanged: (Set<AuthMode> newSelection) {
                    setState(() {
                      _selectedMode = newSelection.first;
                    });
                    if (_selectedMode == AuthMode.register) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    _selectedMode == AuthMode.login ? "Login" : "Register",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
