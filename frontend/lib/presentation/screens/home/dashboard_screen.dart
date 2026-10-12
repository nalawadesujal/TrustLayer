import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/providers/history_provider.dart';
import 'package:frontend/presentation/widgets/app_drawer.dart';
import 'package:frontend/presentation/widgets/glass_card.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final historyProvider = context.watch<HistoryProvider>();
    final username = authProvider.username;
    final logs = historyProvider.logs;
    final totalScans = logs.length;
    final aiDetected = logs.where((log) => log.isAi).length;
    final realContent = logs
        .where((log) => !log.isAi && log.verdict.toLowerCase() != 'uncertain')
        .length;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('TrustLayer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppTheme.errorRed),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FadeIn(
                  controller: _controller,
                  delay: 0,
                  child: _Header(username: username),
                ),
                const SizedBox(height: 20),
                _FadeIn(
                  controller: _controller,
                  delay: 0.12,
                  child: _StatsSection(
                    totalScans: totalScans,
                    aiDetected: aiDetected,
                    realContent: realContent,
                    isLoading: historyProvider.isLoading,
                  ),
                ),
                const SizedBox(height: 26),
                _FadeIn(
                  controller: _controller,
                  delay: 0.22,
                  child: const _SectionTitle(
                    label: 'Detector Modules',
                    icon: Icons.security_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                _DetectorGrid(controller: _controller),
                const SizedBox(height: 24),
                _FadeIn(
                  controller: _controller,
                  delay: 0.62,
                  child: _HistoryCard(
                    onTap: () => Navigator.of(context).pushNamed('/history'),
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

class _Header extends StatelessWidget {
  const _Header({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.electricBlue.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cyberCyan.withOpacity(0.24)),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppTheme.cyberCyan,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $username',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Validate image, text, and voice content from one secure dashboard.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.totalScans,
    required this.aiDetected,
    required this.realContent,
    required this.isLoading,
  });

  final int totalScans;
  final int aiDetected;
  final int realContent;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final stats = [
            _StatData(
              label: 'Total scans',
              value: totalScans,
              icon: Icons.radar_outlined,
              color: AppTheme.electricBlue,
            ),
            _StatData(
              label: 'AI detected',
              value: aiDetected,
              icon: Icons.auto_awesome_outlined,
              color: AppTheme.errorRed,
            ),
            _StatData(
              label: 'Real content',
              value: realContent,
              icon: Icons.check_circle_outline,
              color: AppTheme.successGreen,
            ),
          ];

          if (isCompact) {
            return Column(
              children: [
                for (var index = 0; index < stats.length; index++) ...[
                  _StatTile(data: stats[index], isLoading: isLoading),
                  if (index != stats.length - 1)
                    Divider(color: AppTheme.outlineBlue.withOpacity(0.7)),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var index = 0; index < stats.length; index++) ...[
                Expanded(
                  child: _StatTile(data: stats[index], isLoading: isLoading),
                ),
                if (index != stats.length - 1)
                  Container(
                    width: 1,
                    height: 54,
                    color: AppTheme.outlineBlue.withOpacity(0.7),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data, required this.isLoading});

  final _StatData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.cyberCyan,
                          ),
                        )
                      : Text(
                          '${data.value}',
                          key: ValueKey(data.value),
                          style: const TextStyle(
                            color: AppTheme.textMain,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectorGrid extends StatelessWidget {
  const _DetectorGrid({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final detectors = [
      _DetectorData(
        title: 'Image Detector',
        description:
            'Scan photos for generated-image patterns and visual artifacts.',
        icon: Icons.image_search_outlined,
        color: AppTheme.electricBlue,
        onTap: () => Navigator.of(context).pushNamed('/detect/image'),
      ),
      _DetectorData(
        title: 'Text Detector',
        description:
            'Review articles, emails, and essays for AI-written signals.',
        icon: Icons.text_snippet_outlined,
        color: AppTheme.cyberCyan,
        onTap: () => Navigator.of(context).pushNamed('/detect/text'),
      ),
      _DetectorData(
        title: 'Voice Detector',
        description:
            'Analyze uploaded audio for synthetic speech characteristics.',
        icon: Icons.graphic_eq_outlined,
        color: AppTheme.successGreen,
        onTap: () => Navigator.of(context).pushNamed('/detect/voice'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < detectors.length; index++) ...[
                Expanded(
                  child: _FadeIn(
                    controller: controller,
                    delay: 0.3 + (index * 0.1),
                    child: _DetectorCard(data: detectors[index]),
                  ),
                ),
                if (index != detectors.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < detectors.length; index++) ...[
              _FadeIn(
                controller: controller,
                delay: 0.3 + (index * 0.1),
                child: _DetectorCard(data: detectors[index]),
              ),
              if (index != detectors.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

class _DetectorData {
  const _DetectorData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _DetectorCard extends StatefulWidget {
  const _DetectorCard({required this.data});

  final _DetectorData data;

  @override
  State<_DetectorCard> createState() => _DetectorCardState();
}

class _DetectorCardState extends State<_DetectorCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: widget.data.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: widget.data.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.data.color.withOpacity(0.25),
                      ),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.textMuted.withOpacity(0.85),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                widget.data.title,
                style: const TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.description,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.surfaceRaised.withOpacity(0.75),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.history_outlined,
                color: AppTheme.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detection History',
                    style: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Review previous validations and confidence scores.',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.cyberCyan, size: 18),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.cyberCyan,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({
    required this.controller,
    required this.delay,
    required this.child,
  });

  final AnimationController controller;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = delay.clamp(0.0, 0.85);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
