import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/widgets/glass_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Guide')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IntroCard(),
                SizedBox(height: 18),
                _GuideGrid(),
                SizedBox(height: 18),
                _SupportedFilesCard(),
                SizedBox(height: 18),
                _PrivacyCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.electricBlue.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(17),
                  border:
                      Border.all(color: AppTheme.cyberCyan.withOpacity(0.26)),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppTheme.cyberCyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Using TrustLayer',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'TrustLayer checks whether content looks AI-generated or real. Upload or enter content, run a scan, then review the verdict, confidence score, and diagnostic metrics.',
            style: _bodyStyle,
          ),
        ],
      ),
    );
  }
}

class _GuideGrid extends StatelessWidget {
  const _GuideGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        const cards = [
          _GuideCard(
            title: 'Image Detection',
            icon: Icons.image_search_outlined,
            color: AppTheme.electricBlue,
            points: [
              'Upload a JPG, JPEG, or PNG image.',
              'The app resizes it and extracts visual clues such as color patterns, edges, texture, and sharpness.',
              'A trained model compares those clues with real and AI image examples.',
            ],
          ),
          _GuideCard(
            title: 'Text Detection',
            icon: Icons.text_snippet_outlined,
            color: AppTheme.cyberCyan,
            points: [
              'Paste a text sample into the text detector.',
              'The app studies writing patterns such as word usage and sentence structure.',
              'The model estimates whether the writing style looks human-written or AI-generated.',
            ],
          ),
          _GuideCard(
            title: 'Voice Detection',
            icon: Icons.keyboard_voice_outlined,
            color: AppTheme.successGreen,
            points: [
              'Upload a supported audio file.',
              'The app extracts sound features such as frequency and voice texture patterns.',
              'The model checks whether the audio resembles natural speech or synthetic voice generation.',
            ],
          ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                Expanded(child: cards[index]),
                if (index != cards.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              cards[index],
              if (index != cards.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.points,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.28)),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final point in points) _GuidePoint(text: point),
        ],
      ),
    );
  }
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.cyberCyan,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }
}

class _SupportedFilesCard extends StatelessWidget {
  const _SupportedFilesCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Supported File Types',
            icon: Icons.folder_open_outlined,
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FileChip(label: 'Image: PNG'),
              _FileChip(label: 'Image: JPG'),
              _FileChip(label: 'Image: JPEG'),
              _FileChip(label: 'Voice: WAV'),
              _FileChip(label: 'Voice: MP3'),
              _FileChip(label: 'Voice: OGG'),
              _FileChip(label: 'Voice: M4A'),
              _FileChip(label: 'Text: typed/pasted input'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Privacy Note',
            icon: Icons.lock_outline,
          ),
          SizedBox(height: 12),
          Text(
            'TrustLayer sends your selected content to the backend only when you run a scan. Uploaded files are used for analysis, and the app stores scan history such as filename/summary, verdict, confidence, and metrics. Avoid uploading private or sensitive content unless you trust the local project environment.',
            style: _bodyStyle,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _FileChip extends StatelessWidget {
  const _FileChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised.withOpacity(0.64),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppTheme.outlineBlue.withOpacity(0.72)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textMain,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  color: AppTheme.textMuted,
  fontSize: 14,
  height: 1.45,
);
