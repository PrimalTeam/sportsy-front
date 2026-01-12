import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/auth_dto.dart';
import 'package:sportsy_front/features/auth/data/auth_remote_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

enum AuthMode { login, register }

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  AuthMode _selectedMode = AuthMode.register;

  void _submit() {
    // Validate passwords match
    if (_passwordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    // Validate fields are not empty
    if (_nicknameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    AuthRemoteService.register(
          RegisterDto(
            email: _emailController.text,
            password: _passwordController.text,
            userName: _nicknameController.text,
          ),
        )
        .then((response) {
          if (mounted) {
            if (response.statusCode == 201) {
              print(response.data);
              _navigateToLogin();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("E-mail or username is already taken.")),
              );
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Register error.")));
          }
        });
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
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
                        label: Text(
                          "Login",
                          style: TextStyle(color: Colors.grey),
                        ),
                        icon: Icon(Icons.login, color: Colors.grey),
                      ),
                      ButtonSegment<AuthMode>(
                        value: AuthMode.register,
                        label: Text(
                          "Register",
                          style: TextStyle(color: Colors.black),
                        ),
                        icon: Icon(Icons.app_registration),
                      ),
                    ],
                    selected: <AuthMode>{_selectedMode},
                    onSelectionChanged: (Set<AuthMode> newSelection) {
                      setState(() {
                        _selectedMode = newSelection.first;
                      });

                      if (_selectedMode == AuthMode.login) {
                        _navigateToLogin();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

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

                TextField(
                  controller: _repeatPasswordController,
                  decoration: InputDecoration(
                    labelText: "Repeat Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  child: ElevatedButton(
                    onPressed: _submit,

                    child: const Text(
                      "REGISTER",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
