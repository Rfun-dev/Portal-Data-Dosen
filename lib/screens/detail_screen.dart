import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dosen.dart';
import '../utils/dosen_colors.dart';

class DetailScreen extends StatelessWidget {
  final Dosen dosen;

  const DetailScreen({super.key, required this.dosen});

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('$label disalin ke clipboard'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = dosenAvatarColor(dosen.nama);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible profile header ───────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: avatarColor,
            foregroundColor: Colors.white,
            title: Text(
              dosen.nama,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _ProfileHeader(dosen: dosen, color: avatarColor),
            ),
          ),

          // ── Action buttons ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _ActionRow(dosen: dosen, onCopy: _copy),
            ),
          ),

          // ── Info card ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              child: _InfoCard(dosen: dosen, onCopy: _copy),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Dosen dosen;
  final Color color;

  const _ProfileHeader({required this.dosen, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.25)!],
            ),
          ),
        ),
        // Decorative circles
        Positioned(
          right: -40,
          top: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          left: -20,
          bottom: 40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Profile content
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: Text(
                    dosen.nama[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  dosen.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  '@${dosen.username}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_rounded,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 5),
                      Text(
                        dosen.instansi,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action Row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final Dosen dosen;
  final void Function(BuildContext, String, String) onCopy;

  const _ActionRow({required this.dosen, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionBtn(
          icon: Icons.email_rounded,
          label: 'Email',
          onTap: () => onCopy(context, dosen.email, 'Email'),
        ),
        const SizedBox(width: 10),
        _ActionBtn(
          icon: Icons.phone_rounded,
          label: 'Telepon',
          onTap: () => onCopy(context, dosen.telepon, 'Nomor telepon'),
        ),
        const SizedBox(width: 10),
        _ActionBtn(
          icon: Icons.language_rounded,
          label: 'Website',
          onTap: () => onCopy(context, dosen.website, 'Website'),
        ),
        const SizedBox(width: 10),
        _ActionBtn(
          icon: Icons.share_rounded,
          label: 'Bagikan',
          onTap: () => onCopy(
            context,
            'Nama: ${dosen.nama}\nEmail: ${dosen.email}\nTelepon: ${dosen.telepon}\nWebsite: ${dosen.website}\nInstansi: ${dosen.instansi}',
            'Info dosen',
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: cs.onPrimaryContainer, size: 22),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Dosen dosen;
  final void Function(BuildContext, String, String) onCopy;

  const _InfoCard({required this.dosen, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _Tile(
            icon: Icons.tag_rounded,
            label: 'ID Dosen',
            value: dosen.id.toString(),
            onCopy: () => onCopy(context, dosen.id.toString(), 'ID Dosen'),
          ),
          const _Divider(),
          _Tile(
            icon: Icons.person_outline_rounded,
            label: 'Nama Lengkap',
            value: dosen.nama,
            onCopy: () => onCopy(context, dosen.nama, 'Nama'),
          ),
          const _Divider(),
          _Tile(
            icon: Icons.alternate_email_rounded,
            label: 'Username',
            value: '@${dosen.username}',
            onCopy: () => onCopy(context, dosen.username, 'Username'),
          ),
          const _Divider(),
          _Tile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: dosen.email,
            onCopy: () => onCopy(context, dosen.email, 'Email'),
          ),
          const _Divider(),
          _Tile(
            icon: Icons.phone_outlined,
            label: 'Nomor Telepon',
            value: dosen.telepon,
            onCopy: () => onCopy(context, dosen.telepon, 'Nomor telepon'),
          ),
          const _Divider(),
          _Tile(
            icon: Icons.language_outlined,
            label: 'Website',
            value: dosen.website,
            onCopy: () => onCopy(context, dosen.website, 'Website'),
          ),
          const _Divider(),
          _Tile(
            icon: Icons.business_outlined,
            label: 'Instansi / Perusahaan',
            value: dosen.instansi,
            onCopy: () => onCopy(context, dosen.instansi, 'Instansi'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: cs.primaryContainer,
        child: Icon(icon, size: 17, color: cs.onPrimaryContainer),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
        onPressed: onCopy,
        tooltip: 'Salin',
      ),
      dense: true,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, endIndent: 16);
}
