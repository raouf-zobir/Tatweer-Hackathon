import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/style.dart';
import '../../providers/auth_provider.dart';
import '../main/main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _acceptedTerms = false;

  Future<void> _login() async {
    if (!_acceptedTerms) {
      setState(() => _errorMessage = 'Please accept the terms and conditions');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final success = await context.read<AuthProvider>().login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else if (mounted) {
        setState(() => _errorMessage = 'Invalid credentials');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '1. Acceptance of Terms\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'By accessing and using this dashboard, you accept and agree to be bound by the terms and provision of this agreement.\n\n',
              ),
              Text(
                '2. Use License\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Permission is granted to temporarily use this dashboard for personal and business monitoring purposes only.\n\n',
              ),
              Text(
                '3. Disclaimer\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'The materials on this dashboard are provided on an "as is" basis.\n\n',
              ),
              Text(
                '4. Limitations\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'In no event shall the company or its suppliers be liable for any damages arising out of the use or inability to use the materials on the dashboard.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 100,
              ),
              const SizedBox(height: defaultPadding),
              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: defaultPadding),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red[400]),
                ),
              ],
              const SizedBox(height: defaultPadding * 2),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  fillColor: bgColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  fillColor: bgColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding * 2),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() => _acceptedTerms = value ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTerms,
                      child: const Text(
                        'I accept the terms and conditions',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding,
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  // Add bypass button
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding,
                        vertical: defaultPadding,
                      ),
                    ),
                    onPressed: () {
                      // Direct access to dashboard
                      context.read<AuthProvider>().bypassLogin();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    },
                    child: const Text(
                      "Skip Login",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
