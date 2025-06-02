// lib/screens/profile/user_profile_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/providers/auth_provider.dart';

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  // Untuk ganti password (opsional, jika ingin diizinkan di sini)
  // final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Isi form dengan data user yang sudah ada
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController.text = authProvider.user?.fullName ?? '';
    _addressController.text = authProvider.user?.address ?? '';
    _phoneNumberController.text = authProvider.user?.phoneNumber ?? '';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Map<String, dynamic> userData = {
      'full_name': _fullNameController.text,
      'address': _addressController.text,
      'phone_number': _phoneNumberController.text,
      // 'password': _passwordController.text.isNotEmpty ? _passwordController.text : null, // Jika ada ganti password
    };

    bool success = await authProvider.updateUserProfile(userData);

    if (success) {
      _showSnackBar('Profile updated successfully!');
      Navigator.of(context).pop(); // Kembali ke ProfileScreen
    } else {
      _showSnackBar('Failed to update profile. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            // const SizedBox(height: 16), // Jika ada ganti password
            // TextField(
            //   controller: _passwordController,
            //   decoration: const InputDecoration(labelText: 'New Password (optional)'),
            //   obscureText: true,
            // ),
            const SizedBox(height: 32),
            authProvider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
          ],
        ),
      ),
    );
  }
}