// main.dart
import 'package:flutter/material.dart';
import 'google_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: GoogleSignInScreen());
  }
}

class GoogleSignInScreen extends StatefulWidget {
  @override
  _GoogleSignInScreenState createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await loginWithGoogle();
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : _userData == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Login with Google'),
                    ),
                  ],
                )
                : UserInfoCard(userData: _userData!),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserInfoCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userData['user_info']['picture'] != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    userData['user_info']['picture'],
                  ),
                  radius: 40,
                ),
              const SizedBox(height: 16),
              Text(
                userData['user_info']['name'] ?? 'No name',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                userData['user_info']['email'] ?? 'No email',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                userData['token'].toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
