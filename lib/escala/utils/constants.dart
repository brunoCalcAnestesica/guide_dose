import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryBlue = Color(0xFF1B2A4A);
  static const Color accentBlue = Color(0xFF1A3A6B);
  static const Color highlightBlue = Color(0xFF2563EB);
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF616161);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color accentRed = Color(0xFF8B1A1A);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryDark, Color(0xFF1A1A2E), Color(0xFF3D0C11)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Map<String, Color> shiftTypeColors = {
    'Diurno': Color(0xFF42A5F5),
    'Noturno': Color(0xFF1565C0),
    '24h': Color(0xFFFF8F00),
    'Manhã': Color(0xFF43A047),
    'Tarde': Color(0xFFE53935),
    'Cinderela': Color(0xFF6A1B9A),
    'Extra': Color(0xFF212121),
    'Sobreaviso': Color(0xFFBDBDBD),
    'Procedimento': Color(0xFF2E7D32),
  };

  static Color getShiftTypeColor(String type) {
    return shiftTypeColors[type] ?? mediumGray;
  }

  /// Paleta com cores de alto contraste (hues espaçados ~137.5° no espectro).
  /// Mesmo hospital = mesma cor; hospitais diferentes = cores diferentes.
  static const List<Color> hospitalColors = [
    Color(0xFFE53935), // vermelho
    Color(0xFF43A047), // verde
    Color(0xFF1E88E5), // azul
    Color(0xFFFB8C00), // laranja
    Color(0xFF8E24AA), // roxo
    Color(0xFF00ACC1), // ciano
    Color(0xFF7CB342), // verde-limão
    Color(0xFFD81B60), // magenta
    Color(0xFF5E35B1), // índigo
    Color(0xFFFDD835), // amarelo
    Color(0xFFE91E63), // rosa
    Color(0xFF009688), // teal
    Color(0xFF795548), // marrom
    Color(0xFF1976D2), // azul médio
    Color(0xFF558B2F), // verde escuro
    Color(0xFFAD1457), // pink escuro
    Color(0xFF00838F), // ciano escuro
    Color(0xFF6A1B9A), // violeta
    Color(0xFFF57C00), // laranja escuro
    Color(0xFF303F9F), // índigo escuro
  ];

  /// Atrela cor de forma pseudoaleatória ao hospital quando escrito.
  /// Hospitais com o mesmo nome (idêntico) utilizam a mesma cor.
  static Color getHospitalColor(String hospitalName) {
    if (hospitalName.isEmpty) return highlightBlue;
    final hash = _hashString(hospitalName);
    return hospitalColors[hash % hospitalColors.length];
  }

  /// Hash FNV-1a para distribuição pseudoaleatória: nomes similares
  /// geram índices bem diferentes.
  static int _hashString(String s) {
    const fnvPrime = 0x01000193;
    const fnvOffset = 0x811c9dc5;
    var h = fnvOffset;
    for (var i = 0; i < s.length; i++) {
      h ^= s.codeUnitAt(i);
      h = (h * fnvPrime) & 0xFFFFFFFF;
    }
    return h.abs();
  }
}

