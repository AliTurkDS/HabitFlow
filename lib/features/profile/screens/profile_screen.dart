import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../core/utils/date_utils.dart';
import '../../habits/controller/habit_controller.dart';

/// Profile: identity, lifetime stats, and app preferences (theme, name, about).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final controller = context.watch<HabitController>();
    final habits = controller.habits;

    final totalCompletions =
        habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    final bestStreak = habits.isEmpty
        ? 0
        : habits
            .map((h) => StreakCalculator.longest(h.completedDates))
            .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Row(
            children: [
              const AppMark(size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.palette.textSecondary,
                            )),
                    Text(
                      settings.displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editName(context, settings),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: StatCard(value: '${habits.length}', label: 'Habits')),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: '$totalCompletions', label: 'Total done')),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '$bestStreak',
                  label: 'Best streak',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.flame,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _ThemeSelector(
            mode: settings.themeMode,
            onChanged: settings.setThemeMode,
          ),
          const SizedBox(height: 28),
          Text('AI Suggestions', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _Tile(
            icon: settings.hasAiKey
                ? Icons.auto_awesome_rounded
                : Icons.auto_awesome_outlined,
            iconColor: settings.hasAiKey ? AppColors.primary : context.palette.textSecondary,
            title: settings.hasAiKey ? 'Claude connected' : 'Connect Claude AI',
            subtitle: settings.hasAiKey
                ? 'Personalized habit suggestions are on'
                : 'Add an API key for smarter suggestions',
            onTap: () => _editApiKey(context, settings),
          ),
          const SizedBox(height: 28),
          Text('About', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.info_outline_rounded,
            title: 'About ${AppConstants.appName}',
            subtitle: 'Build habits, keep streaks, grow.',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: '1.0.0',
              applicationLegalese: 'Build · Streak · Grow',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, SettingsController settings) async {
    final controller = TextEditingController(text: settings.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null) settings.setDisplayName(name);
  }

  Future<void> _editApiKey(
      BuildContext context, SettingsController settings) async {
    final controller = TextEditingController(text: settings.claudeApiKey);
    var obscure = true;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Claude API key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your Anthropic API key to power AI habit suggestions. '
                "It's stored only on this device.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.palette.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'sk-ant-...',
                  suffixIcon: IconButton(
                    icon: Icon(obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setLocal(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (settings.hasAiKey)
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Clear', style: TextStyle(color: AppColors.danger)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return; // cancelled
    await settings.setClaudeApiKey(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.trim().isEmpty
              ? 'API key cleared — using offline suggestions.'
              : 'Claude connected. AI suggestions enabled.'),
        ),
      );
    }
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('System')),
          ButtonSegment(value: ThemeMode.light, label: Text('Light')),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
        ],
        selected: {mode},
        showSelectedIcon: false,
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.palette.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.palette.textSecondary,
                            )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
