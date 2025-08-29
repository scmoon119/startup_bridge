import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _healthStatus = '';

  @override
  void initState() {
    super.initState();
    _checkHealthStatus();
  }

  Future<void> _checkHealthStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/health'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _healthStatus = response.body;
        });
      } else {
        setState(() {
          _healthStatus = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _healthStatus = 'Connection Error';
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _healthStatus == 'OK'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _healthStatus == 'OK' ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                _healthStatus.isEmpty ? 'Loading...' : _healthStatus,
                style: TextStyle(
                  color: _healthStatus == 'OK'
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          iconSize: 48,
                          color: Colors.blue,
                        ),
                        const Text('계정 생성'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.login),
                          iconSize: 48,
                          color: Colors.green,
                        ),
                        const Text('로그인'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
