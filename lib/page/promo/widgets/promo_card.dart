import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromoCard extends StatelessWidget {
  final String title;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? minTransaction;
  final double? maxDiscount;
  final String? startDate;
  final String? endDate;
  final int quota;
  final int usedQuota;
  final bool isActive;
  final String? promoCode;
  final String? targetType;
  final String? image; // ← TAMBAH
  final VoidCallback? onTap;

  const PromoCard({
    super.key,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minTransaction,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    required this.quota,
    required this.usedQuota,
    required this.isActive,
    this.promoCode,
    this.targetType,
    this.image, // ← TAMBAH
    this.onTap,
  });

  String _rp(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  String get discountLabel => discountType == 'fixed'
      ? 'Hemat ${_rp(discountValue)}'
      : 'Hemat ${discountValue.toInt()}%';

  String get discountBadge => discountType == 'fixed'
      ? _rp(discountValue)
      : '${discountValue.toInt()}%';

  int get sisaKuota => quota > 0 ? quota - usedQuota : 999;
  bool get isUnlimited => quota == 0;

  String _formatDateStr(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agu','Sep','Okt','Nov','Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _targetLabel() {
    switch (targetType) {
      case 'ticket': return 'pembelian tiket bus';
      case 'rental': return 'sewa armada';
      case 'tour':   return 'paket wisata';
      default:       return 'semua layanan';
    }
  }

  String _targetBadge() {
    switch (targetType) {
      case 'ticket': return 'Tiket Bus';
      case 'rental': return 'Sewa Bus';
      case 'tour':   return 'Wisata';
      default:       return 'Semua';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER — gambar kalau ada, gradient kalau tidak ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: image != null && image!.isNotEmpty
                  ? Stack(
                      children: [
                        // Gambar dari server
                        Image.network(
                          image!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _gradientHeader(),
                        ),
                        // Overlay gelap supaya teks tetap terbaca
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.55),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Konten di atas gambar
                        Positioned(
                          left: 16, right: 16, bottom: 16,
                          child: _headerContent(),
                        ),
                      ],
                    )
                  : _gradientHeader(),
            ),

            // ── BODY INFO ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _infoRow(
                    icon: Icons.calendar_today_rounded,
                    label: startDate == null && endDate == null
                        ? 'Berlaku setiap saat'
                        : '${_formatDateStr(startDate)} – ${_formatDateStr(endDate)}',
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 14, color: Color(0xFF8B0000)),
                      const SizedBox(width: 8),
                      Text(
                        isUnlimited
                            ? 'Kuota tidak terbatas'
                            : 'Sisa $sisaKuota dari $quota kuota',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF555555)),
                      ),
                      if (!isUnlimited) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: quota > 0 ? usedQuota / quota : 0,
                              backgroundColor: const Color(0xFFEEEEEE),
                              color: sisaKuota <= (quota * 0.2)
                                  ? Colors.orange
                                  : const Color(0xFF8B0000),
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (minTransaction != null && minTransaction! > 0) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      icon: Icons.payments_outlined,
                      label: 'Min. transaksi ${_rp(minTransaction!)}',
                    ),
                  ],

                  if (maxDiscount != null && maxDiscount! > 0 &&
                      discountType == 'percent') ...[
                    const SizedBox(height: 6),
                    _infoRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Maks. diskon ${_rp(maxDiscount!)}',
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF0EBE8)),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'Aktif' : 'Tidak Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () {
                          final teks = promoCode ?? discountBadge;
                          Clipboard.setData(ClipboardData(text: teks));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(promoCode != null
                                  ? 'Kode "$promoCode" disalin!'
                                  : 'Info diskon disalin!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF8B0000),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B0000).withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.copy_rounded,
                                  size: 13, color: Color(0xFF8B0000)),
                              SizedBox(width: 5),
                              Text(
                                'Salin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8B0000),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B0000).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 12,
                                color: Color(0xFF8B0000),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Syarat & Ketentuan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (startDate != null || endDate != null)
                          _syaratItem(
                            'Berlaku ${_formatDateStr(startDate)} s/d ${_formatDateStr(endDate)}',
                          ),
                        if (!isUnlimited)
                          _syaratItem('Kuota terbatas ($quota pengguna)'),
                        _syaratItem(
                            'Diskon $discountLabel untuk ${_targetLabel()}'),
                        if (minTransaction != null && minTransaction! > 0)
                          _syaratItem('Min. transaksi ${_rp(minTransaction!)}'),
                        if (maxDiscount != null && maxDiscount! > 0 &&
                            discountType == 'percent')
                          _syaratItem('Maks. diskon ${_rp(maxDiscount!)}'),
                        _syaratItem('Tidak dapat digabung dengan promo lain'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header (fallback kalau tidak ada gambar) ────────
  Widget _gradientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B0000), Color(0xFFB01010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: _headerContent(),
    );
  }

  // ── Konten header (dipakai di gambar & gradient) ─────────────
  Widget _headerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _targetBadge(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Text(
                discountBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          discountLabel,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        if (promoCode != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 13, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  promoCode!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _infoRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8B0000)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
        ),
      ],
    );
  }

  Widget _syaratItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4, height: 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF8B0000),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }
}