import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/promo_card.dart';
import '../../../services/promo_service.dart';
import '../../models/promo_model.dart';

class PromoListPage extends StatefulWidget {
  const PromoListPage({super.key});

  @override
  State<PromoListPage> createState() => _PromoListPageState();
}

class _PromoListPageState extends State<PromoListPage> {
  List<Promo> promoList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPromo();
  }

  Future<void> loadPromo() async {
    setState(() => isLoading = true);
    try {
      final data = await PromoService.getPromo();
        print("DATA: $data");
      if (!mounted) return;
      setState(() {
        promoList = data;
        isLoading = false;
      });
    } catch (e) {
       print("ERROR DETAIL: $e"); 
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat promo: $e')),
      );
    }
  }

  void _onTapPromo(Promo promo) async {
    if (promo.targetType == null || promo.targetType!.isEmpty) {
      _showPromoInfoSheet(promo);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B0000)),
      ),
    );

    try {
      final detail = await PromoService.getPromoDetail(promo.id);
      if (!mounted) return;
      Navigator.pop(context);
      _navigateByTarget(promo: promo, detail: detail);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail: $e')),
      );
    }
  }

  void _navigateByTarget({required Promo promo, required Promo detail}) {
    switch (promo.targetType) {
      case 'tour':
        Navigator.pushNamed(context, '/paket-wisata', arguments: {'promo': promo});
        break;
      case 'ticket':
        Navigator.pushNamed(context, '/schedule', arguments: {'promo': promo});
        break;
      case 'rental':
        Navigator.pushNamed(context, '/armada', arguments: {'promo': promo});
        break;
      default:
        _showPromoInfoSheet(promo);
    }
  }

  void _showPromoInfoSheet(Promo promo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PromoInfoSheet(promo: promo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B0000),
        title: const Text(
          "Diskon Eksklusif",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B0000), strokeWidth: 2.5),
      );
    }

    if (promoList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.local_offer_outlined,
                  color: Color(0xFF8B0000), size: 32),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum ada diskon aktif',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pantau terus untuk penawaran terbaik',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF8B0000),
      onRefresh: loadPromo,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: promoList.length,
        itemBuilder: (context, index) {
          final promo = promoList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PromoCard(
              title:          promo.title,
              description:    promo.description,
              discountType:   promo.discountType,
              discountValue:  promo.discountValue,
              minTransaction: promo.minTransaction,
              maxDiscount:    promo.maxDiscount,
              startDate:      promo.startDate,   // ← String? langsung
              endDate:        promo.endDate,     // ← String? langsung
              quota:          promo.quota,
              usedQuota:      promo.usedQuota,
              isActive:       promo.bisaDipakai,
              promoCode:      promo.promoCode,
              targetType:     promo.targetType,
              onTap: () => _onTapPromo(promo),
            ),
          );
        },
      ),
    );
  }
}

// ─── BOTTOM SHEET INFO PROMO ─────────────────────────────────────────────────

class _PromoInfoSheet extends StatefulWidget {
  final Promo promo;
  const _PromoInfoSheet({required this.promo});

  @override
  State<_PromoInfoSheet> createState() => _PromoInfoSheetState();
}

class _PromoInfoSheetState extends State<_PromoInfoSheet> {
  bool _copied = false;

  Future<void> _salinKode() async {
    await Clipboard.setData(ClipboardData(text: widget.promo.promoCode!));
    setState(() => _copied = true);

    // Reset icon setelah 2 detik
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

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

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Handle bar ──────────────────────────────────────────
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header: gradient banner ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B0000), Color(0xFFCC2222)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target type chip
                if (promo.targetType != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _targetLabel(promo.targetType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                // Angka diskon
                Text(
                  'Hemat ${promo.discountLabel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),

                // Judul
                Text(
                  promo.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Kotak kode promo (kalau ada) ─────────────────────────
          if (promo.promoCode != null) ...[
            const Text(
              'Kode Promo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _salinKode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: _copied
                      ? const Color(0xFF8B0000).withOpacity(0.06)
                      : const Color(0xFFF7F3F0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _copied
                        ? const Color(0xFF8B0000).withOpacity(0.4)
                        : const Color(0xFFE0D8D3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Kode
                    Expanded(
                      child: Text(
                        promo.promoCode!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8B0000),
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    // Tombol salin / centang
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _copied
                          ? const Icon(
                              Icons.check_circle_rounded,
                              key: ValueKey('check'),
                              color: Color(0xFF8B0000),
                              size: 22,
                            )
                          : Row(
                              key: const ValueKey('copy'),
                              children: [
                                const Icon(Icons.copy_rounded,
                                    color: Color(0xFF8B0000), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Salin',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF8B0000).withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Hint tap to copy
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _copied ? '✓ Kode berhasil disalin!' : 'Ketuk untuk menyalin kode',
                style: TextStyle(
                  fontSize: 11,
                  color: _copied ? const Color(0xFF8B0000) : Colors.grey[500],
                  fontWeight: _copied ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Info detail ──────────────────────────────────────────
          if (promo.description != null) ...[
            Text(
              promo.description!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 16),
          ],

          const Divider(height: 1),
          const SizedBox(height: 16),

          if (promo.minTransaction != null && promo.minTransaction! > 0)
            _infoRow(Icons.payments_outlined, 'Min. transaksi',
                'Rp ${promo.minTransaction!.toInt()}'),

          if (promo.maxDiscount != null && promo.maxDiscount! > 0 && promo.discountType == 'percentage')
            _infoRow(Icons.info_outline_rounded, 'Maks. diskon',
                'Rp ${promo.maxDiscount!.toInt()}'),

          if (promo.endDate != null)
            _infoRow(Icons.calendar_today_outlined, 'Berlaku hingga',
                _formatDateStr(promo.endDate)),

          _infoRow(
            Icons.people_outline,
            'Sisa kuota',
            promo.quota > 0 ? '${promo.sisaKuota} tersisa' : 'Tidak terbatas',
          ),

          const SizedBox(height: 20),

          // ── Tombol CTA ───────────────────────────────────────────
          if (promo.promoCode != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _copied
                      ? Colors.green
                      : const Color(0xFF8B0000),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _salinKode,
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  color: Colors.white, size: 18,
                ),
                label: Text(
                  _copied ? 'Tersalin!' : 'Salin Kode Promo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _targetLabel(String? type) {
    switch (type) {
      case 'ticket':  return 'Tiket Bus';
      case 'rental':  return 'Sewa Bus';
      case 'tour':    return 'Paket Wisata';
      default:        return 'Semua Layanan';
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000).withOpacity(0.07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: const Color(0xFF8B0000)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}