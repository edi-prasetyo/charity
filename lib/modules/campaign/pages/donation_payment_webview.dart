import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../main_navigation.dart';

class DonationPaymentWebview extends StatefulWidget {
  final String paymentUrl;
  final String externalId;

  const DonationPaymentWebview({
    super.key,
    required this.paymentUrl,
    required this.externalId,
  });

  @override
  State<DonationPaymentWebview> createState() => _DonationPaymentWebviewState();
}

class _DonationPaymentWebviewState extends State<DonationPaymentWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            // Deteksi jika redirect ke success_url dari backend
            if (request.url.contains('payment/success')) {
              _finishPayment(success: true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // Fungsi tunggal untuk kembali ke Main Navigation
  void _finishPayment({bool success = false}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigation()),
      (route) => false,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih atas donasi Anda!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Mengganti tombol back menjadi Close (X)
        leading: IconButton(
          icon: const Icon(MingCuteIcons.mgc_close_line),
          onPressed: () => _finishPayment(), // Langsung ke main navigation
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(MingCuteIcons.mgc_refresh_1_line),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
