import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/FireStoreService.dart';
import '../../models/UserEmailProvider.dart';
import '../../models/auth.dart';
import '../../widgets/password_text_form_field.dart';
import '../task_screen/task_list.dart';
import './registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late bool _isLoginInProgress;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _isLoginInProgress = false;
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userEmailProvider = Provider.of<UserEmailProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Center(child: Text('Login')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/logo.png'),
            Padding(
        
        
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'user@gmail.com',
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    PasswordTextFormField(
                      labelText: 'Password',
                      passwordEditingController: _passwordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter password.';
                        } else if (value!.length < 8) {
                          return 'Password must be at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.amberAccent, // Text color
                          fontSize: 16.0,    // Text size
                        ),
                        padding: const EdgeInsets.all(10.0),  // Padding around the text
                        backgroundColor: Colors.amberAccent,   // Button background color
                      ),
                      onPressed: _isLoginInProgress == true
                          ? null
                          : () {
                        if (_formKey.currentState!.validate() == true) {
                          loginUser(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                        }
                      },
                      child: Visibility(
                        visible: _isLoginInProgress,
                        replacement: const Text('Login'),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Haven\'t account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (cntxt) => const RegistrationScreen(),
                              ),
                            );
                          },
                          child: const Text('Create'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'user@gmail.com',
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    PasswordTextFormField(
                      labelText: 'Password',
                      passwordEditingController: _passwordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter password.';
                        } else if (value!.length < 8) {
                          return 'Password must be at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          color: Colors.amberAccent, // Text color
                          fontSize: 16.0,    // Text size
                        ),
                        padding: const EdgeInsets.all(10.0),  // Padding around the text
                        backgroundColor: Colors.amberAccent,   // Button background color
                      ),
                      onPressed: _isLoginInProgress == true
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate() == true) {
                          userEmailProvider.setEnteredEmail(_emailController.text.trim());
                          print(_emailController.text);
                          String? userName = await _firestoreService.getUserName(_emailController.text.trim());
                          // Store the user's name
                          if (userName != null) {
                            userEmailProvider.setUserName(userName);
                          }
                          loginUser(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                        }
                      },
                      child: Visibility(
                        visible: _isLoginInProgress,
                        replacement: const Text('Login'),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Haven\'t account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (cntxt) => const RegistrationScreen(),
                              ),
                            );
                          },
                          child: const Text('Create'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        
        
        ),
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoginInProgress = true;
    if (mounted) {
      setState(() {});
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoginInProgress = false;
      if (mounted) {
        setState(() {});
      }
      log(userCredential.user.toString());
      if (userCredential.user?.emailVerified == false) {
        showToastMessage('Please varify your account.',
            color: Colors.red, actionLabel: 'SEND', action: () async {
          await userCredential.user?.sendEmailVerification();
          showToastMessage(
            'Varification URL is sent to your email.',
            color: Colors.green,
          );
        });
      } else if (userCredential.user?.emailVerified == true) {
        log('login success');
        // log(userCredential.user!.uid);
        // log(userCredential.user!.phoneNumber.toString());
        // log(userCredential.user.toString());
        final UserModel user = UserModel(
          userEmail: email,
          userId: userCredential.user!.uid,
        );
        await UserAuth().saveUserAuth(user);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (cntxt) => const TaskScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('user-not-found') == true ||
          e.code.contains('wrong-password') == true) {
        showToastMessage('E-mail or Password is incorrect!', color: Colors.red);
      }
    } catch (e) {
      showToastMessage(e.toString(), color: Colors.red);
    }

    _isLoginInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  void showToastMessage(String content,
      {Color color = Colors.green, VoidCallback? action, String? actionLabel}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(content),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                onPressed: () {
                  if (action != null) {
                    action();
                  }
                },
                label: actionLabel,
                textColor: Colors.white,
                backgroundColor: Colors.black38,
              ),
      ),
    );
  }
}
