import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isEmailChecked = false;
  bool _isEmailCheckInProgress = false;
  String? _emailCheckMessage;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus && _emailController.text.trim().isNotEmpty) {
      _checkEmailDuplicate();
    }
  }

  Future<void> _checkEmailDuplicate() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailCheckMessage = '이메일을 입력해주세요';
      });
      return;
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailCheckMessage = '올바른 이메일 형식을 입력해주세요';
      });
      return;
    }

    setState(() {
      _isEmailCheckInProgress = true;
      _emailCheckMessage = null;
    });

    try {
      final uri = Uri.parse(
        'http://127.0.0.1:8080/api/users/check-email?email=${Uri.encodeComponent(email)}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exists = data['exists'] as bool;

        setState(() {
          _isEmailCheckInProgress = false;
          _isEmailChecked = !exists;
          _emailCheckMessage = !exists ? '사용 가능한 이메일입니다' : '이미 사용 중인 이메일입니다';
        });
      } else {
        setState(() {
          _isEmailCheckInProgress = false;
          _emailCheckMessage = 'API 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isEmailCheckInProgress = false;
        _emailCheckMessage = '연결 오류: 서버에 연결할 수 없습니다';
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_isEmailChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일 중복 확인을 해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('계정을 생성 중입니다...'),
          ],
        ),
      ),
    );

    try {
      final uri = Uri.parse('http://127.0.0.1:8080/api/users');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password, 'name': name}),
      );

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode == 201) {
        // 성공 처리
        final data = json.decode(response.body);
        final userData = data['data'];

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('계정 생성 완료'),
              content: Text(
                '${userData['name']}님의 계정이 성공적으로 생성되었습니다.\n로그인 화면으로 이동합니다.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pushReplacement(
                      // 회원가입 화면을 로그인 화면으로 교체
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('로그인하러 가기'),
                ),
              ],
            ),
          );
        }
      } else if (response.statusCode == 400) {
        // 실패 처리 (이메일 중복 등)
        final data = json.decode(response.body);
        final message = data['message'] ?? '계정 생성에 실패했습니다';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }

        // 이메일 중복일 경우 중복 확인 상태 초기화
        if (message.contains('Email already exists') ||
            message.contains('이메일')) {
          setState(() {
            _isEmailChecked = false;
            _emailCheckMessage = '이미 사용 중인 이메일입니다';
          });
        }
      } else {
        // 기타 서버 오류
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('서버 오류: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      // 네트워크 오류
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('네트워크 오류: 서버에 연결할 수 없습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 생성'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '새 계정 만들기',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '이메일',
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: _isEmailCheckInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _isEmailChecked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (_isEmailChecked) {
                    setState(() {
                      _isEmailChecked = false;
                      _emailCheckMessage = null;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              if (_emailCheckMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    _emailCheckMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isEmailChecked ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isEmailChecked ? _handleSignup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEmailChecked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '계정 생성',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('이미 계정이 있으신가요? 로그인하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