class AppStrings {
  static const String appTitle = 'Guide Escala ®';
  static const String calendarTab = 'Calendário';
  static const String historyTab = 'Produção';
  static const String filterAll = 'Todos';
  static const String filterShifts = 'Plantões';
  static const String filterProcedures = 'Procedimentos';
  static const String filterButton = 'Filtros';
  static const String filterTitle = 'Filtrar produção';
  static const String filterDisplayType = 'Exibir';
  static const String filterByHospital = 'Hospital';
  static const String filterByProcedureType = 'Tipo de procedimento';
  static const String filterDateRange = 'Intervalo de datas';
  static const String filterDateStart = 'Data inicial';
  static const String filterDateEnd = 'Data final';
  static const String filterClear = 'Limpar filtros';
  static const String filterApply = 'Aplicar';
  static const String filterActiveLabel = 'Filtros ativos';
  static const String filterActiveTooltip = 'Filtros ativos. Toque para editar.';
  static const String hospitalsTab = 'Hospitais';
  static const String today = 'Hoje';
  static const String noShiftsForDay = 'Este dia não possui escalas registradas';
  static const String noShiftsForMonth = 'Nenhuma escala encontrada';
  static const String noShiftsForMonthSubtitle =
      'Este mês não possui escalas registradas';
  static const String noHospitals = 'Nenhum hospital cadastrado';
  static const String noHospitalsSubtitle =
      'Toque no + para adicionar um novo hospital';
  static const String yourHospitals = 'Seus Hospitais';
  static const String addHospital = 'Adicionar Hospital';
  static const String editHospital = 'Editar Hospital';
  static const String hospitalName = 'Nome do Hospital';
  static const String hospitalColor = 'Cor';
  static const String addShift = 'Adicionar Escala';
  static const String editShift = 'Editar Escala';
  static const String hospital = 'Hospital / Clínica';
  static const String date = 'Data';
  static const String startTime = 'Hora Início';
  static const String endTime = 'Hora Fim';
  static const String shiftValue = 'Valor (R\$)';
  static const String shiftInformations = 'Informações';
  static const String shiftType = 'Tipo';
  static const String completed = 'Pago';
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String deleteConfirm = 'Tem certeza que deseja excluir?';
  static const String yes = 'Sim';
  static const String no = 'Não';
  static const String shifts = 'Plantões:';
  static const String completedShifts = 'Pagos:';
  static const String pendingShifts = 'À Realizar:';
  static const String pendingValueLabel = 'A receber:';
  static const String completedShiftsCircle = 'Plantões\nPagos';
  static const String financialProgress = 'Progresso\nFinanceiro';
  static const String progressHintPending = 'Marque como pago quando receber.';
  static const String selectHospital = 'Selecione um hospital';
  static const String requiredField = 'Campo obrigatório';
  static const String saveError = 'Não foi possível salvar. Tente novamente.';
  static const String deleteError = 'Não foi possível excluir. Tente novamente.';

  static const List<String> shiftTypes = [
    'Diurno',
    'Noturno',
    '24h',
    'Manhã',
    'Tarde',
    'Cinderela',
    'Extra',
    'Sobreaviso',
    'Procedimento',
  ];

  // Recorrencia
  static const String recurrence = 'Repetir';
  static const String recurrenceNone = 'Não se repete';
  static const String recurrenceDaily = 'Todos os dias';
  static const String recurrenceWeekly = 'Toda semana';
  static const String recurrenceMonthly = 'Todo mês';
  static const String recurrenceYearly = 'Todo ano';
  static const String recurrenceWeekdays = 'Dias úteis (seg a sex)';
  static const String recurrenceCustom = 'Personalizado...';
  static const String customRecurrenceTitle = 'Recorrência personalizada';
  static const String every = 'A cada';
  static const String days = 'dia(s)';
  static const String weeks = 'semana(s)';
  static const String months = 'mês(es)';
  static const String years = 'ano(s)';
  static const String endsLabel = 'Termina';
  static const String endsNever = 'Nunca';
  static const String endsOnDate = 'Em';
  static const String endsAfterCount = 'Após';
  static const String occurrences = 'ocorrências';
  static const String done = 'Concluir';
  static const String editRecurringTitle = 'Escala recorrente';
  static const String editOnlyThis = 'Somente esta escala';
  static const String editThisAndFollowing = 'Este e os próximos plantões';
  static const String editAllInSeries = 'Todos os plantões da série';
  static const String editOnlyThisShift = 'Editar apenas este plantão';
  static const String deleteOnlyThis = 'Excluir apenas este plantão';
  static const String deleteRecurringTitle = 'Excluir escala recorrente';

