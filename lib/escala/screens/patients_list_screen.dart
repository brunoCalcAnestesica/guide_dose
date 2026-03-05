import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/formatters.dart';
import 'patient_editor_screen.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Arquivados',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ArchivedPatientsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PatientProvider>(
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
                      'Toque em + para adicionar um paciente',
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PatientEditorScreen(),
            ),
          );
          if (context.mounted) {
            context.read<PatientProvider>().reload();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;
  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PatientProvider>();
    final dih = patient.admissionDays;

    return Dismissible(
      key: Key(patient.id),
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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await provider.archive(patient.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paciente arquivado')),
            );
          }
          return false;
        } else {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Excluir'),
              content: Text('Excluir paciente "${patient.initials}"?'),
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
            await provider.delete(patient.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paciente removido')),
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
            child: Text(
              patient.initials.isNotEmpty
                  ? patient.initials.substring(
                      0, patient.initials.length > 2 ? 2 : patient.initials.length)
                  : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            patient.initials.isEmpty ? 'Sem iniciais' : patient.initials,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(patient.ageDisplay),
                  if (dih != null) ...[
                    const Text('  •  '),
                    Text('DIH: ${dih}º dia'),
                  ],
                ],
              ),
              if (patient.diagnosis.isNotEmpty)
                Text(
                  patient.diagnosis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          trailing: patient.antibiotics.trim().isNotEmpty
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ATB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                )
              : null,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PatientEditorScreen(patient: patient),
              ),
            );
            if (context.mounted) {
              context.read<PatientProvider>().reload();
            }
          },
        ),
      ),
    );
  }
}

class ArchivedPatientsScreen extends StatefulWidget {
  const ArchivedPatientsScreen({super.key});

  @override
  State<ArchivedPatientsScreen> createState() => _ArchivedPatientsScreenState();
}

class _ArchivedPatientsScreenState extends State<ArchivedPatientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchArchivedItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes Arquivados'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<PatientProvider>(
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
                      'Nenhum paciente arquivado',
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
              final patient = archived[index];
              final provider = context.read<PatientProvider>();
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    child: Text(
                      patient.initials.isNotEmpty
                          ? patient.initials.substring(0,
                              patient.initials.length > 2 ? 2 : patient.initials.length)
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  title: Text(patient.initials.isEmpty
                      ? 'Sem iniciais'
                      : patient.initials),
                  subtitle: Text(AppFormatters.formatDate(patient.updatedAt)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.unarchive_outlined),
                        tooltip: 'Restaurar',
                        onPressed: () async {
                          await provider.unarchive(patient.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Paciente restaurado')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error),
                        tooltip: 'Excluir',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Excluir'),
                              content: Text(
                                  'Excluir "${patient.initials}" permanentemente?'),
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
                            await provider.deleteArchived(patient.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
