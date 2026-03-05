import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../utils/constants.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Nota' : 'Nova Nota'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Arquivar',
              onPressed: _archive,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: AppStrings.save,
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Escreva aqui...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    if (isEditing)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton.outlined(
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline),
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          tooltip: AppStrings.delete,
                        ),
                      ),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.save,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final provider = context.read<NoteProvider>();
    final title = _titleController.text.trim();
    final content = _contentController.text;

    try {
      if (isEditing) {
        final updated = widget.note!
          ..title = title.isEmpty ? 'Sem título' : title
          ..content = content;
        await provider.update(updated);
      } else {
        await provider.add(title, content);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _archive() async {
    try {
      await context.read<NoteProvider>().archive(widget.note!.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota arquivada')),
      );
      Navigator.of(context).pop();
    }
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<NoteProvider>().delete(widget.note!.id);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteError)),
          );
        }
        return;
      }
      if (mounted) Navigator.of(context).pop();
    }
  }
}
