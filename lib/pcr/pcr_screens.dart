import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:medcalc/pcr/simple_beep_player_controller.dart';
import 'package:medcalc/shared_data.dart';

// 🌐 CONFIGURAÇÃO DE IDIOMA GLOBAL
String appLanguage = 'PT';

final Map<String, Map<String, String>> strings = {
  'PT': {
    'title': 'MC PCR',
    'select_mode': 'Selecionar Modo',
    'mode_acls': 'Modo ACLS',
    'mode_pals': 'Modo PALS',
    'rcp_title': 'RCP -',
    'rcp_text': 'Tela de RCP:',
    'start_cpr': 'Início RCP',
    'start_cpr_label': 'RCP',
    'cpr': 'RCP',
    'switch': 'Troca',
    'adrenaline': 'Adrenalina',
    'amiodarone': 'Amiodarona',
    'lidocaine': 'Lidocaína',
    'bicarbonate': 'Bicarbonato de Sódio',
    'intubation': 'Intubação',
    'shock': 'Choque',
    'return_of_spontaneous_circulation': 'Retorno da Circulação Espontânea',
    'rhythm': 'Ritmo',
    'asystole': 'Assistolia',
    'vfib': 'FV',
    'vtach': 'TV',
    'pvtach': 'TV Pulso',
    'pulseless_electrical_activity': 'Atividade Elétrica Sem Pulso',
    // 'start': 'Iniciar', // removido
    'stop': 'Parar',
    'reset': 'Resetar',
    'patient_data': 'Dados do Paciente',
    'age': 'Idade (anos)',
    'weight': 'Peso (kg)',
    'start_button': 'Iniciar',
    // Novos termos
    'monitor': 'Monitor',
    'balao': 'Balão Auto Inflável',
    'veia': 'Veia',
    'events': 'Eventos',
    'patient': 'Paciente',
    'events_title': 'Eventos RCP',
    'no_medication': 'Nenhum medicamento',
    'charge': 'Carrege',
    'yes': 'Sim',
    'no': 'Não',
    'adrenaline_desc':
        'Adrenalina: {dose} mg ({volume} mL) \n— 1 ampola para 10 mL de Sf 0,9%',
    'amiodarone_desc':
        'Amiodarona: {dose} mg ({volume} mL) \n— diluir em SF 20-30 mL (50 mg/mL)',
    'lidocaine_desc':
        'Lidocaína: {dose} mg ({volume} mL) \n— solução 1% (10 mg/mL)',
    'bicarbonate_desc':
        'Bicarbonato de Sódio: {dose} mEq ({volume} mL) \n— solução 8.4% (1 mEq/mL)',
    // Novas chaves para via, unidade e log de medicação
    'direct_iv': 'EV direta',
    'slow_iv': 'IV lenta',
    'mg': 'mg',
    'meq': 'mEq',
    'medication_log': '{med} ({dose} {unit}) administrado por via {via}.',
    // Nova chave para troca de massagem
    'compression_change': 'Troca de massagem',
    // Chave para intubação realizada
    'intubation_performed': 'Intubação realizada',
    // Nova chave para interrupção dos esforços
    'interruption_of_efforts': 'Interrupção dos Esforços',
    'birth_date': 'Data de Nascimento',
    'record_number': 'Número do Prontuário',
    'diagnostic': 'Diagnóstico',
    'comorbidities': 'Comorbidades',
    'doctor_name': 'Médico Assistente',
    'doctor_registry': 'Registro Médico ',
    'other_medication': 'Outros',
    'other_medication_title': 'Outros medicamentos',
    'other_medication_hint': 'Descreva o medicamento ou ação...',
    'cancel': 'Cancelar',
    'save': 'Salvar',
  },
};

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});
  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool monitorChecked = false;
  bool balaoChecked = false;
  bool veiaChecked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parada Cardio Respiratória',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Referências Bibliográficas',
            onPressed: () => _showReferencesDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Text(
                'PCR',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF102A43),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    // Verificar se os dados do paciente estão preenchidos
                    if (SharedData.idade == null || SharedData.peso == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, preencha os dados do paciente na aba "Paciente" antes de iniciar.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    // Usar dados do SharedData
                    final idade = SharedData.idade!.round();
                    final peso = SharedData.peso!;

                    // Mostrar popup apenas com checkboxes (Monitor, Balão, Veia)
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => StatefulBuilder(
                        builder: (context, setStateDialog) => Dialog(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: size.width * 0.9,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Confirmar Atendimento PCR',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Idade: $idade anos | Peso: ${peso.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                // Checkboxes
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildCheckboxTile(
                                        title:
                                            strings[appLanguage]!['monitor']!,
                                        value: monitorChecked,
                                        onChanged: (value) {
                                          setState(
                                              () => monitorChecked = value!);
                                          setStateDialog(() {});
                                        },
                                      ),
                                      _buildCheckboxTile(
                                        title: strings[appLanguage]!['balao']!,
                                        value: balaoChecked,
                                        onChanged: (value) {
                                          setState(() => balaoChecked = value!);
                                          setStateDialog(() {});
                                        },
                                      ),
                                      _buildCheckboxTile(
                                        title: strings[appLanguage]!['veia']!,
                                        value: veiaChecked,
                                        onChanged: (value) {
                                          setState(() => veiaChecked = value!);
                                          setStateDialog(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final modo =
                                                idade < 8 ? 'PALS' : 'ACLS';
                                            Navigator.of(context).pop();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => CodeLogScreen(
                                                  mode: modo,
                                                  idade: idade,
                                                  peso: peso,
                                                  monitor: monitorChecked,
                                                  balao: balaoChecked,
                                                  veia: veiaChecked,
                                                  autoStart: true,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Iniciar'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(strings['PT']!['start_button']!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
      {required String title,
      required bool value,
      required ValueChanged<bool?> onChanged}) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

class CodeLogScreen extends StatefulWidget {
  final String mode;
  final int idade;
  final double peso;
  final bool monitor;
  final bool balao;
  final bool veia;
  final bool autoStart;
  final List<String>? initialLogEntries;

  const CodeLogScreen({
    super.key,
    required this.mode,
    required this.idade,
    required this.peso,
    required this.monitor,
    required this.balao,
    required this.veia,
    this.autoStart = false,
    this.initialLogEntries,
  });

  @override
  State<CodeLogScreen> createState() => _CodeLogScreenState();
}

class _CodeLogScreenState extends State<CodeLogScreen> {
  // Variável para controle do beep
  late SimpleBeepPlayerController beepController;
  int adrenalineCount = 0;
  int shockCount = 0;
  int amiodaroneDoseCount = 0;
  Map<String, DateTime> _medBlockTimestamps = {};

  void administerMedication(String medKey,
      {bool restartCountdown = true, bool segundaDose = false}) {
    final now = DateTime.now();
    final clockTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    String medName = strings['PT']![medKey] ?? medKey;
    String via = '';
    String unit = '';
    final peso = widget.peso;
    final idade = widget.idade;
    double dose = 0.0;
    switch (medKey) {
      case 'amiodarone':
        via = strings['PT']!['direct_iv']!;
        unit = strings['PT']!['mg']!;
        if (idade >= 12) {
          if (amiodaroneDoseCount == 0) {
            dose = 300;
          } else if (amiodaroneDoseCount == 1) {
            dose = 150;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Dose não permitida após a segunda dose de amiodarona em adultos.')),
            );
            return;
          }
        } else {
          if (amiodaroneDoseCount == 0) {
            dose = (peso * 5).clamp(0, 300);
          } else if (amiodaroneDoseCount < 3) {
            dose = (peso * 5).clamp(0, 150);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Dose não permitida após a terceira dose de amiodarona em crianças.')),
            );
            return;
          }
        }
        break;
      case 'lidocaine':
        via = strings['PT']!['direct_iv']!;
        unit = strings['PT']!['mg']!;
        dose = peso * 1;
        break;
      case 'adrenaline':
        via = strings['PT']!['direct_iv']!;
        unit = strings['PT']!['mg']!;
        dose = idade >= 12 ? 1.0 : (peso * 0.01).clamp(0, 1.0);
      case 'bicarbonate':
        medName = strings['PT']!['bicarbonate']!;
        via = strings['PT']!['slow_iv']!;
        unit = strings['PT']!['meq']!;
        dose = peso * 1; // 1 mEq/kg
        break;
      default:
        via = strings['PT']!['direct_iv']!;
        unit = strings['PT']!['mg']!;
        dose = (peso * 0.01).clamp(0, 1.0);
    }
    String logTemplate = strings['PT']!['medication_log']!;
    String medLog = logTemplate
        .replaceFirst('{med}', medName)
        .replaceFirst('{dose}', dose.toStringAsFixed(2))
        .replaceFirst('{unit}', unit)
        .replaceFirst('{via}', via);
    setState(() {
      _logEntries
          .add('[$clockTime] +${formatTime(secondsElapsed)} → 💉 $medLog');
      if (medKey == 'adrenaline') {
        adrenalineCount++;
      }
      // Para bicarbonato, não reinicia o countdown se restartCountdown for false
      if (restartCountdown) {
        countdownAdrenaline = 120;
        showAdre = true;
      }
      if (medKey == 'amiodarone') {
        amiodaroneDoseCount++;
      }
      _medBlockTimestamps[medKey] = DateTime.now();
    });
  }

  int _selectedIndex = 0;
  bool isRunning = false;
  int secondsElapsed = 0;
  int secondsSinceAdrenaline = 0;
  int countdownAdrenaline = 0;
  String rhythm = 'asystole';
  int pediatricShockCount = 0;

  String calcularCargaChoque() {
    // ACLS: sempre MAX
    if (widget.idade >= 15) {
      return 'MAX';
    }
    // PALS: 1º choque 2J/kg, 2º 4J/kg, >=3º 10J/kg (máx 200J)
    double carga;
    if (pediatricShockCount == 0) {
      carga = widget.peso * 2;
    } else if (pediatricShockCount == 1) {
      carga = widget.peso * 4;
    } else {
      carga = widget.peso * 10;
    }
    if (carga > 200) carga = 200;
    return '${carga.toStringAsFixed(0)}J';
  }

  double intubationOpacity = 1.0;
  Timer? intubationBlinkTimer = null; // Garante null inicial
  bool isIntubated = false;

  bool showRhythmButton = true;

  bool showRhythmAlertBorder = false;
  List<Map<String, dynamic>> medicationSchedule = [];
  int medIndex = 0;

  StreamSubscription<int>? ticker;
  Timer? revezamentoTimer;

  late List<String> _logEntries;
  bool showAdre = true;
  bool showCPRLabel = true;
  bool highlightShock = false;
  Timer? shockBlinkTimer;
  double shockOpacity = 1.0;
  double cprBlinkOpacity = 1.0;
  Timer? cprBlinkTimer;
  double rhythmOpacity = 1.0;
  Timer? rhythmBlinkTimer;
  bool isCprGreen = false;

  @override
  void initState() {
    super.initState();
    _logEntries = widget.initialLogEntries != null
        ? List<String>.from(widget.initialLogEntries!)
        : [];
    // Inicializa o controlador do beep
    beepController = SimpleBeepPlayerController(bpm: 115);
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rhythmBlinkTimer?.cancel();
        rhythmBlinkTimer =
            Timer.periodic(const Duration(milliseconds: 800), (_) {
          if (!showRhythmButton) return;
          setState(() {
            rhythmOpacity = rhythmOpacity == 0.8 ? 0.0 : 0.8;
          });
        });
        _realStart();
      });
    }
  }

  void _realStart() {
    if (!isRunning) {
      setState(() {
        isRunning = true;
        secondsSinceAdrenaline = 0;
        countdownAdrenaline = 0;
        showAdre = true;
        final now = DateTime.now();
        final clockTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        // Adiciona evento: Identificado Parada Cardio Respiratória pela ausência de pulso
        _logEntries.add(
            '[$clockTime] +${formatTime(secondsElapsed)} → Identificado Parada Cardio Respiratória pela ausência de pulso');
        // Adiciona evento: Início RCP
        _logEntries.add(
            '[$clockTime] +${formatTime(secondsElapsed)} → ${strings['PT']!['start_cpr']!}');
      });
      // Inicia o beep junto com a contagem
      beepController.start();
      ticker = Stream.periodic(const Duration(milliseconds: 800), (x) => x)
          .listen((event) {
        setState(() {
          secondsElapsed++;
          secondsSinceAdrenaline++;
          if (countdownAdrenaline > 0) {
            countdownAdrenaline--;
            showAdre = true;
          } else if (countdownAdrenaline == 0) {
            showAdre = !showAdre;
          }
          if (secondsElapsed % 120 == 0 && secondsElapsed != 0) {
            isCprGreen = !isCprGreen;
          }
        });
      });
      revezamentoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final minutos = secondsElapsed ~/ 60;
        final segundos = secondsElapsed % 60;

        if (minutos > 0 && minutos % 2 == 0 && segundos < 10) {
          if (showCPRLabel) {
            final now = DateTime.now();
            final clockTime =
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
            _logEntries.add(
                '[$clockTime] +${formatTime(secondsElapsed)} → 🔁 ${strings['PT']!['compression_change']!}');
            setState(() {
              showCPRLabel = false;
            });
            cprBlinkTimer?.cancel();
            cprBlinkTimer =
                Timer.periodic(const Duration(milliseconds: 800), (_) {
              setState(() {
                cprBlinkOpacity = cprBlinkOpacity == 1.0 ? 0.0 : 1.0;
              });
            });
          }
        } else if (!showCPRLabel) {
          setState(() {
            showCPRLabel = true;
            cprBlinkTimer?.cancel();
            cprBlinkOpacity = 1.0;
          });
        }

        if (minutos % 2 != 0 && segundos >= 45) {
          if (!showRhythmAlertBorder) {
            setState(() {
              showRhythmAlertBorder = true;
            });
          }
        }

        if (minutos % 2 != 0 &&
            segundos == 59 &&
            showRhythmButton &&
            rhythmBlinkTimer == null) {
          rhythmBlinkTimer =
              Timer.periodic(const Duration(milliseconds: 800), (_) {
            if (!showRhythmButton) return;
            setState(() {
              rhythmOpacity = rhythmOpacity == 0.8 ? 0.0 : 0.8;
            });
          });
        }
        if (secondsElapsed >= 180 &&
            !isIntubated &&
            intubationBlinkTimer == null) {
          intubationBlinkTimer =
              Timer.periodic(const Duration(milliseconds: 800), (_) {
            setState(() {
              intubationOpacity = intubationOpacity == 1.0 ? 0.0 : 1.0;
            });
          });
        }
      });
    }
  }

  String patientName = '';
  String patientBirth = '';
  String patientRecord = '';
  String doctorName = '';
  String doctorCrm = '';
  String diagnostic = '';
  String comorbidities = '';

  void stopTimer([String? reasonKey]) {
    if (isRunning) {
      // Para o beep junto com a contagem
      beepController.stop();
      ticker?.cancel();
      setState(() {
        isRunning = false;
        final now = DateTime.now();
        final clockTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        if (reasonKey != null && strings['PT']!.containsKey(reasonKey)) {
          _logEntries.add(
              '[$clockTime] +${formatTime(secondsElapsed)} → ${strings['PT']![reasonKey]!}');
        }
      });
    }
  }

  void stopWithReason(String reasonKey) {
    stopTimer(reasonKey);
    setState(() {
      _selectedIndex = 1;
    });
    // Após salvar os dados e encerrar, navega para a tela de resumo, passando os dados do paciente e eventos.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResumoEventosScreen(
          logEntries: _logEntries,
          patientName: patientName,
          patientBirth: patientBirth,
          patientRecord: patientRecord,
          diagnostic: diagnostic,
          comorbidities: comorbidities,
          doctorName: doctorName,
          doctorCrm: doctorCrm,
          patientAge: widget.idade.toString(),
          patientWeight: widget.peso.toStringAsFixed(1),
        ),
      ),
    );
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      secondsElapsed = 0;
    });
  }

  void changeRhythm(String newRhythm) {
    setState(() {
      rhythmBlinkTimer?.cancel();
      rhythmBlinkTimer = null;
      rhythmOpacity = 1.0;

      showRhythmAlertBorder = false;

      rhythm = newRhythm;
      highlightShock = (newRhythm == 'vfib' || newRhythm == 'vtach');
      showRhythmButton = !(highlightShock);
      if (highlightShock) {
        shockBlinkTimer?.cancel();
        shockBlinkTimer =
            Timer.periodic(const Duration(milliseconds: 800), (_) {
          setState(() {
            shockOpacity = shockOpacity == 1.0 ? 0.0 : 1.0;
          });
        });
      } else {
        shockOpacity = 1.0;
      }
      final now = DateTime.now();
      final clockTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      _logEntries.add(
          '[$clockTime] +${formatTime(secondsElapsed)} → ${strings['PT']!['rhythm']!}: ${strings['PT']![newRhythm]!}');
      if (medicationSchedule.isEmpty) {
        initializeSchedule(newRhythm);
      }
    });
  }

  void initializeSchedule(String rhythm) {
    medicationSchedule.clear();
    medIndex = 0;

    if (rhythm == 'vfib' || rhythm == 'vtach') {
      medicationSchedule.addAll([
        {'med': 'adrenaline', 'interval': 120},
        {'med': 'amiodarone', 'interval': 120},
        {'med': 'adrenaline', 'interval': 120},
        {'med': 'amiodarone', 'interval': 120},
        {'med': 'adrenaline', 'interval': 120},
        {'med': 'lidocaine', 'interval': 120},
        {'med': 'adrenaline', 'interval': 240},
        {'med': 'adrenaline', 'interval': 240},
      ]);
    } else {
      medicationSchedule.addAll([
        {'med': 'adrenaline', 'interval': 240},
        {'med': 'adrenaline', 'interval': 240},
      ]);
    }
  }

  void administerNextMedication() {
    if (medIndex >= medicationSchedule.length) {
      final currentRhythm = rhythm;
      if (currentRhythm == 'vfib' || currentRhythm == 'vtach') {
        if (medIndex == 8) {
          medicationSchedule.add({'med': 'adrenaline', 'interval': 240});
        } else {
          medicationSchedule.addAll([
            {'med': 'adrenaline', 'interval': 120},
            {'med': 'amiodarone', 'interval': 120},
            {'med': 'adrenaline', 'interval': 120},
            {'med': 'amiodarone', 'interval': 120},
            {'med': 'adrenaline', 'interval': 120},
            {'med': 'lidocaine', 'interval': 120},
            {'med': 'adrenaline', 'interval': 240},
          ]);
        }
      } else if (currentRhythm == 'asystole' ||
          currentRhythm == 'pulseless_electrical_activity') {
        medicationSchedule.add({'med': 'adrenaline', 'interval': 240});
      }
    }

    final current = medicationSchedule[medIndex];
    medIndex++;
    final now = DateTime.now();
    final clockTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    String medKey = current['med'];
    String medName = strings['PT']![medKey] ?? medKey;
    String via = '';
    String unit = '';
    switch (medKey) {
      case 'amiodarone':
      case 'lidocaine':
      case 'adrenaline':
        via = strings['PT']!['direct_iv']!;
        unit = strings['PT']!['mg']!;
        break;
      case 'bicarbonato':
        medName = strings['PT']!['bicarbonate']!;
        via = strings['PT']!['slow_iv']!;
        unit = strings['PT']!['meq']!;
        break;
      default:
        via = strings['PT']!['direct_iv']!;
        unit = strings['PT']!['mg']!;
    }
    final peso = widget.peso;
    final idade = widget.idade;
    final dose = medKey == 'amiodarone'
        ? (idade < 12
            ? (peso * 5).clamp(0, 300)
            : 300.0) // dose padrão para adultos
        : medKey == 'adrenaline'
            ? (idade < 12 ? (peso * 0.01).clamp(0, 1.0) : 1.0)
            : switch (medKey) {
                'lidocaine' => peso * 1,
                'bicarbonato' => peso * 1,
                _ => (peso * 0.01).clamp(0, 1.0),
              };
    String logTemplate = strings['PT']!['medication_log']!;
    String medLog = logTemplate
        .replaceFirst('{med}', medName)
        .replaceFirst('{dose}', dose.toStringAsFixed(2))
        .replaceFirst('{unit}', unit)
        .replaceFirst('{via}', via);
    _logEntries.add('[$clockTime] +${formatTime(secondsElapsed)} → 💉 $medLog');
    countdownAdrenaline = 120;
    showAdre = true;
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    ticker?.cancel();
    shockBlinkTimer?.cancel();
    revezamentoTimer?.cancel();
    cprBlinkTimer?.cancel();
    rhythmBlinkTimer?.cancel();
    intubationBlinkTimer?.cancel();
    beepController.stop();
    super.dispose();
  }

  // Mover _buildMedicationList antes do build para evitar referência antecipada
  Widget _buildMedicationList({
    required double doseAdre,
    required double doseAmi,
    required double doseLido,
    required double doseBic,
    required double volumeAdre,
    required double volumeAmi,
    required double volumeLido,
    required double volumeBic,
  }) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> meds = [
      {
        'medKey': null,
        'label': strings['PT']!['no_medication']!,
        'desc': null,
        'onTap': () {
          Navigator.pop(context);
          setState(() {
            countdownAdrenaline = 120;
            showAdre = true;
          });
        }
      },
    ];
    if (!_medBlockTimestamps.containsKey('adrenaline') ||
        now.difference(_medBlockTimestamps['adrenaline']!) >
            const Duration(minutes: 3)) {
      meds.add({
        'medKey': 'adrenaline',
        'label': strings['PT']!['adrenaline']!,
        'desc': strings['PT']!['adrenaline_desc']!
            .replaceFirst('{dose}', doseAdre.toStringAsFixed(2))
            .replaceFirst('{volume}', volumeAdre.toStringAsFixed(1)),
        'onTap': () {
          Navigator.pop(context);
          administerMedication('adrenaline');
          setState(() {
            countdownAdrenaline = 120;
            showAdre = true;
          });
        }
      });
    }
    if ((widget.idade >= 12 && amiodaroneDoseCount < 2) ||
        (widget.idade < 12 && amiodaroneDoseCount < 3)) {
      if (!_medBlockTimestamps.containsKey('amiodarone') ||
          now.difference(_medBlockTimestamps['amiodarone']!) >
              const Duration(minutes: 3)) {
        meds.add({
          'medKey': 'amiodarone',
          'label': strings['PT']!['amiodarone']!,
          'desc': strings['PT']!['amiodarone_desc']!
              .replaceFirst('{dose}', doseAmi.toStringAsFixed(2))
              .replaceFirst('{volume}', volumeAmi.toStringAsFixed(1)),
          'onTap': () {
            Navigator.pop(context);
            administerMedication('amiodarone', segundaDose: false);
            setState(() {
              countdownAdrenaline = 120;
              showAdre = true;
            });
          }
        });
      }
    }
    if (!_medBlockTimestamps.containsKey('bicarbonate') ||
        now.difference(_medBlockTimestamps['bicarbonate']!) >
            const Duration(minutes: 3)) {
      meds.add({
        'medKey': 'bicarbonate',
        'label': strings['PT']!['bicarbonate']!,
        'desc':
            'Bicarbonato de Sódio: ${doseBic.toStringAsFixed(2)} mEq (${doseBic.toStringAsFixed(2)} mL) — solução 8.4% (1 mEq/mL)',
        'onTap': () {
          Navigator.pop(context);
          administerMedication('bicarbonate', restartCountdown: false);
          setState(() {});
        }
      });
    }
    if (!_medBlockTimestamps.containsKey('lidocaine') ||
        now.difference(_medBlockTimestamps['lidocaine']!) >
            const Duration(minutes: 3)) {
      meds.add({
        'medKey': 'lidocaine',
        'label': strings['PT']!['lidocaine']!,
        'desc': strings['PT']!['lidocaine_desc']!
            .replaceFirst('{dose}', doseLido.toStringAsFixed(2))
            .replaceFirst('{volume}', volumeLido.toStringAsFixed(1)),
        'onTap': () {
          Navigator.pop(context);
          administerMedication('lidocaine');
          setState(() {
            countdownAdrenaline = 120;
            showAdre = true;
          });
        }
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...meds.map((item) => ListTile(
              title: Center(
                  child: Text(item['label'] as String,
                      textAlign: TextAlign.center)),
              subtitle: item['desc'] != null
                  ? Center(
                      child: Text(item['desc'] as String,
                          textAlign: TextAlign.center))
                  : null,
              onTap: item['onTap'] as void Function()?,
            )),
        ListTile(
          title: Center(
            child: Text(
              strings['PT']!['other_medication']!,
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () async {
            Navigator.pop(context);
            final TextEditingController otherMedController =
                TextEditingController();
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text(strings['PT']!['other_medication_title']!),
                content: TextField(
                  controller: otherMedController,
                  autofocus: true,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: strings['PT']!['other_medication_hint']!,
                  ),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings['PT']!['cancel']!),
                  ),
                  TextButton(
                    onPressed: () {
                      final now = DateTime.now();
                      final clockTime =
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                      final description = otherMedController.text.trim();
                      if (description.isNotEmpty) {
                        setState(() {
                          _logEntries.add(
                              '[$clockTime] +${formatTime(secondsElapsed)} → ${strings['PT']!['other_medication_title']}: $description');
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: Text(strings['PT']!['save']!),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
                beepController.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                size: 28),
            tooltip: beepController.isPlaying ? 'Parar beep' : 'Iniciar beep',
            onPressed: () {
              setState(() {
                if (beepController.isPlaying) {
                  beepController.stop();
                } else {
                  beepController.start();
                }
              });
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          centerTitle: false,
          title: Center(
            child: Text(
              'Idade: ${widget.idade} anos | Peso: ${widget.peso.toStringAsFixed(1)} kg',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.lan),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                          const Text("H's e T's na Parada Cardiorrespiratória"),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "H's:\n"
                                      "- Hipovolemia\n"
                                      "- Hipóxia\n"
                                      "- Hidrogênio (acidose)\n"
                                      "- Hiper-/Hipocalemia\n"
                                      "- Hipotermia" +
                                  (widget.idade < 12
                                      ? "\n- Hipoglicemia"
                                      : "") +
                                  "\n\nT's:\n"
                                      "- Tensão no pneumotórax\n"
                                      "- Tamponamento cardíaco\n"
                                      "- Toxinas\n"
                                      "- Tromboembolismo pulmonar\n"
                                      "- Tromboembolismo coronariano",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Fechar'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          // Garante que o índice seja 0 ou 1, pois temos 2 filhos no IndexedStack
          index: (_selectedIndex == 1) ? 1 : 0,
          children: [
            // Página principal com toda a estrutura visual da RCP (Stack com botões ao redor do paciente)
            Container(
              // Pode adicionar propriedades de estilo, padding, etc, se desejar
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, -0.6),
                    child: Icon(
                      Icons.accessibility,
                      size: isIOS ? 320 : 320,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  // Idade e peso discretos no canto inferior esquerdo
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          'Idade: ${widget.idade} anos | Peso: ${widget.peso.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Contadores de adrenalina e choque - alinhados no topo, centralizados, altura restrita
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9E2EC),
                                  borderRadius:
                                      BorderRadius.circular(isIOS ? 8 : 12),
                                  border: Border.all(
                                      color: const Color(0xFF334E68), width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Center(
                                  child: Text(
                                    'Adrenalina: $adrenalineCount doses',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: isIOS ? 12 : 14,
                                      color: const Color(0xFF334E68),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius:
                                      BorderRadius.circular(isIOS ? 8 : 12),
                                  border: Border.all(
                                      color: const Color(0xFFDA1E28), width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Center(
                                  child: Text(
                                    'Choques: $shockCount vezes',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: isIOS ? 12 : 14,
                                      color: const Color(0xFFDA1E28),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Lado esquerdo - botão ritmo (posição mais centralizada, agora com Align)
                  if (showRhythmButton)
                    Align(
                      alignment: const Alignment(-0.6, -0.3),
                      child: AnimatedOpacity(
                        opacity: rhythmOpacity,
                        duration: const Duration(milliseconds: 400),
                        child: RawMaterialButton(
                          onPressed: () {
                            if (rhythmOpacity < 1) {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) => SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ritmo da Parada Cardio Respiratória',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        ListTile(
                                          title: const Text(
                                              'FV: Fibrilação Ventricular'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () {
                                            Navigator.pop(context);
                                            changeRhythm('vfib');
                                          },
                                        ),
                                        ListTile(
                                          title: const Text(
                                              'TV: Taquicardia Ventricular'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () {
                                            Navigator.pop(context);
                                            changeRhythm('vtach');
                                          },
                                        ),
                                        ListTile(
                                          title: const Text(
                                              'AESP: Atividade Elétrica Sem Pulso'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () {
                                            Navigator.pop(context);
                                            changeRhythm(
                                                'pulseless_electrical_activity');
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('AST: Assistolia'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () {
                                            Navigator.pop(context);
                                            changeRhythm('asystole');
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Desfecho',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        ListTile(
                                          title: const Text(
                                              'RCE: Retorno à Circulação Espontânea'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () async {
                                            Navigator.pop(context);
                                            stopTimer('popup_patient_data');
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                TextEditingController
                                                    nameController =
                                                    TextEditingController(
                                                        text: patientName);
                                                TextEditingController
                                                    birthController =
                                                    TextEditingController(
                                                        text: patientBirth);
                                                TextEditingController
                                                    recordController =
                                                    TextEditingController(
                                                        text: patientRecord);
                                                TextEditingController
                                                    diagnosticController =
                                                    TextEditingController(
                                                        text: diagnostic);
                                                TextEditingController
                                                    comorbiditiesController =
                                                    TextEditingController(
                                                        text: comorbidities);
                                                // Carregar dados do médico do SharedPreferences
                                                TextEditingController
                                                    doctorController =
                                                    TextEditingController();
                                                TextEditingController
                                                    crmController =
                                                    TextEditingController();
                                                Future<void>
                                                    loadDoctorData() async {
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  doctorController.text =
                                                      prefs.getString(
                                                              'doctorName') ??
                                                          doctorName;
                                                  crmController.text =
                                                      prefs.getString(
                                                              'doctorCrm') ??
                                                          doctorCrm;
                                                }

                                                // Garante que o carregamento ocorra apenas uma vez ao abrir o dialog
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  loadDoctorData();
                                                });
                                                return StatefulBuilder(
                                                  builder: (context,
                                                      setStateDialog) {
                                                    return AlertDialog(
                                                      title: Text(strings[
                                                              'PT']![
                                                          'return_of_spontaneous_circulation']!),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  nameController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Nome do Paciente'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  birthController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .datetime,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Data de Nascimento'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  recordController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Número do Prontuário'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  diagnosticController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Diagnóstico'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  comorbiditiesController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Comorbidades'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  doctorController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Nome do Médico Assistente'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  crmController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Registro Médico (CRM)'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            // Validação dos campos obrigatórios
                                                            if (nameController
                                                                    .text
                                                                    .isEmpty ||
                                                                birthController
                                                                    .text
                                                                    .isEmpty ||
                                                                recordController
                                                                    .text
                                                                    .isEmpty ||
                                                                diagnosticController
                                                                    .text
                                                                    .isEmpty ||
                                                                comorbiditiesController
                                                                    .text
                                                                    .isEmpty ||
                                                                doctorController
                                                                    .text
                                                                    .isEmpty ||
                                                                crmController
                                                                    .text
                                                                    .isEmpty) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text('Preencha todos os campos antes de salvar.')));
                                                              return;
                                                            }
                                                            setState(() {
                                                              patientName =
                                                                  nameController
                                                                      .text;
                                                              patientBirth =
                                                                  birthController
                                                                      .text;
                                                              patientRecord =
                                                                  recordController
                                                                      .text;
                                                              diagnostic =
                                                                  diagnosticController
                                                                      .text;
                                                              comorbidities =
                                                                  comorbiditiesController
                                                                      .text;
                                                              doctorName =
                                                                  doctorController
                                                                      .text;
                                                              doctorCrm =
                                                                  crmController
                                                                      .text;
                                                            });
                                                            // Salvar dados do médico no SharedPreferences
                                                            SharedPreferences
                                                                    .getInstance()
                                                                .then((prefs) {
                                                              prefs.setString(
                                                                  'doctorName',
                                                                  doctorController
                                                                      .text);
                                                              prefs.setString(
                                                                  'doctorCrm',
                                                                  crmController
                                                                      .text);
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            stopTimer(
                                                                'return_of_spontaneous_circulation');
                                                            stopWithReason(
                                                                'return_of_spontaneous_circulation');
                                                            final now =
                                                                DateTime.now();
                                                            final clockTime =
                                                                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                                                            setState(() {
                                                              _logEntries.add(
                                                                  '[$clockTime] +${formatTime(secondsElapsed)} → 🩺 Retorno da Circulação Espontânea registrado');
                                                              _logEntries.add(
                                                                  '[$clockTime] +${formatTime(secondsElapsed)} → Cuidados Pós-Parada Iniciados:');
                                                              _logEntries
                                                                  .addAll([
                                                                '• Suporte Neurológico: temperatura 32–36°C, evitar febre, sedação, EEG se necessário',
                                                                '• Suporte Hemodinâmico: PAM ≥ 65 mmHg, ecocardiograma, vasopressores se necessário',
                                                                '• Suporte Respiratório: SpO₂ 92–98%, normocápnia, VM protetora',
                                                                '• Investigação da Causa: ECG 12 deriv., troponina, eletrólitos, coronariografia se indicado',
                                                                '• Monitorização Estratégica: ECG contínuo, capnografia, diurese, lactato',
                                                                '• Avaliação Neurológica: aguardar ≥72h, Glasgow e reflexos troncoencefálicos',
                                                                '• Controle Glicêmico: evitar hiperglicemia (>180 mg/dL), manter alvo 140–180 mg/dL',
                                                              ]);
                                                            });
                                                            // Exibe o diálogo pós-parada no próximo frame para evitar conflitos de contexto
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) =>
                                                                    AlertDialog(
                                                                  title: const Text(
                                                                      "Cuidados Pós-Parada"),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: const [
                                                                        Text(
                                                                            " Suporte Neurológico",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Controle de temperatura (32–36°C por 24h)\n- Evitar febre\n- Sedação e EEG se necessário\n"),
                                                                        Text(
                                                                            " Suporte Hemodinâmico",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- PAM ≥ 65 mmHg\n- Ecocardiograma\n- Vasopressores se necessário\n"),
                                                                        Text(
                                                                            " Suporte Respiratório",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- SpO₂ 92–98%\n- Normocápnia\n- Ventilação protetora\n"),
                                                                        Text(
                                                                            " Investigação da Causa",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- ECG 12 derivações\n- Troponina, eletrólitos\n- Considerar coronariografia\n"),
                                                                        Text(
                                                                            " Monitorização Estratégica",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- ECG contínuo, capnografia, diurese\n- Lactato seriado\n"),
                                                                        Text(
                                                                            " Avaliação Neurológica",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Postergar por ≥72h após sedação\n- Usar Glasgow, reflexos troncoencefálicos\n"),
                                                                        Text(
                                                                            " Controle Glicêmico",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Evitar hiperglicemia (>180 mg/dL)\n- Manter alvo entre 140–180 mg/dL\n"),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    Builder(
                                                                      builder:
                                                                          (innerContext) =>
                                                                              TextButton(
                                                                        child: const Text(
                                                                            "Fechar"),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(innerContext)
                                                                              .pop();
                                                                          Navigator
                                                                              .pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (_) => ResumoEventosScreen(
                                                                                logEntries: List<String>.from(_logEntries),
                                                                                patientName: patientName,
                                                                                patientBirth: patientBirth,
                                                                                patientRecord: patientRecord,
                                                                                diagnostic: diagnostic,
                                                                                comorbidities: comorbidities,
                                                                                doctorName: doctorName,
                                                                                doctorCrm: doctorCrm,
                                                                                patientAge: widget.idade.toString(),
                                                                                patientWeight: widget.peso.toStringAsFixed(1),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          child: const Text(
                                                              'Salvar'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        ListTile(
                                          title: const Text(
                                              'IE: Interrupção dos Esforços'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () async {
                                            Navigator.pop(context);
                                            stopTimer('popup_patient_data');
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                final nameController =
                                                    TextEditingController(
                                                        text: patientName);
                                                final birthController =
                                                    TextEditingController(
                                                        text: patientBirth);
                                                final recordController =
                                                    TextEditingController(
                                                        text: patientRecord);
                                                final diagnosticController =
                                                    TextEditingController(
                                                        text: diagnostic);
                                                final comorbiditiesController =
                                                    TextEditingController(
                                                        text: comorbidities);
                                                final doctorController =
                                                    TextEditingController();
                                                final crmController =
                                                    TextEditingController();
                                                Future<void>
                                                    loadDoctorData() async {
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  doctorController.text =
                                                      prefs.getString(
                                                              'doctorName') ??
                                                          doctorName;
                                                  crmController.text =
                                                      prefs.getString(
                                                              'doctorCrm') ??
                                                          doctorCrm;
                                                }

                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  loadDoctorData();
                                                });

                                                return StatefulBuilder(
                                                  builder: (context,
                                                      setStateDialog) {
                                                    return AlertDialog(
                                                      title: Text(strings[
                                                              'PT']![
                                                          'interruption_of_efforts']!),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  nameController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Nome do Paciente'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  birthController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .datetime,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Data de Nascimento'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  recordController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Número do Prontuário'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  diagnosticController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Diagnóstico'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  comorbiditiesController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Comorbidades'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  doctorController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Nome do Médico Assistente'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  crmController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Registro Médico (CRM)'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              patientName =
                                                                  nameController
                                                                      .text;
                                                              patientBirth =
                                                                  birthController
                                                                      .text;
                                                              patientRecord =
                                                                  recordController
                                                                      .text;
                                                              diagnostic =
                                                                  diagnosticController
                                                                      .text;
                                                              comorbidities =
                                                                  comorbiditiesController
                                                                      .text;
                                                              doctorName =
                                                                  doctorController
                                                                      .text;
                                                              doctorCrm =
                                                                  crmController
                                                                      .text;
                                                            });
                                                            // Salvar dados do médico no SharedPreferences
                                                            SharedPreferences
                                                                    .getInstance()
                                                                .then((prefs) {
                                                              prefs.setString(
                                                                  'doctorName',
                                                                  doctorController
                                                                      .text);
                                                              prefs.setString(
                                                                  'doctorCrm',
                                                                  crmController
                                                                      .text);
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            stopTimer(
                                                                'interruption_of_efforts');
                                                            stopWithReason(
                                                                'interruption_of_efforts');
                                                            final now =
                                                                DateTime.now();
                                                            final clockTime =
                                                                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                                                            setState(() {
                                                              _logEntries.add(
                                                                  '[$clockTime] +${formatTime(secondsElapsed)} → 🩺 Interrupção dos Esforços registrada');
                                                              _logEntries.add(
                                                                  '[$clockTime] +${formatTime(secondsElapsed)} → Constatado óbito e acionado suporte multidisciplinar');
                                                            });
                                                            // Exibe o diálogo SPIKES no próximo frame para evitar conflitos de contexto
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) =>
                                                                    AlertDialog(
                                                                  title: const Text(
                                                                      "Protocolo SPIKES"),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: const [
                                                                        Text(
                                                                            "1. S - Situação",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Verifique local adequado, convide a família para ambiente privativo\n"),
                                                                        Text(
                                                                            "2. P - Percepção",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Pergunte o que a família entende da situação atual\n"),
                                                                        Text(
                                                                            "3. I - Informação",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Dê as informações necessárias com clareza, sem termos técnicos\n"),
                                                                        Text(
                                                                            "4. K - Conhecimento",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Respeite o tempo da família para absorção da notícia\n"),
                                                                        Text(
                                                                            "5. E - Emoção",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Ofereça empatia, escute e acolha reações emocionais\n"),
                                                                        Text(
                                                                            "6. S - Estratégia e Sumário",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text(
                                                                            "- Planeje os próximos passos junto à família\n- Encaminhe ao suporte psicológico, assistência social ou capelania\n"),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    Builder(
                                                                      builder:
                                                                          (innerContext) =>
                                                                              TextButton(
                                                                        child: const Text(
                                                                            "Fechar"),
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(innerContext).pop(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            });
                                                            // Após salvar, navega para a tela de resumo substituindo a tela atual
                                                            Navigator
                                                                .pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ResumoEventosScreen(
                                                                  logEntries: List<
                                                                          String>.from(
                                                                      _logEntries),
                                                                  patientName:
                                                                      patientName,
                                                                  patientBirth:
                                                                      patientBirth,
                                                                  patientRecord:
                                                                      patientRecord,
                                                                  diagnostic:
                                                                      diagnostic,
                                                                  comorbidities:
                                                                      comorbidities,
                                                                  doctorName:
                                                                      doctorName,
                                                                  doctorCrm:
                                                                      doctorCrm,
                                                                  patientAge: widget
                                                                      .idade
                                                                      .toString(),
                                                                  patientWeight:
                                                                      widget
                                                                          .peso
                                                                          .toStringAsFixed(
                                                                              1),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                              'Salvar'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'O ritmo só pode ser avaliado no intervalo da RCP .'),
                                ),
                              );
                            }
                          },
                          shape: const CircleBorder(),
                          fillColor: const Color(0xFFFFA726),
                          constraints: BoxConstraints.tightFor(
                              width: isIOS ? 75 : 84, height: isIOS ? 75 : 84),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFA726),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (showRhythmAlertBorder)
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFDA1E28),
                                    ),
                                  ),
                                if (showRhythmAlertBorder)
                                  Positioned(
                                    bottom: 0,
                                    child: Text(
                                      calcularCargaChoque(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 3,
                                              color: Colors.black)
                                        ],
                                      ),
                                    ),
                                  ),
                                if (showRhythmAlertBorder)
                                  Positioned(
                                    top: 0,
                                    child: Text(
                                      strings[appLanguage]!['charge']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 3,
                                              color: Colors.black)
                                        ],
                                      ),
                                    ),
                                  ),
                                Icon(Icons.monitor_heart,
                                    color: Colors.white, size: isIOS ? 24 : 36),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Topo - botão intubação (alinhado na parte superior da tela), agora apenas ícone

                  Align(
                    alignment: const Alignment(0.0,
                        -0.87), // Pequeno ajuste para cima para melhor visualização
                    child: Padding(
                      // O Padding garante que o botão não encoste na barra do app
                      padding: const EdgeInsets.only(top: 16),
                      child: AnimatedOpacity(
                        opacity: intubationOpacity,
                        duration: const Duration(milliseconds: 400),
                        child: RawMaterialButton(
                          onPressed: () {
                            final now = DateTime.now();
                            final clockTime =
                                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                            setState(() {
                              isIntubated = true;
                              _logEntries.add(
                                  '[$clockTime] +${formatTime(secondsElapsed)} → ${strings[appLanguage]!['intubation_performed']!}');
                              intubationBlinkTimer?.cancel();
                              intubationOpacity = 1.0;
                            });
                          },
                          shape: const CircleBorder(),
                          fillColor:
                              const Color(0xFF2ECC40), // Mantém a forma circula
                          constraints: BoxConstraints.tightFor(
                              width: isIOS ? 75 : 84,
                              height: isIOS
                                  ? 75
                                  : 84), // Ajuste responsivo para iOS
                          child: isIntubated
                              ? const Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 36)
                              : Transform.rotate(
                                  angle: 3.14159, // 180 graus em radianos
                                  child: const Icon(Icons.hardware_outlined,
                                      color: Colors.white, size: 36),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // Lado direito - botão choque (posição mais centralizada)
                  if (!showRhythmButton)
                    Stack(
                      children: [
                        Align(
                          alignment: const Alignment(-0.6, -0.3),
                          child: AnimatedOpacity(
                            opacity: shockOpacity,
                            duration: const Duration(milliseconds: 400),
                            child: RawMaterialButton(
                              fillColor: const Color(0xFFDA1E28),
                              shape: const CircleBorder(),
                              constraints: BoxConstraints.tightFor(
                                  width: isIOS ? 75 : 84,
                                  height: isIOS ? 75 : 84),
                              onPressed: () {
                                final cargaStr = calcularCargaChoque();
                                final now = DateTime.now();
                                final clockTime =
                                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                                setState(() {
                                  _logEntries.add(
                                      '[$clockTime] +${formatTime(secondsElapsed)} → ⚡ ${strings[appLanguage]!['shock']!} ($cargaStr)');
                                  shockCount++;
                                  if (widget.idade < 18) pediatricShockCount++;
                                  showRhythmButton = true;
                                  highlightShock = false;
                                  shockBlinkTimer?.cancel();
                                  shockOpacity = 1.0;
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flash_on,
                                      color: Colors.white, size: 36),
                                  const SizedBox(height: 4),
                                  Text(
                                    calcularCargaChoque(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Novo Positioned para idade/peso canto inferior direito
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            color: Colors.white70,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              'Idade: ${widget.idade} anos | Peso: ${widget.peso.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Centro superior - círculo RCP (simulando compressão torácica)
                  Align(
                    alignment: const Alignment(0.0, -0.45),
                    child: (() {
                      final radius = isIOS ? 35.0 : 42.0;
                      return CircleAvatar(
                        radius: radius,
                        backgroundColor: const Color(0xFFDA1E28),
                        child: SizedBox(
                          width: radius * 2,
                          height: radius * 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(formatTime(secondsElapsed),
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                secondsElapsed < 10
                                    ? strings[appLanguage]!['start_cpr_label']!
                                    : ((showCPRLabel || secondsElapsed < 50)
                                        ? strings[appLanguage]!['cpr']!
                                        : strings[appLanguage]!['switch']!),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    })(),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Text(
                        'Idade: ${widget.idade} anos | Peso: ${widget.peso.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Opacity(
                        opacity: 0.7,
                        child: Container(
                          color: Colors.white70,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                            'Idade: ${widget.idade} anos | Peso: ${widget.peso.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Ícone de troca entre ventilação e RCP
                  if (!showCPRLabel && secondsElapsed >= 60)
                    Align(
                      alignment: const Alignment(0.0, -0.65),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.change_circle,
                            color: Colors.white, size: 60),
                      ),
                    ),
                  Align(
                    alignment: const Alignment(0.6, -0.3),
                    child: AnimatedOpacity(
                      opacity: countdownAdrenaline == 0
                          ? (showAdre ? 1.0 : 0.0)
                          : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: RawMaterialButton(
                        onPressed: () {
                          final peso = widget.peso;
                          final doseAdre =
                              (peso * 0.01).clamp(0, 1.0).toDouble();
                          final doseAmi = (peso * 5).clamp(0, 300).toDouble();
                          final doseLido = (peso * 1).toDouble();
                          final doseBic = (peso * 1).toDouble();
                          final volumeAdre = (doseAdre * 10).toDouble();
                          final volumeAmi = (doseAmi / 50).toDouble();
                          final volumeLido = (doseLido / 10).toDouble();
                          final volumeBic = doseBic.toDouble();
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (_) => _buildMedicationList(
                              doseAdre: doseAdre,
                              doseAmi: doseAmi,
                              doseLido: doseLido,
                              doseBic: doseBic,
                              volumeAdre: volumeAdre,
                              volumeAmi: volumeAmi,
                              volumeLido: volumeLido,
                              volumeBic: volumeBic,
                            ),
                          );
                        },
                        shape: const CircleBorder(),
                        fillColor: const Color(0xFF334E68),
                        constraints: BoxConstraints.tightFor(
                            width: isIOS ? 75 : 84, height: isIOS ? 75 : 84),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            countdownAdrenaline > 0
                                ? Text(
                                    formatTime(countdownAdrenaline),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isIOS ? 11 : 14),
                                    textAlign: TextAlign.center,
                                  )
                                : Icon(Icons.vaccines,
                                    color: Colors.white, size: isIOS ? 24 : 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Botão de Ritmo central sobreposto (exemplo fictício do Stack central)
                  // (procure pelo Positioned do botão de Ritmo central)
                  // Removido ou pode ser ajustado conforme necessidade, pois agora a lógica está acima
                  // --- Adiciona container de eventos recentes no rodapé ---
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.grey.shade200,
                      height: 400, // Altura aumentada de 350 para 450
                      padding: const EdgeInsets.all(
                          18), // Padding aumentado de 16 para 20
                      child: ListView.builder(
                        itemCount: _logEntries.length,
                        itemBuilder: (context, index) {
                          final lastEvents = _logEntries.reversed.toList();
                          final event = lastEvents[index];
                          // Remover emojis para exibição limpa
                          final cleanEvent = event
                              .replaceAll('💉', '')
                              .replaceAll('⚡', '')
                              .replaceAll('🔁', '')
                              .replaceAll('🩺', '')
                              .trim();
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Colors.black12)
                              ],
                            ),
                            child: Text(
                              cleanEvent,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Segundo filho vazio para evitar erro de índice inválido
            SizedBox.shrink(),
          ],
        ));
  }
}

class ResumoEventosScreen extends StatefulWidget {
  final List<String> logEntries;
  final String patientName;
  final String patientBirth;
  final String patientRecord;
  final String diagnostic;
  final String comorbidities;
  final String doctorName;
  final String doctorCrm;
  final String patientAge;
  final String patientWeight;

  const ResumoEventosScreen({
    Key? key,
    required this.logEntries,
    required this.patientName,
    required this.patientBirth,
    required this.patientRecord,
    required this.diagnostic,
    required this.comorbidities,
    required this.doctorName,
    required this.doctorCrm,
    required this.patientAge,
    required this.patientWeight,
  }) : super(key: key);

  @override
  State<ResumoEventosScreen> createState() => _ResumoEventosScreenState();
}

class _ResumoEventosScreenState extends State<ResumoEventosScreen> {
  late String patientName;
  late String patientBirth;
  late String patientRecord;
  late String diagnostic;
  late String comorbidities;
  late String doctorName;
  late String doctorCrm;

  late TextEditingController _nameController;
  late TextEditingController _birthController;
  late TextEditingController _recordController;
  late TextEditingController _diagnosticController;
  late TextEditingController _comorbiditiesController;
  late TextEditingController _doctorController;
  late TextEditingController _crmController;

  @override
  void initState() {
    super.initState();
    patientName = widget.patientName;
    patientBirth = widget.patientBirth;
    patientRecord = widget.patientRecord;
    diagnostic = widget.diagnostic;
    comorbidities = widget.comorbidities;
    doctorName = widget.doctorName;
    doctorCrm = widget.doctorCrm;

    _nameController = TextEditingController(text: patientName);
    _birthController = TextEditingController(text: patientBirth);
    _recordController = TextEditingController(text: patientRecord);
    _diagnosticController = TextEditingController(text: diagnostic);
    _comorbiditiesController = TextEditingController(text: comorbidities);
    _doctorController = TextEditingController(text: doctorName);
    _crmController = TextEditingController(text: doctorCrm);
  }

  Future<bool> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retornar à tela inicial?'),
        content: const Text('Deseja realmente voltar para a tela inicial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showEditDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Editar Dados do Paciente'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nome do Paciente'),
                  ),
                  TextField(
                    controller: _birthController,
                    keyboardType: TextInputType.datetime,
                    decoration:
                        const InputDecoration(labelText: 'Data de Nascimento'),
                  ),
                  TextField(
                    controller: _recordController,
                    decoration: const InputDecoration(
                        labelText: 'Número do Prontuário'),
                  ),
                  TextField(
                    controller: _diagnosticController,
                    decoration: const InputDecoration(labelText: 'Diagnóstico'),
                  ),
                  TextField(
                    controller: _comorbiditiesController,
                    decoration:
                        const InputDecoration(labelText: 'Comorbidades'),
                  ),
                  TextField(
                    controller: _doctorController,
                    decoration: const InputDecoration(
                        labelText: 'Nome do Médico Assistente'),
                  ),
                  TextField(
                    controller: _crmController,
                    decoration: const InputDecoration(
                        labelText: 'Registro Médico (CRM)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    patientName = _nameController.text;
                    patientBirth = _birthController.text;
                    patientRecord = _recordController.text;
                    diagnostic = _diagnosticController.text;
                    comorbidities = _comorbiditiesController.text;
                    doctorName = _doctorController.text;
                    doctorCrm = _crmController.text;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontWeight: FontWeight.w400))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final shouldExit = await _confirmExit();
          if (shouldExit && context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text('Eventos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _confirmExit()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          actions: [
            if (widget.logEntries.any(
                (entry) => entry.contains('Retorno da Circulação Espontânea')))
              IconButton(
                icon: const Icon(Icons.health_and_safety),
                tooltip: 'Cuidados Pós-Parada',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Cuidados Pós-Parada"),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(" Suporte Neurológico",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Controle de temperatura (32–36°C por 24h)\n- Evitar febre\n- Sedação e EEG se necessário\n"),
                            Text(" Suporte Hemodinâmico",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- PAM ≥ 65 mmHg\n- Ecocardiograma\n- Vasopressores se necessário\n"),
                            Text(" Suporte Respiratório",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- SpO₂ 92–98%\n- Normocápnia\n- Ventilação protetora\n"),
                            Text(" Investigação da Causa",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- ECG 12 derivações\n- Troponina, eletrólitos\n- Considerar coronariografia\n"),
                            Text(" Monitorização Estratégica",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- ECG contínuo, capnografia, diurese\n- Lactato seriado\n"),
                            Text(" Avaliação Neurológica",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Postergar por ≥72h após sedação\n- Usar Glasgow, reflexos troncoencefálicos\n"),
                            Text(" Controle Glicêmico",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Evitar hiperglicemia (>180 mg/dL)\n- Manter alvo entre 140–180 mg/dL\n"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Fechar"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (widget.logEntries.any((entry) =>
                entry.contains('Interrupção dos Esforços registrada')))
              IconButton(
                icon: const Icon(Icons.announcement),
                tooltip: 'Protocolo SPIKES',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Protocolo SPIKES"),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("1. S - Situação",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Verifique local adequado, convide a família para ambiente privativo\n"),
                            Text("2. P - Percepção",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Pergunte o que a família entende da situação atual\n"),
                            Text("3. I - Informação",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Dê as informações necessárias com clareza, sem termos técnicos\n"),
                            Text("4. K - Conhecimento",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Respeite o tempo da família para absorção da notícia\n"),
                            Text("5. E - Emoção",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Ofereça empatia, escute e acolha reações emocionais\n"),
                            Text("6. S - Estratégia e Sumário",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "- Planeje os próximos passos junto à família\n- Encaminhe ao suporte psicológico, assistência social ou capelania\n"),
                          ],
                        ),
                      ),
                      actions: [
                        Builder(
                          builder: (innerContext) => TextButton(
                            child: const Text("Fechar"),
                            onPressed: () => Navigator.of(innerContext).pop(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar dados do paciente',
              onPressed: _showEditDialog,
            ),
            // Botão de imprimir removido para simplificar dependências iOS
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dados do Paciente',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              _buildInfoRow('Nome', patientName),
              _buildInfoRow('Data de Nascimento', patientBirth),
              _buildInfoRow('Prontuário', patientRecord),
              _buildInfoRow('Idade', '${widget.patientAge} anos'),
              _buildInfoRow('Peso', '${widget.patientWeight} Kg'),
              _buildInfoRow('Diagnóstico', diagnostic),
              _buildInfoRow('Comorbidades', comorbidities),
              const SizedBox(height: 18),
              Text(strings['PT']!['events_title']!,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(8)),
                  child: widget.logEntries.isEmpty
                      ? Center(
                          child: Text(
                              '— ${strings[appLanguage]!['no_medication']!} —',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey)))
                      : ListView.builder(
                          itemCount: widget.logEntries.length,
                          itemBuilder: (context, index) {
                            final entry = widget.logEntries[index];
                            final regex = RegExp(
                                r'^(\[\\d{2}:\\d{2}:\\d{2}\\]\\s*\\+\\d{2}:\\d{2})\\s*→\\s*(.*)$');
                            final match = regex.firstMatch(entry);
                            final timeAndElapsed = match?.group(1) ?? '';
                            final message = match?.group(2) ?? entry;
                            final cleanMessage = message
                                .replaceAll('💉', '')
                                .replaceAll('⚡', '')
                                .replaceAll('🔁', '')
                                .replaceAll('🩺', '')
                                .trim();
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (timeAndElapsed.isNotEmpty)
                                      Text(
                                        timeAndElapsed,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    const SizedBox(height: 4),
                                    SelectableText(cleanMessage,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showReferencesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Referências Bibliográficas'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: const [
            ListTile(
              leading: Text('1.'),
              title: Text(
                  "Miller RD. Miller’s Anesthesia. 8th ed. Elsevier; 2015."),
            ),
            ListTile(
              leading: Text('2.'),
              title: Text(
                  "Barash PG, Cullen BF, Stoelting RK. Clinical Anesthesia. 7th ed. Lippincott Williams & Wilkins; 2013."),
            ),
            ListTile(
              leading: Text('3.'),
              title: Text(
                  "American Heart Association. Guidelines for CPR and ECC. 2020."),
            ),
            ListTile(
              leading: Text('4.'),
              title: Text(
                  "Butterworth JF, Mackey DC, Wasnick JD. Morgan & Mikhail’s Clinical Anesthesiology. 6th ed. McGraw-Hill; 2018."),
            ),
            ListTile(
              leading: Text('5.'),
              title: Text(
                  "Gan TJ. Anesthesia: A Comprehensive Review. 4th ed. Elsevier; 2017."),
            ),
            ListTile(
              leading: Text('6.'),
              title: Text(
                  "Jaffe RS, Schwab R, Stevens RD. Critical Care Neurology. 2nd ed. Elsevier; 2018."),
            ),
            ListTile(
              leading: Text('7.'),
              title: Text(
                  "Smith I, White PF. Sedation and Analgesia in Intensive Care Medicine. 3rd ed. Springer; 2016."),
            ),
            ListTile(
              leading: Text('8.'),
              title: Text(
                  "Levy JH, Tanaka KA, Refsum EK. Anesthesia and Co-Existing Disease. 5th ed. Elsevier; 2017."),
            ),
            ListTile(
              leading: Text('9.'),
              title: Text(
                  "Morgan GE, Mikhail MS, Murray MJ. Clinical Anesthesiology. 6th ed. McGraw-Hill; 2018."),
            ),
            ListTile(
              leading: Text('10.'),
              title: Text(
                  "Weinger MB, Slagle JM. Handbook of Clinical Anesthesia. 7th ed. Wolters Kluwer; 2019."),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Fechar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
