import 'package:flutter/material.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:pblmsadmin/screens/admin/login/admin_register.dart';
import 'package:provider/provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 63, 23),
              Colors.black,
              Color.fromARGB(255, 5, 63, 23)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Logo positioned at top left
            Positioned(
              top: 16,
              left: 24,
              child: Image.asset(
                'assets/pblogo.png',
                height: 120,
                width: 120,
              ),
            ),
            
            // Main content centered
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isLargeScreen = constraints.maxWidth > 800;
                  double formWidth = isLargeScreen
                      ? constraints.maxWidth * 0.4
                      : constraints.maxWidth * 0.8;
                  double imageWidth =
                      isLargeScreen ? constraints.maxWidth * 0.2 : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Section: Login Form
                      Container(
                        width: formWidth,
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(top: 80), // Added margin to account for logo
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Enter your details to login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Email',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Password',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 26),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Pass context to the login method
                                      Provider.of<AdminAuthProvider>(context,
                                              listen: false)
                                          .adminloginprovider(
                                        _emailController.text,
                                        _passwordController.text,
                                        context, // Pass context here
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 5, 63, 23),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdminregisterScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                ),
                                child: const Text(
                                  'Dont have an account? Sign Up?',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  ForgotPasswordHandler.showEmailPopup(context);
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Section: Image (for large screens)
                      if (isLargeScreen)
                        Container(
                          width: imageWidth,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 80), // Added margin to account for logo
                          child: Image.asset(
                            'assets/quuote.png',
                            height: 600,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordHandler {
  static void showEmailPopup(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            provider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      provider
                          .sendResetEmail(emailController.text, context)
                          .then((_) {
                        Navigator.pop(context); // Close the email dialog
                        showOtpPopup(context, emailController.text);
                      });
                    },
                    child: Text('Send'),
                  ),
          ],
        );
      },
    );
  }

  static void showOtpPopup(BuildContext context, String email) {
    final TextEditingController otpController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP from Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            provider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      provider
                          .resetPassword(
                        email,
                        otpController.text,
                        passwordController.text,
                        context,
                      )
                          .then((_) {
                        Navigator.pop(context); // Close the OTP dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password reset successful!')),
                        );
                      });
                    },
                    child: Text('Reset Password'),
                  ),
          ],
        );
      },
    );
  }
}