  static const List<String> weekDayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  static const List<String> weekDayLabelsFull = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];

  // Tipo de evento
  static const String eventTypeShift = 'Escala';
  static const String eventTypeProcedure = 'Procedimento';
  static const String eventTypeBlock = 'Bloquear';
  static const String blockLabelFeriado = 'Feriado';
  static const String addBlockTitle = 'Bloquear dia';
  static const String blockLabelHint = 'Ex.: Feriado, Folga';
  static const String blockModeSingle = 'Dia individual';
  static const String blockModeRange = 'Intervalo de dias';
  static const String blockWarningShiftsTitle = 'Plantões nos dias bloqueados';
  static const String blockWarningShiftsMessage =
      'Existem plantões marcados nestes dias. Lembre-se de repassar os plantões.';
  static const String blockAnyway = 'Bloquear mesmo assim';
  static const String shiftRepassReminder = 'Lembrete: repassar escala';
  static const String repassNotificationTitle = 'Plantões / procedimentos para repassar';
  static const String repassNotificationBody =
      'Existem plantões ou procedimentos em dias bloqueados na agenda. Lembre-se de repassar.';

  // Procedimento
  static const String addProcedure = 'Adicionar Procedimento';
  static const String editProcedure = 'Editar Procedimento';
  static const String procedureTypeLabel = 'Tipo de Procedimento';
  static const String settingsScreenTitle = 'Configurações da Escala';
  static const String settingsHospitals = 'Hospitais';
  static const String settingsProcedureTypes = 'Tipos de procedimento';
  static const String settingsBlockedDays = 'Dias bloqueados';
  static const String noBlockedDays = 'Nenhum dia bloqueado';
  static const String noBlockedDaysSubtitle = 'Toque em + para bloquear um dia';
  static const String procedureValue = 'Valor (R\$)';
  static const String selectProcedureType = 'Selecione o tipo';

  // CRUD Tipo de Procedimento
  static const String addProcedureType = 'Adicionar Tipo';
  static const String editProcedureType = 'Editar Tipo';
  static const String procedureTypeName = 'Nome do Procedimento';
  static const String defaultValueLabel = 'Valor Padrão (R\$)';

  // Recorrencia mensal por semana
  static const List<String> ordinalLabels = [
    '1º',
    '2º',
    '3º',
    '4º',
    '5º',
  ];
  static const String lastOrdinal = 'último';

  /// Calcula a posicao ordinal do dia da semana dentro do mes.
  /// Ex: 17/01/2026 (sabado) -> 3 (3o sabado do mes)
  static int weekdayOccurrenceInMonth(DateTime date) {
    int count = 0;
    for (int d = 1; d <= date.day; d++) {
      if (DateTime(date.year, date.month, d).weekday == date.weekday) {
        count++;
      }
    }
    return count;
  }

  /// Retorna o label ordinal: "3º sábado", "1º segunda-feira", etc.
  static String monthlyWeekdayLabel(DateTime date) {
    final occurrence = weekdayOccurrenceInMonth(date);
    final dayName = weekDayLabelsFull[date.weekday - 1];
    if (occurrence <= 5) {
      return 'Todo ${ordinalLabels[occurrence - 1]} $dayName do mês';
    }
    return 'Todo $lastOrdinal $dayName do mês';
  }

  // Divisor de plantão
  static const String shiftDividerTitle = 'Divisor de Plantão';
  static const String shiftDividerCurrentTime = 'Hora atual';
  static const String shiftDividerEndTime = 'Hora fim do plantão';
  static const String shiftDividerMethod = 'Tipo de divisão';
  static const String shiftDividerEqualBlocks = 'Blocos iguais';
  static const String shiftDividerFixedInterval = 'Intervalo fixo';
  static const String shiftDividerBlockCount = 'Número de blocos';
  static const String shiftDividerInterval = 'Intervalo';
  static const String shiftDividerCalculate = 'Calcular';
  static const String shiftDividerTotalRemaining = 'Tempo restante';
  static const String shiftDividerMissingEnd = 'Informe a hora de término do plantão';
  static const String shiftDividerMissingBlocks = 'Informe o número de blocos';
  static const String shiftDividerMissingInterval = 'Selecione o intervalo';
}
