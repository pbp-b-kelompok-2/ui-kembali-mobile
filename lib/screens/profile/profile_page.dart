import 'package:material_ui/material_ui.dart';

import '../../theme.dart';

/// Static profile screen matching the current mobile design mockup.
/// Replace the sample profile values with API data when auth is integrated.
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.onBack,
    this.onTransactions,
  });

  final VoidCallback? onBack;
  final VoidCallback? onTransactions;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nickname = TextEditingController(text: 'Nadia');
  final _phone = TextEditingController(text: '+62 812 3456 7890');
  final _meetingPoint = TextEditingController(
    text: 'Perpustakaan UI, Stasiun UI',
  );
  final _bio = TextEditingController(
    text: 'Suka berbagi buku kuliah dan mencari kebutuhan kos yang masih layak pakai.',
  );

  @override
  void dispose() {
    _nickname.dispose();
    _phone.dispose();
    _meetingPoint.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(onBack: widget.onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _IdentityCard(),
                    const SizedBox(height: 16),
                    _OutlineAction(
                      label: 'Barang saya',
                      onPressed: () => _showMessage('Barang saya segera hadir.'),
                    ),
                    const SizedBox(height: 16),
                    _OutlineAction(
                      label: 'Riwayat transaksi',
                      onPressed: widget.onTransactions,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Informasi profil',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nama dan fakultas disinkronkan dari UI SSO.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    const _ProfileLabel('Nama lengkap'),
                    const SizedBox(height: 8),
                    const _ReadOnlyField(value: 'Nadia Ayuningtyas'),
                    const SizedBox(height: 24),
                    const _ProfileLabel('Nama panggilan'),
                    const SizedBox(height: 8),
                    _EditableField(controller: _nickname),
                    const SizedBox(height: 24),
                    const _ProfileLabel('Program studi'),
                    const SizedBox(height: 8),
                    const _ReadOnlyField(value: 'Biologi, FMIPA'),
                    const SizedBox(height: 24),
                    const _ProfileLabel('Angkatan'),
                    const SizedBox(height: 8),
                    const _ReadOnlyField(value: '2022'),
                    const SizedBox(height: 24),
                    const _ProfileLabel('Nomor WhatsApp'),
                    const SizedBox(height: 8),
                    _EditableField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nomor hanya terlihat setelah transaksi disetujui.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 11),
                    ),
                    const SizedBox(height: 20),
                    const _ProfileLabel('Titik temu favorit'),
                    const SizedBox(height: 8),
                    _EditableField(controller: _meetingPoint),
                    const SizedBox(height: 24),
                    _BioField(controller: _bio),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.ink,
                        minimumSize: const Size.fromHeight(48),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => _showMessage(
                        'Perubahan profil akan tersimpan setelah API tersedia.',
                      ),
                      child: const Text('Simpan perubahan'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppColors.greenDark,
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 2),
          const Text(
            'Profil saya',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.subtle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 27,
            color: AppColors.greenDark,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nadia Ayuningtyas',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Biologi · FMIPA 2022',
            style: TextStyle(color: AppColors.inkSoft, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.infoTint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Warga UI terverifikasi',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 20,
            runSpacing: 6,
            children: [
              _StatText('4,9 ★'),
              _StatText('12 transaksi'),
              _StatText('9,6 kg dampak'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  const _StatText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: AppColors.greenDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size.fromHeight(46),
          foregroundColor: AppColors.greenDark,
          backgroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      );
}

class _ProfileLabel extends StatelessWidget {
  const _ProfileLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => _FieldContainer(
        child: Text(value, style: const TextStyle(color: AppColors.inkSoft, fontSize: 14)),
      );
}

class _EditableField extends StatelessWidget {
  const _EditableField({required this.controller, this.keyboardType});

  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => _FieldContainer(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.inkSoft, fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
}

class _FieldContainer extends StatelessWidget {
  const _FieldContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 46),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
}

class _BioField extends StatelessWidget {
  const _BioField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bio singkat',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 3,
              maxLength: 160,
              style: const TextStyle(color: AppColors.ink, fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ],
        ),
      );
}

