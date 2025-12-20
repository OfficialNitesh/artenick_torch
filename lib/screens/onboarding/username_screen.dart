import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../main.dart';

class UsernameScreen extends StatefulWidget {
  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _controller = TextEditingController();
  final _userService = UserService();
  bool _isCreating = false;

  Future<void> _createUser() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    setState(() => _isCreating = true);

    await _userService.createUser(_controller.text.trim());
    await _userService.completeOnboarding();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flashlight_on, size: 80, color: Colors.orange),
                SizedBox(height: 24),
                Text(
                  'Welcome to Artenick',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Discipline training platform',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                SizedBox(height: 48),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Choose your username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isCreating,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    backgroundColor: Colors.orange,
                  ),
                  child: _isCreating
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Get Started',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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