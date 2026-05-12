import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/widgets/app_button.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/campaign_model.dart';
import 'donation_preview_page.dart';

class CampaignDonationPage extends ConsumerStatefulWidget {
  final Campaign campaign;

  const CampaignDonationPage({super.key, required this.campaign});

  @override
  ConsumerState<CampaignDonationPage> createState() =>
      _CampaignDonationPageState();
}

class _CampaignDonationPageState extends ConsumerState<CampaignDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isAnonymous = false;

  final List<int> _quickAmounts = [20000, 25000, 50000, 100000, 250000, 500000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fillInitialProfileData();
    });
  }

  void _fillInitialProfileData() {
    final profileAsync = ref.read(profileProvider);
    profileAsync.whenData((user) {
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
        });
      }
    });
  }

  void _submitToPreview() {
    if (_formKey.currentState!.validate()) {
      final donationData = {
        'amount': _amountController.text
            .replaceAll('.', '')
            .replaceAll('Rp ', ''),
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'message': _messageController.text,
        'is_anonymous': _isAnonymous,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonationPreviewPage(
            donationData: donationData,
            campaign: widget.campaign,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(profileProvider, (previous, next) {
      next.whenData((user) {
        if (_nameController.text.isEmpty) {
          setState(() {
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phone ?? '';
          });
        }
      });
    });

    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Donasi Sekarang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(MingCuteIcons.mgc_left_line),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildFormContent(),
        data: (profile) => _buildFormContent(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildFormContent() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Info Kampanye
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 1.0),
                    AppColors.primaryColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    MingCuteIcons.mgc_heart_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Membantu Untuk:',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          widget.campaign.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Section Nominal
            const _SectionTitle(title: 'Pilih Nominal Donasi'),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: _quickAmounts.length,
              itemBuilder: (context, index) {
                final amount = _quickAmounts[index];
                bool isSelected = _amountController.text == amount.toString();
                return InkWell(
                  onTap: () => setState(
                    () => _amountController.text = amount.toString(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.1)
                          : Colors.white,
                    ),
                    child: Text(
                      currencyFormat.format(amount).replaceAll(',00', ''),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  MingCuteIcons.mgc_wallet_4_line,
                  color: AppColors.primaryColor,
                ),
                prefixText: 'Rp ',
                hintText: 'Nominal lainnya...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              // UPDATE BAGIAN VALIDATOR DI BAWAH INI:
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nominal';
                }

                // Hilangkan karakter non-digit jika ada (seperti titik atau spasi)
                final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                final amount = int.tryParse(cleanedValue);

                if (amount == null) {
                  return 'Nominal tidak valid';
                }

                if (amount < 20000) {
                  return 'Minimal donasi Rp 20.000';
                }

                return null;
              },
            ),
            const SizedBox(height: 32),

            // Section Profil
            const _SectionTitle(title: 'Data Diri'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    _nameController,
                    'Nama Lengkap',
                    MingCuteIcons.mgc_user_3_line,
                    readOnly: true,
                  ),
                  _buildTextField(
                    _emailController,
                    'Alamat Email',
                    MingCuteIcons.mgc_mail_line,
                    readOnly: true,
                  ),
                  _buildTextField(
                    _phoneController,
                    'WhatsApp',
                    MingCuteIcons.mgc_phone_line,
                    readOnly: true,
                  ),
                  _buildTextField(
                    _messageController,
                    'Doa atau Dukungan (Opsional)',
                    MingCuteIcons.mgc_chat_2_line,
                    maxLines: 3,
                  ),
                  const Divider(height: 30),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Sembunyikan nama (Anonim)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Nama Anda tidak akan ditampilkan di publik',
                      style: TextStyle(fontSize: 12),
                    ),
                    activeColor: AppColors.primaryColor,
                    value: _isAnonymous,
                    onChanged: (val) => setState(() => _isAnonymous = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: AppButton(
            title: "Lanjutkan",
            type: AppButtonType.primary,
            rightIcon: Icons.arrow_forward,
            onPressed: _submitToPreview,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            style: TextStyle(
              fontSize: 14,
              color: readOnly ? Colors.black54 : Colors.black87,
              fontWeight: readOnly ? FontWeight.normal : FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: AppColors.primaryColor),
              filled: true,
              fillColor: readOnly
                  ? const Color(0xFFF1F3F5)
                  : const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Isi $hint...',
              hintStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
            validator: (value) {
              if (controller == _messageController) return null;
              return (value == null || value.isEmpty) ? 'Wajib diisi' : null;
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }
}
