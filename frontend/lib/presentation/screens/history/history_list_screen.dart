import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/data/models/detection_model.dart';
import 'package:frontend/presentation/providers/history_provider.dart';
import 'package:frontend/presentation/widgets/glass_card.dart';
import 'package:frontend/presentation/widgets/result_badge.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen({super.key});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detection History')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: _buildBody(historyProvider),
        ),
      ),
    );
  }

  Widget _buildBody(HistoryProvider provider) {
    if (provider.errorMessage != null) {
      return _buildErrorState(provider);
    }

    if (provider.isLoading) {
      return const _HistoryShimmer();
    }

    final filteredLogs = _filteredLogs(provider.logs);

    return Column(
      children: [
        _SearchAndFilters(
          controller: _searchController,
          query: _query,
          activeFilter: _activeFilter,
          onQueryChanged: (value) => setState(() => _query = value),
          onFilterChanged: (value) => setState(() => _activeFilter = value),
        ),
        Expanded(
          child: provider.logs.isEmpty
              ? _buildEmptyState(
                  icon: Icons.history_toggle_off,
                  title: 'No Detection History',
                  message: 'Your analysis logs will appear here.',
                )
              : filteredLogs.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No Matching Logs',
                      message: 'Try a different keyword or category.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return _HistoryItem(log: log, provider: provider);
                      },
                    ),
        ),
      ],
    );
  }

  List<DetectionModel> _filteredLogs(List<DetectionModel> logs) {
    final normalizedQuery = _query.trim().toLowerCase();

    return logs.where((log) {
      final matchesFilter =
          _activeFilter == 'all' || log.modality.toLowerCase() == _activeFilter;
      final matchesQuery = normalizedQuery.isEmpty ||
          log.inputSummary.toLowerCase().contains(normalizedQuery) ||
          log.verdict.toLowerCase().contains(normalizedQuery) ||
          log.modality.toLowerCase().contains(normalizedQuery);

      return matchesFilter && matchesQuery;
    }).toList();
  }

  Widget _buildErrorState(HistoryProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => provider.fetchHistory(),
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.textMuted.withOpacity(0.55)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.query,
    required this.activeFilter,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final String query;
  final String activeFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: onQueryChanged,
              style: const TextStyle(color: AppTheme.textMain),
              cursorColor: AppTheme.cyberCyan,
              decoration: InputDecoration(
                hintText: 'Search history',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.clear();
                          onQueryChanged('');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    value: 'all',
                    icon: Icons.all_inclusive,
                    activeFilter: activeFilter,
                    onSelected: onFilterChanged,
                  ),
                  _CategoryChip(
                    label: 'Image',
                    value: 'image',
                    icon: Icons.image_outlined,
                    activeFilter: activeFilter,
                    onSelected: onFilterChanged,
                  ),
                  _CategoryChip(
                    label: 'Text',
                    value: 'text',
                    icon: Icons.text_snippet_outlined,
                    activeFilter: activeFilter,
                    onSelected: onFilterChanged,
                  ),
                  _CategoryChip(
                    label: 'Voice',
                    value: 'voice',
                    icon: Icons.keyboard_voice_outlined,
                    activeFilter: activeFilter,
                    onSelected: onFilterChanged,
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.activeFilter,
    required this.onSelected,
  });

  final String label;
  final String value;
  final IconData icon;
  final String activeFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isActive = activeFilter == value;
    final color = _colorForModality(value);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isActive,
        onSelected: (_) => onSelected(value),
        showCheckmark: false,
        avatar: Icon(icon, size: 17, color: isActive ? AppTheme.black : color),
        label: Text(label),
        labelStyle: TextStyle(
          color: isActive ? AppTheme.black : AppTheme.textMain,
          fontWeight: FontWeight.w700,
        ),
        selectedColor: color,
        backgroundColor: AppTheme.surfaceRaised.withOpacity(0.72),
        side: BorderSide(color: color.withOpacity(0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Color _colorForModality(String modality) {
    switch (modality) {
      case 'image':
        return AppTheme.electricBlue;
      case 'text':
        return AppTheme.cyberCyan;
      case 'voice':
        return AppTheme.successGreen;
      default:
        return AppTheme.textMuted;
    }
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.log, required this.provider});

  final DetectionModel log;
  final HistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    final meta = _modalityMeta(log.modality);
    final dateFormatted = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(log.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: Key(log.id.toString()),
        direction: DismissDirection.endToStart,
        background: _DeleteBackground(borderRadius: BorderRadius.circular(20)),
        confirmDismiss: (_) => _deleteLog(context),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            '/detection-details',
            arguments: log,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meta.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: meta.color.withOpacity(0.25)),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SmallCategoryChip(
                              label: meta.label, color: meta.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateFormatted,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        log.inputSummary,
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      ResultBadge(
                        type: ResultBadge.typeFromVerdict(log.verdict),
                        confidence: log.confidence,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _deleteLog(BuildContext context) async {
    final success = await provider.deleteHistoryItem(log.id);
    if (!context.mounted) return success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Record deleted successfully.' : 'Failed to delete record.',
        ),
        backgroundColor: success ? AppTheme.surfaceRaised : AppTheme.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );

    return success;
  }

  _ModalityMeta _modalityMeta(String modality) {
    switch (modality.toLowerCase()) {
      case 'text':
        return const _ModalityMeta(
          label: 'Text',
          icon: Icons.text_snippet_outlined,
          color: AppTheme.cyberCyan,
        );
      case 'image':
        return const _ModalityMeta(
          label: 'Image',
          icon: Icons.image_outlined,
          color: AppTheme.electricBlue,
        );
      case 'voice':
        return const _ModalityMeta(
          label: 'Voice',
          icon: Icons.keyboard_voice_outlined,
          color: AppTheme.successGreen,
        );
      default:
        return const _ModalityMeta(
          label: 'Other',
          icon: Icons.device_unknown_outlined,
          color: AppTheme.textMuted,
        );
    }
  }
}

