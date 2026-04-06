import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/app_color.dart';

class PromoCard extends StatelessWidget {
  final String title;
  final String discountType;
  final double discountValue;
  final DateTime startTime;
  final DateTime endTime;
  final int quota;
  final int usedQuota;
  final bool isActive;
  final VoidCallback? onTap;

  const PromoCard({
    super.key,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.startTime,
    required this.endTime,
    required this.quota,
    required this.usedQuota,
    required this.isActive,
    this.onTap,
  });

  String get discountLabel => discountType == 'fixed'
      ? 'Hemat Rp ${discountValue.toInt()}'
      : 'Hemat ${discountValue.toInt()}%';

  String get discountBadge => discountType == 'fixed'
      ? 'Rp ${discountValue.toInt()}'
      : '${discountValue.toInt()}%';

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  int get sisaKuota => quota - usedQuota;

  @override
  Widget build(BuildContext context) {
    return InkWell(                              // ← BERUBAH
      onTap: onTap,                              // ← BERUBAH
      borderRadius: BorderRadius.circular(20),   // ← BERUBAH
      child: Container(                          // ← BERUBAH
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP: gradient banner ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B0000), Color(0xFFCC2222)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          discountLabel,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      discountBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BOTTOM: info ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Periode
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: Color(0xFF8B0000)),
                      const SizedBox(width: 6),
                      Text(
                        'Berlaku: ${_formatDate(startTime)} – ${_formatDate(endTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Kuota
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 14, color: Color(0xFF8B0000)),
                      const SizedBox(width: 6),
                      Text(
                        'Sisa kuota: $sisaKuota dari $quota',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress bar kuota
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: quota > 0 ? usedQuota / quota : 0,
                            backgroundColor: const Color(0xFFEEE),
                            color: sisaKuota <= (quota * 0.2)
                                ? Colors.orange
                                : const Color(0xFF8B0000),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Status aktif / tidak
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 12,
                              color: isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isActive ? 'Aktif' : 'Tidak Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Tombol salin diskon label
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: discountBadge));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Info diskon disalin!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.copy_rounded,
                                size: 14, color: Color(0xFF8B0000)),
                            SizedBox(width: 4),
                            Text(
                              'Salin',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8B0000),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Syarat dinamis
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Syarat & Ketentuan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _syaratItem(
                            'Berlaku ${_formatDate(startTime)} s/d ${_formatDate(endTime)}'),
                        _syaratItem('Kuota terbatas ($quota pengguna)'),
                        _syaratItem(
                            'Diskon $discountLabel untuk ${_targetLabel()}'),
                        _syaratItem(
                            'Tidak dapat digabung dengan promo lain'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),    // ← tutup Container
    );      // ← tutup InkWell
  }

  String _targetLabel() {
    return 'pengguna terpilih';
  }

  Widget _syaratItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 11, color: Color(0xFF8B0000))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }
}