import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blocked_day.dart';
import '../providers/blocked_day_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'block_form_screen.dart';

/// Lista dias bloqueados e permite adicionar (BlockFormScreen) ou remover.
class BlockedDaysListScreen extends StatelessWidget {
  const BlockedDaysListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsBlockedDays),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<BlockedDayProvider>(
        builder: (context, provider, _) {
          if (provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noBlockedDays,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.noBlockedDaysSubtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final sorted = List<BlockedDay>.from(provider.items)
            ..sort((a, b) => a.date.compareTo(b.date));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final block = sorted[index];
              return Dismissible(
                key: Key(block.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(AppStrings.delete),
                      content: Text(
                        'Excluir "${block.label}" (${AppFormatters.formatDate(block.date)})?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(AppStrings.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                          child: const Text(AppStrings.delete),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await provider.remove(block.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dia bloqueado removido')),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5),
                      child: Icon(
                        Icons.event_busy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(block.label),
                    subtitle: Text(AppFormatters.formatDate(block.date)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BlockFormScreen(),
            ),
          );
          if (context.mounted) {
            context.read<BlockedDayProvider>().load();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
