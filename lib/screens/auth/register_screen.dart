import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';
import 'package:shoe_store_app/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk menampilkan dialog pop-up
  void _showPopupDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    bool isSuccess = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: iconColor),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Message
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isSuccess) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isSuccess ? 'Lanjutkan' : 'Coba Lagi',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk validasi input
  bool _validateInputs() {
    if (_fullNameController.text.trim().isEmpty) {
      _showPopupDialog(
        title: 'Nama Lengkap Kosong',
        message:
            'Silakan masukkan nama lengkap Anda untuk melanjutkan pendaftaran.',
        icon: Icons.person_outline,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (_fullNameController.text.trim().length < 2) {
      _showPopupDialog(
        title: 'Nama Terlalu Pendek',
        message:
            'Nama lengkap harus minimal 2 karakter. Silakan gunakan nama yang lebih lengkap.',
        icon: Icons.person_outline,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (_usernameController.text.trim().isEmpty) {
      _showPopupDialog(
        title: 'Username Kosong',
        message: 'Silakan masukkan username untuk akun Anda.',
        icon: Icons.account_circle_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (_usernameController.text.trim().length < 3) {
      _showPopupDialog(
        title: 'Username Terlalu Pendek',
        message:
            'Username harus minimal 3 karakter. Silakan gunakan username yang lebih panjang.',
        icon: Icons.account_circle_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showPopupDialog(
        title: 'Email Kosong',
        message:
            'Silakan masukkan alamat email Anda untuk melanjutkan pendaftaran.',
        icon: Icons.email_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showPopupDialog(
        title: 'Format Email Tidak Valid',
        message:
            'Silakan masukkan alamat email dengan format yang benar (contoh: user@example.com).',
        icon: Icons.email_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showPopupDialog(
        title: 'Password Kosong',
        message: 'Silakan masukkan password untuk akun Anda.',
        icon: Icons.lock_outline,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showPopupDialog(
        title: 'Password Terlalu Pendek',
        message:
            'Password harus minimal 6 karakter. Silakan gunakan password yang lebih panjang dan aman.',
        icon: Icons.lock_outline,
        iconColor: Colors.orange,
      );
      return false;
    }

    return true;
  }

  // Fungsi untuk validasi format email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _register() async {
    // Validasi input terlebih dahulu
    if (!_validateInputs()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Clear error sebelum registrasi
    authProvider.clearError();

    try {
      bool success = await authProvider.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _fullNameController.text.trim(),
      );

      if (success) {
        _showPopupDialog(
          title: 'Registrasi Berhasil!',
          message:
              'Akun Anda berhasil dibuat! Selamat datang di toko sepatu kami.',
          icon: Icons.check_circle,
          iconColor: Colors.green,
          isSuccess: true,
        );
      } else {
        // Ambil error message dari AuthProvider
        String errorMessage = authProvider.errorMessage ?? 'Registrasi gagal';

        // Menentukan jenis error berdasarkan pesan dari AuthProvider
        if (errorMessage.toLowerCase().contains('email already') ||
            errorMessage.toLowerCase().contains('email is already')) {
          _showPopupDialog(
            title: 'Email Sudah Terdaftar',
            message:
                'Email yang Anda masukkan sudah terdaftar. Silakan gunakan email lain atau login dengan akun yang ada.',
            icon: Icons.email_outlined,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains('username already') ||
            errorMessage.toLowerCase().contains('username is already')) {
          _showPopupDialog(
            title: 'Username Sudah Digunakan',
            message:
                'Username yang Anda pilih sudah digunakan. Silakan pilih username yang berbeda.',
            icon: Icons.account_circle_outlined,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains(
              'password requirements',
            ) ||
            errorMessage.toLowerCase().contains('password')) {
          _showPopupDialog(
            title: 'Password Tidak Memenuhi Syarat',
            message:
                'Password Anda tidak memenuhi persyaratan keamanan. Pastikan password minimal 6 karakter.',
            icon: Icons.lock_outline,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains('invalid email') ||
            errorMessage.toLowerCase().contains('email format')) {
          _showPopupDialog(
            title: 'Format Email Salah',
            message:
                'Format email yang Anda masukkan tidak valid. Silakan periksa kembali alamat email Anda.',
            icon: Icons.email_outlined,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains('no internet') ||
            errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('connection')) {
          _showPopupDialog(
            title: 'Masalah Koneksi',
            message:
                'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi.',
            icon: Icons.wifi_off,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains('timeout')) {
          _showPopupDialog(
            title: 'Timeout',
            message:
                'Proses registrasi memakan waktu terlalu lama. Silakan coba lagi.',
            icon: Icons.timer_off,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains('server error')) {
          _showPopupDialog(
            title: 'Server Error',
            message:
                'Terjadi kesalahan pada server. Silakan coba lagi dalam beberapa saat.',
            icon: Icons.dns_outlined,
            iconColor: Colors.red,
          );
        } else if (errorMessage.toLowerCase().contains(
          'invalid registration data',
        )) {
          _showPopupDialog(
            title: 'Data Tidak Valid',
            message:
                'Data registrasi yang Anda masukkan tidak valid. Silakan periksa kembali informasi Anda.',
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        } else {
          // Default error message
          _showPopupDialog(
            title: 'Registrasi Gagal',
            message: errorMessage.isNotEmpty
                ? errorMessage
                : 'Terjadi kesalahan saat mendaftar. Silakan coba lagi.',
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        }
      }
    } catch (e) {
      _showPopupDialog(
        title: 'Terjadi Kesalahan',
        message:
            'Terjadi kesalahan yang tidak terduga. Silakan coba lagi dalam beberapa saat.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Shoe Store Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      size: 50,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Welcome Text
                  const Text(
                    'Join Our Store!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Create your account and start shopping',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
                  ),

                  const SizedBox(height: 40),

                  // Full Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color(0xFF7F8C8D),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        labelStyle: TextStyle(color: Color(0xFF7F8C8D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Username Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.account_circle_outlined,
                          color: Color(0xFF7F8C8D),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        labelStyle: TextStyle(color: Color(0xFF7F8C8D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF7F8C8D),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        labelStyle: TextStyle(color: Color(0xFF7F8C8D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF7F8C8D),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        labelStyle: TextStyle(color: Color(0xFF7F8C8D)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: authProvider.isLoading
                        ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF34495E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3E50),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: const Color(
                                0xFF2C3E50,
                              ).withOpacity(0.3),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.app_registration, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with shoe icon
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.sports_basketball,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2C3E50),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Kembali ke halaman login
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2C3E50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer text
                  Text(
                    'Start your shoe shopping journey today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
