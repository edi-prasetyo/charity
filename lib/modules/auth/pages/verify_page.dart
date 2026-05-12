import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class VerifyPage extends ConsumerStatefulWidget {
  final String email; // Email dikirim dari halaman login

  const VerifyPage({super.key, required this.email});

  @override
  ConsumerState<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends ConsumerState<VerifyPage> {
  // Membuat 6 controller untuk 6 kotak OTP
  bool _isResending = false;

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .resendOtp(widget.email);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kode OTP baru telah dikirim ke email Anda."),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim ulang: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    // Gabungkan ke-6 input menjadi satu string OTP
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi kode OTP terlebih dahulu")),
      );
      return;
    }

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(widget.email, otp);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verifikasi Berhasil! Akun Anda aktif."),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman utama atau navigasi ke Home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verifikasi OTP"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 77, 80, 129),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: Color.fromARGB(255, 77, 80, 129),
            ),
            const SizedBox(height: 30),
            const Text(
              "Masukkan Kode Verifikasi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Kode telah dikirim ke ${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 50),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),

            const SizedBox(height: 40),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 77, 80, 129),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Verifikasi Sekarang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: _isResending ? null : _handleResendOtp,
              child: _isResending
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Kirim Ulang Kode"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "", // Menghilangkan angka counter di bawah
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 77, 80, 129),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            // Pindah ke kotak berikutnya
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Kembali ke kotak sebelumnya jika dihapus
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
