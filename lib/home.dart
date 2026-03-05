import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_manager.dart';
import 'shared_data.dart';
import 'formatters.dart';
import 'fisiologia.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'inducao.dart';
import 'pcr.dart';
import 'medical_ai_screen.dart';
import 'configuracoes_page.dart';
import 'medicamento_unificado/medicamento_unificado_page.dart';
import 'escala/screens/day_detail_screen.dart';
import 'escala/screens/escala_page.dart';
import 'escala/screens/notes_and_patients_screen.dart';
import 'escala/screens/shift_divider_screen.dart';
import 'escala/services/repass_reminder_notification_service.dart';
import 'main.dart';
import 'widgets/update_available_dialog.dart';
import 'widgets/broadcast_message_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class MinhaPagina extends StatelessWidget {
  const MinhaPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '+ ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'Guide Dose ®',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.mail_outline,
              color: Colors.white,
            ),
            tooltip: 'Queremos saber sua opinião. Ajude-nos a melhorar.',
            onPressed: () async {
              // Funcionalidade de email removida - mostrando informações de contato
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Contato'),
                    content: const Text(
                        'Para sugestões e feedback, entre em contato através do email: brunodaroz@exemplo.com'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Conteúdo da página'),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _inducaoRefreshToken = 0;
  int _fisiologiaRefreshToken = 0;
  int _calculosRefreshToken = 0;
  bool _pacientePopupAberto = false;

  // Timer para debounce na edição do paciente (otimização de performance)
  Timer? _debounceTimer;

  final TextEditingController _pesoAtualController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _creatininaController = TextEditingController();

  String _idadeTipo = 'anos'; // 'dias', 'meses', 'anos'
  String? _faixaEtaria;
  String _sexoSelecionado = 'Masculino';

  void _abrirPacientePopup() {
    if (_pacientePopupAberto) return;
    _pacientePopupAberto = true;
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
          child: Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = MediaQuery.of(context).size.height * 0.8;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 360,
                    maxHeight: constraints.maxHeight < maxHeight
                        ? constraints.maxHeight
                        : maxHeight,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: _buildPacienteForm(),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      _pacientePopupAberto = false;
      final atualizou = _atualizarDadosSilencioso();
      if (!mounted || !atualizou) return;
      setState(() {
        _faixaEtaria = SharedData.faixaEtaria;
        _fisiologiaRefreshToken += 1;
        _inducaoRefreshToken += 1;
        _calculosRefreshToken += 1;
      });
    });
  }

  bool _atualizarDadosSilencioso() {
    double? idadeBruta =
        double.tryParse(_idadeController.text.replaceAll(',', '.'));
    double? pesoBruto =
        double.tryParse(_pesoAtualController.text.replaceAll(',', '.'));
    double? alturaBruta =
        double.tryParse(_alturaController.text.replaceAll(',', '.'));

    if (idadeBruta == null || pesoBruto == null || alturaBruta == null) {
      return false;
    }

    // Peso e Altura
    SharedData.peso = pesoBruto;
    SharedData.altura = alturaBruta;

    // Idade convertida
    if (_idadeTipo == 'dias') {
      SharedData.idade = idadeBruta / 365.0;
    } else if (_idadeTipo == 'meses') {
      SharedData.idade = idadeBruta / 12.0;
    } else {
      SharedData.idade = idadeBruta;
    }

    // Sexo e tipo de idade
    SharedData.sexo = _sexoSelecionado;
    SharedData.idadeTipo = _idadeTipo;

    // Creatinina (opcional - null significa função renal normal)
    final creatininaText =
        _creatininaController.text.trim().replaceAll(',', '.');
    SharedData.creatinina =
        creatininaText.isEmpty ? null : double.tryParse(creatininaText);

    // Salvar no dispositivo
    _savePacientePreferences();

    return true;
  }

  void _atualizarDados() {
    double? idadeBruta =
        double.tryParse(_idadeController.text.replaceAll(',', '.'));
    double? pesoBruto =
        double.tryParse(_pesoAtualController.text.replaceAll(',', '.'));
    double? alturaBruta =
        double.tryParse(_alturaController.text.replaceAll(',', '.'));

    setState(() {
      if (idadeBruta == null || pesoBruto == null || alturaBruta == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos corretamente.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Peso e Altura
      SharedData.peso = pesoBruto;
      SharedData.altura = alturaBruta;

      // Idade convertida
      if (_idadeTipo == 'dias') {
        SharedData.idade = idadeBruta / 365.0;
      } else if (_idadeTipo == 'meses') {
        SharedData.idade = idadeBruta / 12.0;
      } else {
        SharedData.idade = idadeBruta;
      }

      // Sexo e tipo de idade
      SharedData.sexo = _sexoSelecionado;
      SharedData.idadeTipo = _idadeTipo;

      // Creatinina (opcional - null significa função renal normal)
      final creatininaText =
          _creatininaController.text.trim().replaceAll(',', '.');
      SharedData.creatinina =
          creatininaText.isEmpty ? null : double.tryParse(creatininaText);

      // Faixa etária
      _faixaEtaria = SharedData.faixaEtaria;

      // Salvar no dispositivo
      _savePacientePreferences();

      // Garante que o teclado virtual seja fechado após preencher os campos e atualizar os dados.
      FocusScope.of(context).unfocus();

      // Atualiza todas as abas (mantém a aba atual)
      _fisiologiaRefreshToken += 1;
      _inducaoRefreshToken += 1;
      _calculosRefreshToken += 1;
    });

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _savePacientePreferences() async {
    try {
      await StorageManager.instance.initialize();
      await StorageManager.instance.setDouble('peso', SharedData.peso ?? 0);
      await StorageManager.instance.setDouble('altura', SharedData.altura ?? 0);
      await StorageManager.instance.setDouble('idade', SharedData.idade ?? 0);
      await StorageManager.instance.setString('sexo', SharedData.sexo);
      await StorageManager.instance
          .setString('idadeTipo', SharedData.idadeTipo);
      // Creatinina: salva -1 se não informada (null)
      await StorageManager.instance
          .setDouble('creatinina', SharedData.creatinina ?? -1);
    } catch (e) {
      // Se houver erro, continua sem salvar
      // Erro silencioso para não impactar o usuário
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarPacientePreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final pendingDate = WidgetDeepLink.pendingDate;
      if (pendingDate != null) {
        WidgetDeepLink.pendingDate = null;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DayDetailScreen(date: pendingDate)),
        );
        return;
      }
      final pendingRoute = WidgetDeepLink.pendingRoute;
      if (pendingRoute != null) {
        WidgetDeepLink.pendingRoute = null;
        Widget? screen;
        switch (pendingRoute) {
          case 'divider':
            screen = const ShiftDividerScreen();
          case 'ai':
            screen = const MedicalAIScreen();
          case 'notes':
            screen = const NotesAndPatientsScreen();
        }
        if (screen != null) {
          final target = screen;
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
          return;
        }
      }
      await UpdateAvailableDialog.showIfNeeded(context);
      if (!mounted) return;
      await BroadcastMessageDialog.showIfNeeded(context);
      if (!mounted) return;
      if (await RepassReminderNotificationService
          .wasLaunchedByRepassNotification()) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EscalaPage()),
        );
      }
    });
    // Ao abrir o app: se o usuário encerrou na tela Escala, abrir direto na Escala.
    // O popup de Dados do Paciente não abre mais automaticamente.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await StorageManager.instance.initialize();
      final fechouNaEscala = StorageManager.instance
          .getBool('restore_escala', defaultValue: false);
      if (fechouNaEscala) {
        await StorageManager.instance.setBool('restore_escala', false);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EscalaPage()),
        );
      }
    });
    // Removido: verificação automática de cadastro ao iniciar
    // A edição do cadastro está disponível nas configurações (engrenagem)
  }

  Future<void> _carregarPacientePreferences() async {
    try {
      await StorageManager.instance.initialize();

      var pesoCarregado = StorageManager.instance.getDouble('peso');
      var alturaCarregada = StorageManager.instance.getDouble('altura');
      var idadeCarregada = StorageManager.instance.getDouble('idade');
      var sexoCarregado = StorageManager.instance.getString('sexo');
      var idadeTipoCarregado = StorageManager.instance.getString('idadeTipo');
      var creatininaCarregada = StorageManager.instance.getDouble('creatinina');

      final usarPadrao =
          pesoCarregado <= 0 || alturaCarregada <= 0 || idadeCarregada <= 0;

      if (usarPadrao) {
        pesoCarregado = 70;
        alturaCarregada = 176;
        idadeCarregada = 33;
        sexoCarregado = 'Masculino';
        idadeTipoCarregado = 'anos';
      }

      setState(() {
        SharedData.peso = pesoCarregado;
        SharedData.altura = alturaCarregada;
        SharedData.idade = idadeCarregada;
        SharedData.sexo = sexoCarregado != '' ? sexoCarregado : 'Masculino';
        SharedData.idadeTipo =
            idadeTipoCarregado != '' ? idadeTipoCarregado : 'anos';
        // Creatinina: -1 ou <= 0 significa não informada
        SharedData.creatinina =
            (creatininaCarregada > 0) ? creatininaCarregada : null;

        _pesoAtualController.text = SharedData.peso!.round().toString();
        _alturaController.text = SharedData.altura!.round().toString();
        _idadeController.text = _formatarValorIdadeOriginal(
            SharedData.idade!, SharedData.idadeTipo);
        _creatininaController.text = SharedData.creatinina != null
            ? SharedData.creatinina!.toStringAsFixed(1).replaceAll('.', ',')
            : '';
        _sexoSelecionado = SharedData.sexo;
        _idadeTipo = SharedData.idadeTipo;
        _faixaEtaria = SharedData.faixaEtaria;
        _calculosRefreshToken += 1;
      });

      if (usarPadrao) {
        await _savePacientePreferences();
      }
    } catch (e) {
      // Se houver erro, usa valores padrão
      setState(() {
        SharedData.sexo = 'Masculino';
        SharedData.idadeTipo = 'anos';
        _sexoSelecionado = 'Masculino';
        _idadeTipo = 'anos';
      });
    }
  }

  String _formatarValorIdadeOriginal(double idadeEmAnos, String tipo) {
    if (tipo == 'dias') return (idadeEmAnos * 365).round().toString();
    if (tipo == 'meses') return (idadeEmAnos * 12).round().toString();
    return idadeEmAnos.round().toString();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pesoAtualController.dispose();
    _alturaController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guide Dose ®',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leadingWidth: 96,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Escala',
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                await StorageManager.instance.setBool('restore_escala', true);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EscalaPage()),
                ).then((_) {
                  StorageManager.instance.setBool('restore_escala', false);
                });
              },
            ),
            IconButton(
              tooltip: 'Divisor de plantão',
              icon: const Icon(Icons.splitscreen),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShiftDividerScreen()),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Anotações',
            icon: const Icon(Icons.note_alt_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotesAndPatientsScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Configuracoes',
            icon: const Icon(Icons.settings),
            onPressed: _abrirMenuConfiguracoes,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPacienteInfoHeader(),
          Expanded(
            child: _buildCurrentPage(),
          ),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicalAIScreen()),
            );
          },
          tooltip: 'IA',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.auto_awesome),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 56,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildNavItem(
                      icon: Icons.health_and_safety,
                      label: 'Fisiologia',
                      index: 0)),
              Expanded(
                  child: _buildNavItem(
                      icon: Icons.medication, label: 'Medicamento', index: 1)),
              Expanded(
                  child: _buildNavItem(
                      icon: Icons.vaccines, label: 'Intubação', index: 2)),
              Expanded(
                  child: _buildNavItem(
                      icon: Icons.monitor_heart, label: 'PCR', index: 3)),
              Expanded(
                  child: const SizedBox
                      .shrink()), // slot do FAB (distribuição homogênea)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        FisiologiaPage(
          key: ValueKey('fisiologia_$_fisiologiaRefreshToken'),
        ),
        MedicamentoUnificadoPage(
          key: ValueKey('calculos_$_calculosRefreshToken'),
        ),
        InducaoPage(
          key: ValueKey('inducao_$_inducaoRefreshToken'),
        ),
        PcrPage(
          key: ValueKey('pcr_$_calculosRefreshToken'),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey;

    return InkWell(
      onTap: () {
        if (SharedData.peso == null ||
            SharedData.altura == null ||
            SharedData.idade == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preencha os dados do paciente para continuar.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.cardPadding,
          AppSpacing.sm + 2, AppSpacing.cardPadding, AppSpacing.cardPadding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth:
              400, // Limita o tamanho para não ficar esticado em telas grandes
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dados do Paciente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // << Peso e Altura na mesma linha
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesoAtualController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}([.,]?\d{0,3})?$')),
                      PesoMaximo200Com3DecimaisFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onChanged: (_) => _atualizarPacienteEmEdicao(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _alturaController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}([.,]?\d{0,3})?$')),
                      AlturaMaxima220Com3DecimaisFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Altura (cm)',
                      prefixIcon: Transform.rotate(
                        angle: 90 * 3.14159 / 180, // 90 graus em radianos
                        child: Icon(Icons.straighten),
                      ),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      floatingLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onChanged: (_) => _atualizarPacienteEmEdicao(),
                  ),
                ),
              ],
            ),

            // << Idade, Tipo e Sexo na mesma linha
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _idadeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          2), // Máximo de 2 dígitos
                      FilteringTextInputFormatter
                          .digitsOnly, // Apenas números inteiros (sem vírgulas ou pontos)
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Idade',
                      prefixIcon: Icon(Icons.cake),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onChanged: (_) => _atualizarPacienteEmEdicao(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _idadeTipo,
                    decoration: const InputDecoration(
                      labelText: 'D/M/A',
                      prefixIcon: Icon(Icons.calendar_today),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'dias',
                        child: Text('Dias', style: TextStyle(fontSize: 16)),
                      ),
                      DropdownMenuItem(
                        value: 'meses',
                        child: Text('Meses', style: TextStyle(fontSize: 16)),
                      ),
                      DropdownMenuItem(
                        value: 'anos',
                        child: Text('Anos', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      _idadeTipo = value;
                      _atualizarPacienteEmEdicao();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // << Sexo e Creatinina na mesma linha
            Row(
              children: [
                // Sexo
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _sexoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    selectedItemBuilder: (context) {
                      return [
                        _buildSexoDropdownItem(
                          label: 'Masculino',
                          icon: Icons.male,
                          iconColor: Colors.blue,
                          centered: true,
                        ),
                        _buildSexoDropdownItem(
                          label: 'Feminino',
                          icon: Icons.female,
                          iconColor: Colors.pink,
                          centered: true,
                        ),
                      ];
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Masculino',
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.male, color: Colors.blue, size: 16),
                              SizedBox(width: 6),
                              Text('Masculino', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Feminino',
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.female, color: Colors.pink, size: 16),
                              SizedBox(width: 6),
                              Text('Feminino', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      _sexoSelecionado = value;
                      _atualizarPacienteEmEdicao();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _atualizarDados,
              icon: const Icon(Icons.check_circle),
              label:
                  const Text('Atualizar Dados', style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            if (_faixaEtaria != null)
              Text(
                'Faixa Etária: $_faixaEtaria',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacienteInfoHeader() {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: InkWell(
        onTap: _abrirPacientePopup,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Idade', _formatarIdade()),
              _buildInfoItem(
                  'Peso',
                  SharedData.peso != null
                      ? '${SharedData.peso!.round()} kg'
                      : '-'),
              _buildInfoItem(
                  'Altura',
                  SharedData.altura != null
                      ? '${SharedData.altura!.round()} cm'
                      : '-'),
              // FR (função renal) oculto até conferência dos medicamentos
              // _buildInfoItem('FR', _formatarFuncaoRenal()),
              _buildInfoItem('Faixa', SharedData.faixaEtaria),
              _buildSexoInfoItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSexoInfoItem() {
    IconData icon = SharedData.sexo == 'Feminino' ? Icons.female : Icons.male;
    Color color = SharedData.sexo == 'Feminino' ? Colors.pink : Colors.blue;

    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(
          SharedData.sexo,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _atualizarPacienteEmEdicao() {
    final idadeBruta =
        double.tryParse(_idadeController.text.replaceAll(',', '.'));
    final pesoBruto =
        double.tryParse(_pesoAtualController.text.replaceAll(',', '.'));
    final alturaBruta =
        double.tryParse(_alturaController.text.replaceAll(',', '.'));

    // Atualiza os dados imediatamente no SharedData (sem setState)
    if (pesoBruto != null) {
      SharedData.peso = pesoBruto;
    }
    if (alturaBruta != null) {
      SharedData.altura = alturaBruta;
    }
    if (idadeBruta != null) {
      if (_idadeTipo == 'dias') {
        SharedData.idade = idadeBruta / 365.0;
      } else if (_idadeTipo == 'meses') {
        SharedData.idade = idadeBruta / 12.0;
      } else {
        SharedData.idade = idadeBruta;
      }
    }

    final creatininaText =
        _creatininaController.text.trim().replaceAll(',', '.');
    SharedData.creatinina =
        creatininaText.isEmpty ? null : double.tryParse(creatininaText);

    SharedData.sexo = _sexoSelecionado;
    SharedData.idadeTipo = _idadeTipo;

    // Debounce: aguarda 300ms após a última alteração para atualizar UI
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _faixaEtaria = SharedData.faixaEtaria;
        _fisiologiaRefreshToken += 1;
        _inducaoRefreshToken += 1;
        _calculosRefreshToken += 1;
      });
    });

    if (pesoBruto != null && alturaBruta != null && idadeBruta != null) {
      _savePacientePreferences();
    }
  }

  Widget _buildSexoDropdownItem({
    required String label,
    required IconData icon,
    required Color iconColor,
    bool centered = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
    if (!centered) return content;
    return Center(child: content);
  }

  void _abrirMenuConfiguracoes() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConfiguracoesPage(),
      ),
    );
  }
}

String _formatarIdade() {
  if (SharedData.idade == null) return '-';
  double idade = SharedData.idade!;

  if (SharedData.idadeTipo == 'dias') {
    int dias = (idade * 365).round();
    return '$dias dias';
  } else if (SharedData.idadeTipo == 'meses') {
    int meses = (idade * 12).round();
    return '$meses meses';
  } else {
    return '${idade.round()} anos';
  }
}

