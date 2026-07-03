import 'package:flutter/material.dart';

import '../../../core/app_spacing.dart';
import '../../../core/app_strings.dart';
import '../../../core/disposable_controllers_mixin.dart';
import '../domain/person.dart';

/// Multi-select participant chips plus an inline "add new person" field —
/// so a new friend can join without a dedicated people-management screen.
class ParticipantSelector extends StatefulWidget {
  const ParticipantSelector({
    super.key,
    required this.people,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onAddPerson,
  });

  final List<Person> people;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final ValueChanged<String> onAddPerson;

  @override
  State<ParticipantSelector> createState() => _ParticipantSelectorState();
}

class _ParticipantSelectorState extends State<ParticipantSelector>
    with DisposableControllersMixin<ParticipantSelector> {
  late final _nameController = manageController();

  void _toggle(String personId) {
    final updated = Set.of(widget.selectedIds);
    if (!updated.remove(personId)) updated.add(personId);
    widget.onSelectionChanged(updated);
  }

  void _submitNewPerson() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onAddPerson(name);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final person in widget.people)
              FilterChip(
                label: Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: widget.selectedIds.contains(person.id),
                onSelected: (_) => _toggle(person.id),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: AppStrings.newParticipantHint,
                ),
                onSubmitted: (_) => _submitNewPerson(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: AppStrings.addPersonTooltip,
              onPressed: _submitNewPerson,
            ),
          ],
        ),
      ],
    );
  }
}
