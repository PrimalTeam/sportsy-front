import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/auth_dto.dart';
import 'login_screen.dart';
import '../modules/services/auth.dart';
import '../modules/services/api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

enum AuthMode { login, register }

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  AuthMode _selectedMode = AuthMode.register;

  void _submit() {
    AuthService.register(
      RegisterDto(
        email: _emailController.text,
        password: _passwordController.text,
        userName: _nicknameController.text,
      ),
    ).then((response) {
      print(response.data);
      _navigateToLogin();
    }).catchError((error) {
      print("Error during registration: $error");
    });
    
  print("${hosturl}--------------------------------------------------------------------------");
  }

  void _navigateToLogin() {
    print("Redirected to the login page");
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
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
                      
                      if (_selectedMode == AuthMode.login) {
                        _navigateToLogin();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: "Surname",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: "Nickname",
                    prefixIcon: const Icon(Icons.badge),
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
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 18),
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