import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../controllers/profile_controller.dart';
import '../../../core/widgets/app_button.dart'; // ⬅️ sesuaikan path

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  ConsumerState<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final message = await ref.read(
        updatePasswordProvider({
          "current_password": currentPasswordController.text,
          "new_password": newPasswordController.text,
          "new_password_confirmation": confirmPasswordController.text,
        }).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// 🔥 reusable modern input
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xfff1f3f7),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Wajib diisi";
        }

        if (!isConfirm && label == "Password Baru" && value.length < 8) {
          return "Minimal 8 karakter";
        }

        if (isConfirm && value != newPasswordController.text) {
          return "Password tidak sama";
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text(
          "Update Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Title
              const Text(
                "Ubah Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                "Pastikan password baru berbeda dari sebelumnya",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              /// 🔹 FORM
              _buildInput(
                controller: currentPasswordController,
                label: "Password Lama",
                icon: MingCuteIcons.mgc_file_locked_line,
              ),

              const SizedBox(height: 16),

              _buildInput(
                controller: newPasswordController,
                label: "Password Baru",
                icon: MingCuteIcons.mgc_key_2_line,
              ),

              const SizedBox(height: 16),

              _buildInput(
                controller: confirmPasswordController,
                label: "Konfirmasi Password",
                icon: MingCuteIcons.mgc_safe_shield_2_line,
                isConfirm: true,
              ),

              const SizedBox(height: 30),

              /// 🔥 BUTTON pakai AppButton
              AppButton(
                title: "Update Password",
                isLoading: isLoading,
                leftIcon: MingCuteIcons.mgc_save_2_line,
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
