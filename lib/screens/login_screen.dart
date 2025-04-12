import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/auth_dto.dart';
import 'package:sportsy_front/screens/games_list_page.dart';
import 'package:sportsy_front/screens/register_screen.dart';
import '../modules/services/auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthMode _selectedMode = AuthMode.login;
  bool _isLoading = false;

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    AuthService.login(
          LoginDto(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        )
        .then((response) {
          if (response.statusCode == 201) {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(title: "Welcome"),
                ),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Nieprawidłowe dane logowania")),
              );
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Wystąpił błąd. Spróbuj ponownie.")),
            );
          }
        });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
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
                          label: Text("Login", style: TextStyle(
                            color: Colors.black,
                          ),),
                          icon: Icon(Icons.login),

                        ),
                        ButtonSegment<AuthMode>(
                          value: AuthMode.register,
                          label: Text("Register", style: TextStyle(color: Colors.grey)),
                          icon: Icon(Icons.app_registration, color: Colors.grey,),
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
                            CupertinoPageRoute(
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
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                     
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        "LOGIN",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: LoadingAnimationWidget.inkDrop(
                color: Colors.white,
                size: 200,
              ),
            ),
        ],
      ),
    );
  }
}
