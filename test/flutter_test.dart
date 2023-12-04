import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfirebasecrudapp/main.dart';
import 'package:flutterfirebasecrudapp/widgets/password_text_form_field.dart'; // Replace with the actual path to your main.dart file

void main() {
  testWidgets('Widget Test', (WidgetTester tester) async {
    // Build your app and trigger a frame.
    bool _isCreateAccountInProgress = false;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();

    await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
                body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 46.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  PasswordTextFormField(
                    labelText: 'Confirm Password',
                    passwordEditingController: _confirmPasswordController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter confirm password.';
                      } else if (value!.length < 8) {
                        return 'Password must be at least 8 characters.';
                      } else if (value != _passwordController.text) {
                        return 'Password and Confirm Password must be match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        color: Colors.amberAccent, // Text color
                        fontSize: 16.0,    // Text size
                      ),
                      padding: EdgeInsets.all(10.0),  // Padding around the text
                      backgroundColor: Colors.amberAccent,   // Button background color
                    ),
                    onPressed: () {

                    },
                    child: const Text('Create Account'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Have an account?'),
                      TextButton(
                        onPressed: () {
                        },
                        child: const Text('Login'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
                ),
              ),
        )
    );// Replace MyApp with the actual name of your main widget

    // Verify that the Create Account screen is displayed.
    expect(find.text('Create Account'), findsOneWidget);

    // Fill in the form fields.
    await tester.enterText(find.widgetWithText(TextFormField,'Full Name'), 'John Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'john.doe@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

    expect(_nameController.text, 'John Doe');
    expect(_emailController.text, 'john.doe@example.com');
    expect(_passwordController.text, 'password123');
    expect(_confirmPasswordController.text, 'password123');
  });
}
