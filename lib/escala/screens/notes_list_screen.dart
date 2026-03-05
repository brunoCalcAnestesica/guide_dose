import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../utils/formatters.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloco de Notas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Arquivadas',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ArchivedNotesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma nota',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque em + para criar uma nova nota',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final note = provider.items[index];
              return NoteCard(note: note);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const NoteEditorScreen(),
            ),
          );
          if (context.mounted) {
            context.read<NoteProvider>().reload();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  String _preview(String content) {
    if (content.isEmpty) return 'Nota vazia';
    final clean = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length > 80 ? '${clean.substring(0, 80)}…' : clean;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NoteProvider>();

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Text('Arquivar',
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Excluir',
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await provider.archive(note.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nota arquivada')),
            );
          }
          return false;
        } else {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Excluir'),
              content: Text('Excluir "${note.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await provider.delete(note.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota removida')),
              );
            }
            return true;
          }
          return false;
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
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _preview(note.content),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatters.formatDate(note.updatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NoteEditorScreen(note: note),
              ),
            );
            if (context.mounted) {
              context.read<NoteProvider>().reload();
            }
          },
        ),
      ),
    );
  }
}

class ArchivedNotesScreen extends StatefulWidget {
  const ArchivedNotesScreen({super.key});

  @override
  State<ArchivedNotesScreen> createState() => _ArchivedNotesScreenState();
}

class _ArchivedNotesScreenState extends State<ArchivedNotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().fetchArchivedItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas Arquivadas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.loadingArchived) {
            return const Center(child: CircularProgressIndicator());
          }

          final archived = provider.archivedItems;

          if (archived.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma nota arquivada',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: archived.length,
            itemBuilder: (context, index) {
              final note = archived[index];
              return ArchivedNoteCard(note: note);
            },
          );
        },
      ),
    );
  }
}

class ArchivedNoteCard extends StatelessWidget {
  final Note note;
  const ArchivedNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NoteProvider>();

    return Dismissible(
      key: Key(note.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.unarchive_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await provider.unarchive(note.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nota restaurada')),
            );
          }
          return false;
        } else {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Excluir'),
              content: Text('Excluir "${note.title}" permanentemente?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await provider.deleteArchived(note.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota excluída')),
              );
            }
            return true;
          }
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            child: Icon(
              Icons.archive_outlined,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          title: Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            AppFormatters.formatDate(note.updatedAt),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.unarchive_outlined),
                tooltip: 'Restaurar',
                onPressed: () async {
                  await provider.unarchive(note.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nota restaurada')),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'Excluir',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir'),
                      content:
                          Text('Excluir "${note.title}" permanentemente?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await provider.deleteArchived(note.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
