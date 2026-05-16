import 'package:flutter/material.dart';
import '../models/dosen.dart';
import '../services/api_service.dart';
import '../widgets/dosen_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Dosen>> _futureDosen;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _futureDosen = ApiService.fetchDosen();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollController.offset > 280;
    if (show != _showScrollTop) setState(() => _showScrollTop = show);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _futureDosen = ApiService.fetchDosen();
      _selectedFilter = 'Semua';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  Future<void> _handlePullRefresh() async {
    final future = ApiService.fetchDosen();
    setState(() {
      _futureDosen = future;
      _selectedFilter = 'Semua';
    });
    try {
      await future;
    } catch (_) {}
  }

  List<Dosen> _filter(List<Dosen> list) {
    var result = list;
    if (_selectedFilter != 'Semua') {
      result = result.where((d) => d.nama.startsWith(_selectedFilter)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) =>
          d.nama.toLowerCase().contains(q) ||
          d.email.toLowerCase().contains(q) ||
          d.instansi.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  List<String> _alphabetChips(List<Dosen> list) {
    final letters = list.map((d) => d.nama[0].toUpperCase()).toSet().toList()..sort();
    return ['Semua', ...letters];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      floatingActionButton: IgnorePointer(
        ignoring: !_showScrollTop,
        child: AnimatedSlide(
          offset: _showScrollTop ? Offset.zero : const Offset(0, 1.5),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: _showScrollTop ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: FloatingActionButton.small(
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              ),
              tooltip: 'Kembali ke atas',
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Dosen>>(
        future: _futureDosen,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final allDosen = snapshot.data ?? [];
          final filtered = _filter(allDosen);
          final chips = _alphabetChips(allDosen);

          return RefreshIndicator(
            onRefresh: _handlePullRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Collapsible hero AppBar ──────────────────────────────
                SliverAppBar(
                  expandedHeight: 230,
                  pinned: true,
                  stretch: true,
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _refresh,
                      tooltip: 'Refresh Data',
                    ),
                    const SizedBox(width: 4),
                  ],
                  title: const Text(
                    'Portal Data Dosen',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    stretchModes: const [StretchMode.zoomBackground],
                    background: _HeroHeader(
                      isLoading: isLoading,
                      dosenCount: allDosen.length,
                    ),
                  ),
                ),

                // ── Sticky search bar ────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    controller: _searchController,
                    query: _searchQuery,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),

                // ── Alphabet filter chips ────────────────────────────────
                if (!isLoading && !snapshot.hasError && allDosen.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _FilterChipsRow(
                      chips: chips,
                      selected: _selectedFilter,
                      onSelect: (v) => setState(() => _selectedFilter = v),
                    ),
                  ),

                // ── Main content ─────────────────────────────────────────
                if (isLoading)
                  const SliverFillRemaining(child: _LoadingView())
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: _ErrorView(
                      message: snapshot.error.toString(),
                      onRetry: _refresh,
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyView(query: _searchQuery),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Text(
                        '${filtered.length} dosen ditemukan',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => DosenCard(
                          dosen: filtered[i],
                          index: i,
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(dosen: filtered[i]),
                            ),
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final bool isLoading;
  final int dosenCount;

  const _HeroHeader({required this.isLoading, required this.dosenCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Portal Data Dosen',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Direktori Akademik Kampus',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.people_rounded,
                        label: 'Total Dosen',
                        value: isLoading ? '—' : dosenCount.toString(),
                      ),
                      const SizedBox(width: 10),
                      const _StatChip(
                        icon: Icons.verified_rounded,
                        label: 'Status',
                        value: 'Aktif',
                      ),
                      const SizedBox(width: 10),
                      const _StatChip(
                        icon: Icons.calendar_today_rounded,
                        label: 'T.A.',
                        value: '2025/26',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  final List<String> chips;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterChipsRow({
    required this.chips,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: chips.length,
        itemBuilder: (_, i) => FilterChip(
          label: Text(chips[i]),
          selected: chips[i] == selected,
          onSelected: (_) => onSelect(chips[i]),
          showCheckmark: false,
          labelStyle: TextStyle(
            fontWeight: chips[i] == selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar Delegate (sticky) ─────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  _SearchBarDelegate({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      elevation: overlapsContent ? 3 : 0,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Cari nama, email, atau instansi...',
            hintStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: onClear,
                  )
                : null,
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate old) => old.query != query;
}

// ─── State Views ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat data dosen...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 80, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String query;

  const _EmptyView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Hasil',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            query.isNotEmpty
                ? 'Tidak ada dosen dengan kata kunci\n"$query"'
                : 'Tidak ada dosen pada filter ini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
