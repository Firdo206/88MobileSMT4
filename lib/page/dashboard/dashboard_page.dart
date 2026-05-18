import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../booking/schedule_page.dart';
import '../promo/promo_list.dart';
import '../armada/armada_page.dart';
import '../../services/promo_service.dart';
import '../../models/promo_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final originController = TextEditingController();
  final destinationController = TextEditingController();

  DateTime? selectedDate;
  int _activeMenu = 0;

  bool _isRoundTrip = false;
  DateTime? returnDate;

  List<Promo> promoList = [];
  bool isLoading = true;

  // ── Carousel ─────────────────────────────────────────────
  PageController _promoPageController = PageController(viewportFraction: 0.85);
  int _currentPromoIndex = 0;
  Timer? _promoTimer;
  // ─────────────────────────────────────────────────────────

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    loadPromo();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoPageController.dispose();
    _fadeController.dispose();
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  void loadPromo() async {
    try {
      final data = await PromoService.getPromo();
      if (!mounted) return;
      setState(() {
        promoList = data;
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startPromoAutoScroll();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _startPromoAutoScroll() {
    if (promoList.length <= 1) return;
    _promoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPromoIndex + 1) % promoList.length;
      _promoPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B0000),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        if (returnDate != null && returnDate!.isBefore(picked)) {
          returnDate = null;
        }
      });
    }
  }

  Future<void> pickReturnDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null
          ? selectedDate!.add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: selectedDate != null
          ? selectedDate!.add(const Duration(days: 1))
          : DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B0000),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => returnDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _onTapPromoCard(Promo promo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PromoListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildMenuTabs(),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  title: "Diskon Eksklusif",
                  subtitle: "Lihat semua",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PromoListPage()),
                  ),
                ),
                const SizedBox(height: 14),
                _buildPromoSection(),
                const SizedBox(height: 32),
                _buildInfoBanner(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6B0000),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang 👋",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Mau ke mana hari ini?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSearchCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B0000).withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _tripTypeTab(
                  label: "Sekali Jalan",
                  active: !_isRoundTrip,
                  onTap: () => setState(() {
                    _isRoundTrip = false;
                    returnDate = null;
                  }),
                ),
                _tripTypeTab(
                  label: "Pulang Pergi",
                  active: _isRoundTrip,
                  onTap: () => setState(() => _isRoundTrip = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: originController,
            label: "Kota Asal",
            icon: Icons.radio_button_checked_rounded,
            iconColor: const Color(0xFF8B0000),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFEEEEEE)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0D8D3)),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                    color: Color(0xFF8B0000),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFEEEEEE)),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          _buildInputField(
            controller: destinationController,
            label: "Kota Tujuan",
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFCC3333),
          ),
          const SizedBox(height: 14),
          _buildDateField(
            label: "Tanggal Berangkat",
            date: selectedDate,
            onTap: pickDate,
          ),
          if (_isRoundTrip) ...[
            const SizedBox(height: 8),
            _buildDateField(
              label: "Tanggal Pulang",
              date: returnDate,
              onTap: pickReturnDate,
              isDashed: true,
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SchedulePage(
                  origin: originController.text,
                  destination: destinationController.text,
                  date: selectedDate,
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFCC2222)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Cari Jadwal",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TRIP TYPE TAB ───────────────────────────────────────────────────────────

  Widget _tripTypeTab({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8B0000) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 13,
                color: active ? Colors.white : Colors.grey[500],
              ),
              const SizedBox(width: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DATE FIELD ──────────────────────────────────────────────────────────────

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool isDashed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null
                ? const Color(0xFF8B0000).withOpacity(0.4)
                : isDashed
                ? const Color(0xFF8B0000).withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDashed
                    ? Icons.event_available_rounded
                    : Icons.calendar_month_rounded,
                color: const Color(0xFF8B0000),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? "Pilih tanggal" : _formatDate(date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: date == null
                          ? Colors.grey[400]
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFAAAAAA),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ),
      ],
    );
  }

  // ─── MENU TABS ───────────────────────────────────────────────────────────────

  Widget _buildMenuTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _menuTab(
              index: 0,
              label: "Cari Tiket",
              icon: Icons.confirmation_num_outlined,
            ),
            _menuTab(
              index: 1,
              label: "Sewa Bus",
              icon: Icons.directions_bus_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArmadaPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTab({
    required int index,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final bool active = _activeMenu == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeMenu = index);
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8B0000) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: active ? Colors.white : const Color(0xFF999999),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF888888),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SECTION HEADER ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Lihat semua →",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B0000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROMO SECTION ───────────────────────────────────────────────────────────

  Widget _buildPromoSection() {
    if (isLoading) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8B0000),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (promoList.isEmpty) {
      return Container(
        height: 190,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEDE8E4)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: Color(0xFF8B0000),
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Belum ada diskon aktif",
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Pantau terus untuk penawaran terbaik",
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── PageView carousel ────────────────────────────────
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _promoPageController,
            itemCount: promoList.length,
            onPageChanged: (index) {
              setState(() => _currentPromoIndex = index);
            },
            itemBuilder: (context, index) {
              final promo = promoList[index];
              return AnimatedScale(
                scale: _currentPromoIndex == index ? 1.0 : 0.93,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: _buildPromoCard(promo: promo),
              );
            },
          ),
        ),

        // ── Dot indicator ────────────────────────────────────
        if (promoList.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(promoList.length, (index) {
              final isActive = index == _currentPromoIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF8B0000)
                      : const Color(0xFF8B0000).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildPromoCard({required Promo promo}) {
    final List<List<Color>> gradients = [
      [const Color(0xFF8B0000), const Color(0xFFCC2222)],
      [const Color(0xFF6B0000), const Color(0xFFAA1111)],
      [const Color(0xFF9B1B1B), const Color(0xFFD93333)],
    ];
    final idx = promoList.indexOf(promo) % gradients.length;
    final grad = gradients[idx];

    final targetLabel = switch (promo.targetType) {
      'ticket' => 'Tiket Bus',
      'rental' => 'Sewa Bus',
      'tour' => 'Wisata',
      _ => 'Semua',
    };

    return GestureDetector(
      onTap: () => _onTapPromoCard(promo),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: grad[0].withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -24,
              right: -24,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          targetLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.local_offer_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Hemat\n",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 10,
                          height: 0.8,
                        ),
                      ),
                      Text(
                        promo.discountLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              promo.quota > 0
                                  ? '${promo.sisaKuota} sisa'
                                  : 'Unlimited',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (promo.promoCode != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              promo.promoCode!,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── INFO BANNER ─────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEDE8E4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF8B0000),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Diskon Eksklusif",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "Hanya tersedia di hari-hari tertentu dan untuk pengguna terpilih.",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF888888),
                      height: 1.5,
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
}
