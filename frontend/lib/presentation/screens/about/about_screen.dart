import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Project')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroCard(),
                SizedBox(height: 18),
                _SectionCard(
                  title: 'Project Overview',
                  icon: Icons.shield_outlined,
                  child: Text(
                    'TrustLayer is a multi-modal AI content detection app built to help users validate text, images, and voice clips. It combines a Flutter frontend with a Flask backend and lightweight machine learning models suitable for semester project execution.',
                    style: _bodyStyle,
                  ),
                ),
                SizedBox(height: 18),
                _SectionCard(
                  title: 'Technologies Used',
                  icon: Icons.layers_outlined,
                  child: _ResponsiveGrid(
                    items: [
                      _InfoTile('Flutter', Icons.phone_android_outlined),
                      _InfoTile('Material 3', Icons.palette_outlined),
                      _InfoTile('Provider', Icons.sync_alt_outlined),
                      _InfoTile('Flask API', Icons.api_outlined),
                      _InfoTile('OpenCV', Icons.image_search_outlined),
                      _InfoTile('Scikit-learn', Icons.psychology_outlined),
                      _InfoTile('Librosa', Icons.graphic_eq_outlined),
                      _InfoTile('SQLite', Icons.storage_outlined),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                _SectionCard(
                  title: 'AI Detection Modules',
                  icon: Icons.security_outlined,
                  child: Column(
                    children: [
                      _ModuleRow(
                        title: 'Image Detector',
                        description:
                            'Uses OpenCV handcrafted features with machine learning to classify AI-generated and real images.',
                        icon: Icons.image_outlined,
                        color: AppTheme.electricBlue,
                      ),
                      _ModuleRow(
                        title: 'Text Detector',
                        description:
                            'Uses TF-IDF based text features to identify AI-written content patterns.',
                        icon: Icons.text_snippet_outlined,
                        color: AppTheme.cyberCyan,
                      ),
                      _ModuleRow(
                        title: 'Voice Detector',
                        description:
                            'Uses acoustic features such as MFCCs to detect synthetic voice characteristics.',
                        icon: Icons.keyboard_voice_outlined,
                        color: AppTheme.successGreen,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                _SectionCard(
                  title: 'Developer / Student Info',
                  icon: Icons.school_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailLine(label: 'Project', value: 'TrustLayer'),
                      _DetailLine(label: 'Type', value: 'Semester Project'),
                      _DetailLine(
                        label: 'Focus',
                        value: 'AI-generated content detection',
                      ),
                      _DetailLine(
                        label: 'Goal',
                        value:
                            'Build a practical, lightweight, CPU-friendly detection system with a modern mobile UI.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                _SectionCard(
                  title: 'Future Enhancements',
                  icon: Icons.rocket_launch_outlined,
                  child: Column(
                    children: [
                      _FutureItem('Add profile and account settings screens.'),
                      _FutureItem(
                          'Improve model accuracy with larger datasets.'),
                      _FutureItem('Add detailed explainability for each scan.'),
                      _FutureItem('Support PDF and video detection modules.'),
                      _FutureItem('Add cloud deployment and admin analytics.'),
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
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.electricBlue.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.cyberCyan.withOpacity(0.26)),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppTheme.cyberCyan,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TrustLayer',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A dark, modern AI verification system for text, image, and voice content.',
                  style: _bodyStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.cyberCyan, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.items});

  final List<_InfoTile> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.45 : 1.75,
          ),
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.label, this.icon);

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised.withOpacity(0.56),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineBlue.withOpacity(0.7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.cyberCyan, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: _bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.cyberCyan,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: Text(value, style: _bodyStyle)),
        ],
      ),
    );
  }
}

class _FutureItem extends StatelessWidget {
  const _FutureItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.successGreen,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  color: AppTheme.textMuted,
  fontSize: 14,
  height: 1.45,
);
