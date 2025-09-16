// Lütfen bu kodu kopyalayıp lib/screens/register_screen.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart'; // HATA BURADAYDI: 'package.flutter' -> 'package:flutter' olarak düzeltildi.
import 'package:provider/provider.dart'; // HATA BURADAYDI: 'package.provider' -> 'package:provider' olarak düzeltildi.

import '../providers/auth_provider.dart';
import 'complete_profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isScreenLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isScreenLoading) {
      return;
    }

    setState(() {
      _isScreenLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              authProvider.errorMessage ?? 'Kayıt sırasında bir hata oluştu.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isScreenLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
        automaticallyImplyLeading: !_isScreenLoading,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: AbsorbPointer(
              absorbing: _isScreenLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(labelText: 'Kullanıcı Adı'),
                    enabled: !_isScreenLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen bir kullanıcı adı girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isScreenLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen bir e-posta adresi girin.';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Lütfen geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                    enabled: !_isScreenLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir şifre girin.';
                      }
                      if (value.length < 8) {
                        return 'Şifre en az 8 karakter olmalıdır.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _isScreenLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text('KAYIT OL'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