class _SmallCategoryChip extends StatelessWidget {
  const _SmallCategoryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.9),
        borderRadius: borderRadius,
      ),
      child: const Icon(Icons.delete_outline, color: AppTheme.textMain),
    );
  }
}

class _ModalityMeta {
  const _ModalityMeta({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _HistoryShimmer extends StatefulWidget {
  const _HistoryShimmer();

  @override
  State<_HistoryShimmer> createState() => _HistoryShimmerState();
}

class _HistoryShimmerState extends State<_HistoryShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _ShimmerBlock(controller: _controller, height: 52),
              const SizedBox(height: 14),
              Row(
                children: [
                  _ShimmerBlock(controller: _controller, width: 74, height: 34),
                  const SizedBox(width: 8),
                  _ShimmerBlock(controller: _controller, width: 82, height: 34),
                  const SizedBox(width: 8),
                  _ShimmerBlock(controller: _controller, width: 76, height: 34),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < 5; index++) ...[
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ShimmerBlock(controller: _controller, width: 48, height: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBlock(
                        controller: _controller,
                        width: 140,
                        height: 18,
                      ),
                      const SizedBox(height: 10),
                      _ShimmerBlock(controller: _controller, height: 16),
                      const SizedBox(height: 10),
                      _ShimmerBlock(
                        controller: _controller,
                        width: 118,
                        height: 28,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.controller,
    this.width,
    required this.height,
  });

  final AnimationController controller;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final shift = controller.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment(-1 + shift * 2, 0),
              end: Alignment(shift * 2, 0),
              colors: [
                AppTheme.surfaceRaised.withOpacity(0.45),
                AppTheme.outlineBlue.withOpacity(0.55),
                AppTheme.surfaceRaised.withOpacity(0.45),
              ],
            ),
          ),
        );
      },
    );
  }
}
