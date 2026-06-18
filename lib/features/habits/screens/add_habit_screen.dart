import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/habit.dart';
import '../controller/habit_controller.dart';

/// Create or edit a habit. Pass an existing [habit] to edit it; otherwise a
/// new one is created. Includes an optional AI suggestion helper for new habits.
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key, this.habit});

  final Habit? habit;

  bool get isEditing => habit != null;

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.habit?.title ?? '');

  /// Zero-setup starter habits shown as tappable chips (no API needed).
  static const List<({String emoji, String title})> _starters = [
    (emoji: '💧', title: 'Drink water'),
    (emoji: '🏃', title: 'Walk 20 min'),
    (emoji: '📚', title: 'Read 10 pages'),
    (emoji: '🧘', title: 'Meditate'),
    (emoji: '😴', title: 'Sleep by 11pm'),
  ];

  late String _emoji = widget.habit?.emoji ?? kHabitEmojis.first;
  late Color _color =
      widget.habit != null ? Color(widget.habit!.colorValue) : kHabitColors.first;
  bool _loadingAi = false;
  List<HabitSuggestion> _suggestions = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions() async {
    final goal = _titleController.text.trim();
    if (goal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a goal first, e.g. "get fit"')),
      );
      return;
    }
    setState(() => _loadingAi = true);
    final ai = AiService(apiKey: context.read<SettingsController>().claudeApiKey);
    final result = await ai.suggestHabits(goal);
    if (!mounted) return;
    setState(() {
      _suggestions = result;
      _loadingAi = false;
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your habit a name first.')),
      );
      return;
    }
    final controller = context.read<HabitController>();
    if (widget.isEditing) {
      controller.updateHabit(widget.habit!.copyWith(
        title: title,
        emoji: _emoji,
        colorValue: _color.toARGB32(),
      ));
    } else {
      controller.addHabit(
        title: title,
        emoji: _emoji,
        colorValue: _color.toARGB32(),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasAi = context.watch<SettingsController>().hasAiKey;
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit habit' : 'New habit')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Habit name or goal',
              hintText: "e.g. Drink water, or 'get fit'",
            ),
          ),
          const SizedBox(height: 28),
          const _FieldLabel('ICON'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in kHabitEmojis)
                _SelectableCircle(
                  selected: _emoji == e,
                  accent: _color,
                  onTap: () => setState(() => _emoji = e),
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
            ],
          ),
          const SizedBox(height: 28),
          const _FieldLabel('COLOR'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              for (final c in kHabitColors)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == c ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: _color == c
                          ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 10)]
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          if (!widget.isEditing) ...[
            const SizedBox(height: 28),
            const _FieldLabel('POPULAR HABITS'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _starters)
                  _StarterChip(
                    emoji: s.emoji,
                    title: s.title,
                    onTap: () => setState(() {
                      _titleController.text = s.title;
                      _emoji = s.emoji;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadingAi ? null : _fetchSuggestions,
              icon: _loadingAi
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text('Suggest habits with AI'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasAi ? Icons.bolt_rounded : Icons.cloud_off_rounded,
                  size: 14,
                  color: hasAi ? AppColors.primary : context.palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasAi
                        ? 'Powered by Claude — personalized to your goal.'
                        : 'Offline suggestions. Add a Claude API key in Profile → AI Suggestions for smarter results.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final s in _suggestions) _SuggestionTile(
                suggestion: s,
                onAdd: () => setState(() {
                  _titleController.text = s.title;
                  _emoji = s.emoji;
                }),
              ),
            ],
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: Text(widget.isEditing ? 'Save changes' : 'Save habit'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.palette.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _SelectableCircle extends StatelessWidget {
  const _SelectableCircle({
    required this.selected,
    required this.accent,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? accent.withValues(alpha: 0.22) : context.palette.surfaceHigh,
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.palette.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onAdd});

  final HabitSuggestion suggestion;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: [
          Text(suggestion.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                if (suggestion.reason.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(suggestion.reason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.palette.textSecondary,
                          )),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
