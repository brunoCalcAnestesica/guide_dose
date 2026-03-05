import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../providers/patient_provider.dart';
import '../utils/constants.dart';
import '../../medical_ai_screen.dart';
import 'note_editor_screen.dart';
import 'notes_list_screen.dart';
import 'patient_editor_screen.dart';
import 'patients_list_screen.dart';

/// Janela única com abas para Bloco de Notas e Pacientes.
class NotesAndPatientsScreen extends StatefulWidget {
  /// 0 = Pacientes, 1 = Notas
  final int initialTabIndex;

  const NotesAndPatientsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<NotesAndPatientsScreen> createState() => _NotesAndPatientsScreenState();
}

class _NotesAndPatientsScreenState extends State<NotesAndPatientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.75),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pacientes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Notas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (_tabController.index == 0) {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PatientEditorScreen(),
                      ),
                    );
                    if (context.mounted) {
                      context.read<PatientProvider>().reload();
                    }
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NoteEditorScreen(),
                      ),
                    );
                    if (context.mounted) {
                      context.read<NoteProvider>().reload();
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Tooltip(
                  message: _tabController.index == 0 ? 'Novo paciente' : 'Nova nota',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: _tabController.index == 0 ? 'Arquivados' : 'Arquivadas',
            onPressed: () {
              if (_tabController.index == 0) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ArchivedPatientsScreen(),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ArchivedNotesScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PatientsTabBody(),
          _NotesTabBody(),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MedicalAIScreen(),
              ),
            );
          },
          tooltip: 'IA',
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.auto_awesome),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

/// Corpo da aba Notas (lista ou vazio).
class _NotesTabBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
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
                    'Toque no + acima para criar uma nova nota',
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
    );
  }
}

/// Corpo da aba Pacientes (lista ou vazio).
class _PatientsTabBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, _) {
        if (provider.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum paciente',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no + acima para adicionar um paciente',
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
            final patient = provider.items[index];
            return PatientCard(patient: patient);
          },
        );
      },
    );
  }
}
