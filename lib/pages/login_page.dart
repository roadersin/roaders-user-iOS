import 'package:flutter/material.dart';
import '../components/login_components/login_form_widget.dart';
import '../components/login_components/login_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailTextField = TextEditingController();
  TextEditingController _phoneTextField = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers here
    _emailTextField = TextEditingController();
    _phoneTextField = TextEditingController();
  }

  // Function to validate email
  bool _validateEmail(String value) {
    // Email validation regular expression pattern
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(value);
  }

  bool _validatePhone(String phone) {
    // Your phone validation logic here
    return RegExp(r'^\+?\d{10,15}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- section 1 --
                LoginHeaderWidget(size, context),
                // -- end --

                // -- section 2 --
                loginFormWidget(
                  _emailTextField,
                  _phoneTextField,
                  _formKey,
                  context,
                  _validateEmail, // Pass the email validation function
                  _validatePhone, // Pass the phone validation function
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
