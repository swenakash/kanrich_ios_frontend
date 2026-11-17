import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const KanrichSupportApp());
}

class KanrichSupportApp extends StatelessWidget {
  const KanrichSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanrich Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF212121),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}

enum SystemType {
  icims('ICIMS System'),
  micro('Micro Loan System'),
  rbs('RBS (Welanda Warama)');

  final String label;
  const SystemType(this.label);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SystemType _selectedSystem = SystemType.icims;
  bool _isLoading = false;
  String _statusMessage = '';

  String _getEndpoint(SystemType system) {
    switch (system) {
      case SystemType.icims:
        return 'https://your-kanrich-server.com/api/icims/login';
      case SystemType.micro:
        return 'https://your-kanrich-server.com/api/micro/login';
      case SystemType.rbs:
        return 'https://your-kanrich-server.com/api/rbs/login';
    }
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter Username and Password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_getEndpoint(_selectedSystem)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'system': _selectedSystem.label,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = 'Login Successful (${_selectedSystem.label})';
        });
        // Dashboard screen වෙත යොමු කිරීම මෙතැනට එක් කරන්න
      } else {
        setState(() {
          _statusMessage = 'Login Failed: Server Error ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection Error: $e';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        title: const Text(
          'Kanrich Support',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'sync', child: Text('Sync Data')),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section
                const Text(
                  'KANRICH',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007336),
                    height: 1.0,
                  ),
                ),
                const Text(
                  'LIMITED',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4,
                    color: Color(0xFF8CC63F),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Relationships without borders',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
                const SizedBox(height: 30),

                // User name Field
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'User name',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00897B), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00897B), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // System Selection Radio Buttons
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: SystemType.values.map((system) {
                      return RadioListTile<SystemType>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: const Color(0xFF00897B),
                        title: Text(
                          system.label,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        value: system,
                        groupValue: _selectedSystem,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSystem = value);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // LOG IN Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8F500), // Bright Lime
                      foregroundColor: Colors.black,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                        : const Text(
                      'LOG IN',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // OFFLINE APP Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBCDCE6), // Light Blue
                      foregroundColor: Colors.black,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OfflineDashboardScreen()),
                      );
                    },
                    child: const Text(
                      'OFFLINE APP',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                if (_statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OfflineDashboardScreen extends StatelessWidget {
  const OfflineDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        title: const Text('Offline Mode', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.receipt_long), title: Text('Micro Bulk Receipt')),
          ListTile(leading: Icon(Icons.calculate), title: Text('Rental Calculation')),
          ListTile(leading: Icon(Icons.savings), title: Text('Deposit Interest Calculation')),
          ListTile(leading: Icon(Icons.speed), title: Text('Vehicle Meter Reading')),
        ],
      ),
    );
  }
}