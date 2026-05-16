import 'package:flutter/material.dart';
import '../models/dosen.dart';
import '../utils/dosen_colors.dart';

class DosenCard extends StatefulWidget {
  final Dosen dosen;
  final int index;
  final VoidCallback onTap;

  const DosenCard({
    super.key,
    required this.dosen,
    required this.index,
    required this.onTap,
  });

  @override
  State<DosenCard> createState() => _DosenCardState();
}

class _DosenCardState extends State<DosenCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _opacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    final delay = (widget.index * 55).clamp(0, 320);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = dosenAvatarColor(widget.dosen.nama);
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            splashColor: color.withValues(alpha: 0.08),
            highlightColor: color.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.dosen.nama[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.dosen.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '#${widget.dosen.id}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        _infoRow(Icons.email_outlined, widget.dosen.email),
                        const SizedBox(height: 3),
                        _infoRow(Icons.phone_outlined, widget.dosen.telepon),
                        const SizedBox(height: 3),
                        _infoRow(Icons.language_outlined, widget.dosen.website),
                        const SizedBox(height: 8),
                        // Instansi chip
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 12,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.dosen.instansi,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
