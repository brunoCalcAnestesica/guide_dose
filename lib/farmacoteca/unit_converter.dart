// Sistema automático de conversão de unidades
class UnitConverter {
  // Unidades de massa/peso
  static const Map<String, double> massUnits = {
    'mcg': 1.0,
    'mg': 1000.0,
    'g': 1000000.0,
    'kg': 1000000000.0,
  };

  // Unidades de volume
  static const Map<String, double> volumeUnits = {
    'mL': 1.0,
    'L': 1000.0,
  };

  // Unidades de tempo
  static const Map<String, double> timeUnits = {
    'min': 1.0,
    'h': 60.0,
    's': 1/60.0,
  };

  /// Converte uma unidade de massa para mcg
  static double convertMassToMcg(double value, String fromUnit) {
    final unit = fromUnit.toLowerCase();
    final factor = massUnits[unit] ?? 1.0;
    return value * factor;
  }

  /// Converte uma unidade de massa para mg
  static double convertMassToMg(double value, String fromUnit) {
    final mcg = convertMassToMcg(value, fromUnit);
    return mcg / 1000.0;
  }

  /// Converte uma unidade de volume para mL
  static double convertVolumeToMl(double value, String fromUnit) {
    final unit = fromUnit.toLowerCase();
    final factor = volumeUnits[unit] ?? 1.0;
    return value * factor;
  }

  /// Converte uma unidade de tempo para minutos
  static double convertTimeToMinutes(double value, String fromUnit) {
    final unit = fromUnit.toLowerCase();
    final factor = timeUnits[unit] ?? 1.0;
    return value * factor;
  }

  /// Converte uma unidade de tempo para horas
  static double convertTimeToHours(double value, String fromUnit) {
    final minutes = convertTimeToMinutes(value, fromUnit);
    return minutes / 60.0;
  }

  /// Detecta e extrai unidades de uma string
  static Map<String, String> extractUnits(String text) {
    final units = <String, String>{};
    
    // Padrões para detectar unidades
    final patterns = {
      'mass': RegExp(r'\b(\d+(?:\.\d+)?)\s*(mcg|mg|g|kg)\b', caseSensitive: false),
      'volume': RegExp(r'\b(\d+(?:\.\d+)?)\s*(mL|L|ml|l)\b', caseSensitive: false),
      'time': RegExp(r'\b(\d+(?:\.\d+)?)\s*(min|h|s|minuto|hora|segundo)\b', caseSensitive: false),
      'concentration': RegExp(r'\b(\d+(?:\.\d+)?)\s*(mcg/mL|mg/mL|g/L|mg/L|mcg/L)\b', caseSensitive: false),
    };

    for (final entry in patterns.entries) {
      final matches = entry.value.allMatches(text);
      for (final match in matches) {
        if (match.groupCount >= 2) {
          units[entry.key] = match.group(2)?.toLowerCase() ?? '';
        }
      }
    }

    return units;
  }

  /// Detecta unidades em uma string de concentração
  static String detectConcentrationUnit(String concentrationText) {
    final patterns = [
      RegExp(r'mcg/mL', caseSensitive: false),
      RegExp(r'mg/mL', caseSensitive: false),
      RegExp(r'g/mL', caseSensitive: false),
      RegExp(r'UI/mL', caseSensitive: false),
      RegExp(r'g/L', caseSensitive: false),
      RegExp(r'mg/L', caseSensitive: false),
      RegExp(r'mcg/L', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(concentrationText)) {
        return pattern.firstMatch(concentrationText)?.group(0)?.toLowerCase() ?? '';
      }
    }

    return '';
  }

  /// Detecta unidades de dose
  static String detectDoseUnit(String doseUnit) {
    final patterns = [
      // Padrões específicos para infusões contínuas (ordem de prioridade)
      RegExp(r'mcg/kg/min', caseSensitive: false),
      RegExp(r'mcg/kg/h', caseSensitive: false),
      RegExp(r'mg/kg/min', caseSensitive: false),
      RegExp(r'mg/kg/h', caseSensitive: false),
      RegExp(r'UI/kg/h', caseSensitive: false),
      RegExp(r'UI/kg/min', caseSensitive: false),
      RegExp(r'g/kg/h', caseSensitive: false),
      RegExp(r'g/kg/min', caseSensitive: false),
      // Padrões para infusões por tempo (sem peso)
      RegExp(r'UI/min', caseSensitive: false),
      RegExp(r'UI/h', caseSensitive: false),
      RegExp(r'mg/h', caseSensitive: false),
      RegExp(r'mg/min', caseSensitive: false),
      RegExp(r'mcg/h', caseSensitive: false),
      RegExp(r'mcg/min', caseSensitive: false),
      RegExp(r'g/h', caseSensitive: false),
      RegExp(r'g/min', caseSensitive: false),
      RegExp(r'mg/dia', caseSensitive: false),
      RegExp(r'mcg/dia', caseSensitive: false),
      // Padrões genéricos (menor prioridade)
      RegExp(r'mg', caseSensitive: false),
      RegExp(r'mcg', caseSensitive: false),
      RegExp(r'UI', caseSensitive: false),
      RegExp(r'g', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(doseUnit)) {
        return pattern.firstMatch(doseUnit)?.group(0)?.toLowerCase() ?? '';
      }
    }

    return '';
  }

  /// Detecta se a unidade é uma infusão contínua
  static bool isInfusionUnit(String doseUnit) {
    final unit = doseUnit.toLowerCase();
    // Apenas unidades que claramente indicam infusão contínua
    return unit.contains('/kg/min') || 
           unit.contains('/kg/h') || 
           unit.contains('/min') || 
           unit.contains('/h') ||
           unit.contains('/dia');
  }

  /// Detecta o tipo específico de infusão
  static String detectInfusionType(String doseUnit) {
    final unit = doseUnit.toLowerCase();
    
    // Infusões por peso e tempo
    if (unit.contains('mcg/kg/min')) {
      return 'mcg/kg/min';
    } else if (unit.contains('mcg/kg/h')) {
      return 'mcg/kg/h';
    } else if (unit.contains('mg/kg/min')) {
      return 'mg/kg/min';
    } else if (unit.contains('mg/kg/h')) {
      return 'mg/kg/h';
    } else if (unit.contains('ui/kg/min')) {
      return 'UI/kg/min';
    } else if (unit.contains('ui/kg/h')) {
      return 'UI/kg/h';
    } else if (unit.contains('g/kg/min')) {
      return 'g/kg/min';
    } else if (unit.contains('g/kg/h')) {
      return 'g/kg/h';
    }
    // Infusões por tempo (sem peso)
    else if (unit.contains('ui/min')) {
      return 'UI/min';
    } else if (unit.contains('ui/h')) {
      return 'UI/h';
    } else if (unit.contains('mg/h')) {
      return 'mg/h';
    } else if (unit.contains('mg/min')) {
      return 'mg/min';
    } else if (unit.contains('mcg/h')) {
      return 'mcg/h';
    } else if (unit.contains('mcg/min')) {
      return 'mcg/min';
    } else if (unit.contains('g/h')) {
      return 'g/h';
    } else if (unit.contains('g/min')) {
      return 'g/min';
    } else if (unit.contains('mg/dia')) {
      return 'mg/dia';
    } else if (unit.contains('mcg/dia')) {
      return 'mcg/dia';
    }
    // Casos especiais para unidades que podem ser infusões
    else if (unit == 'mg') {
      return 'mg/h'; // Assumir mg/h para infusões com mg
    } else if (unit == 'mcg/kg') {
      return 'mcg/kg/h'; // Assumir mcg/kg/h para infusões com mcg/kg
    }
    
    return '';
  }

  /// Normaliza uma concentração para mcg/mL
  static double normalizeConcentrationToMcgPerMl(double value, String concentrationText) {
    final unit = detectConcentrationUnit(concentrationText);
    
    switch (unit) {
      case 'mcg/ml':
        return value;
      case 'mg/ml':
        return value * 1000; // mg/mL para mcg/mL
      case 'g/l':
        return value * 1000; // g/L para mg/L, depois para mcg/mL
      case 'mg/l':
        return value; // mg/L = mcg/mL (mesmo valor)
      case 'mcg/l':
        return value / 1000; // mcg/L para mcg/mL
      default:
        return value;
    }
  }

  /// Normaliza uma concentração para mg/mL
  static double normalizeConcentrationToMgPerMl(double value, String concentrationText) {
    final unit = detectConcentrationUnit(concentrationText);
    
    switch (unit) {
      case 'mg/ml':
        return value;
      case 'mcg/ml':
        return value / 1000; // mcg/mL para mg/mL
      case 'g/l':
        return value; // g/L = mg/mL
      case 'mg/l':
        return value / 1000; // mg/L para mg/mL
      case 'mcg/l':
        return value / 1000000; // mcg/L para mg/mL
      default:
        return value;
    }
  }

  /// Calcula mL/h baseado na dose, peso, concentração e unidades
  static double calculateMlPerHour({
    required double dose,
    required double peso,
    required double concentration,
    required String doseUnit,
    required String concentrationUnit,
  }) {
    final infusionType = detectInfusionType(doseUnit);
    final normalizedConcentrationUnit = detectConcentrationUnit(concentrationUnit);
    
    // Calcular dose total por hora baseado no tipo de infusão
    double doseTotalPerHour;
    
    switch (infusionType) {
      // Infusões por peso e tempo
      case 'mcg/kg/min':
        // mcg/kg/min -> mcg/h
        doseTotalPerHour = dose * peso * 60;
        break;
      case 'mcg/kg/h':
        // mcg/kg/h -> mcg/h
        doseTotalPerHour = dose * peso;
        break;
      case 'mg/kg/min':
        // mg/kg/min -> mg/h
        doseTotalPerHour = dose * peso * 60;
        break;
      case 'mg/kg/h':
        // mg/kg/h -> mg/h
        doseTotalPerHour = dose * peso;
        break;
      case 'UI/kg/min':
        // UI/kg/min -> UI/h
        doseTotalPerHour = dose * peso * 60;
        break;
      case 'UI/kg/h':
        // UI/kg/h -> UI/h
        doseTotalPerHour = dose * peso;
        break;
      case 'g/kg/min':
        // g/kg/min -> g/h
        doseTotalPerHour = dose * peso * 60;
        break;
      case 'g/kg/h':
        // g/kg/h -> g/h
        doseTotalPerHour = dose * peso;
        break;
      // Infusões por tempo (sem peso)
      case 'UI/min':
        // UI/min -> UI/h
        doseTotalPerHour = dose * 60;
        break;
      case 'UI/h':
        // UI/h -> UI/h
        doseTotalPerHour = dose;
        break;
      case 'mg/h':
        // mg/h -> mg/h
        doseTotalPerHour = dose;
        break;
      case 'mg/min':
        // mg/min -> mg/h
        doseTotalPerHour = dose * 60;
        break;
      case 'mcg/h':
        // mcg/h -> mcg/h
        doseTotalPerHour = dose;
        break;
      case 'mcg/min':
        // mcg/min -> mcg/h
        doseTotalPerHour = dose * 60;
        break;
      case 'g/h':
        // g/h -> g/h
        doseTotalPerHour = dose;
        break;
      case 'g/min':
        // g/min -> g/h
        doseTotalPerHour = dose * 60;
        break;
      case 'mg/dia':
        // mg/dia -> mg/h
        doseTotalPerHour = dose / 24;
        break;
      case 'mcg/dia':
        // mcg/dia -> mcg/h
        doseTotalPerHour = dose / 24;
        break;
      default:
        // Fallback: assumir mcg/kg/min se não conseguir detectar
        doseTotalPerHour = dose * peso * 60;
        break;
    }
    
    // Normalizar concentração baseada no tipo de infusão
    double normalizedConcentration;
    final isDoseInMcg = infusionType.contains('mcg');
    final isDoseInMg = infusionType.contains('mg');
    final isDoseInUI = infusionType.contains('UI');
    final isDoseInG = infusionType.contains('g');
    
    if (isDoseInMcg) {
      // Dose em mcg - normalizar concentração para mcg/mL
      if (normalizedConcentrationUnit.contains('mg/ml')) {
        normalizedConcentration = concentration * 1000; // mg/mL para mcg/mL
      } else if (normalizedConcentrationUnit.contains('mcg/ml')) {
        normalizedConcentration = concentration; // já está em mcg/mL
      } else {
        normalizedConcentration = concentration; // assumir mcg/mL
      }
    } else if (isDoseInMg) {
      // Dose em mg - normalizar concentração para mg/mL
      if (normalizedConcentrationUnit.contains('mcg/ml')) {
        normalizedConcentration = concentration / 1000; // mcg/mL para mg/mL
      } else if (normalizedConcentrationUnit.contains('mg/ml')) {
        normalizedConcentration = concentration; // já está em mg/mL
      } else {
        normalizedConcentration = concentration; // assumir mg/mL
      }
    } else if (isDoseInUI) {
      // Dose em UI - normalizar concentração para UI/mL
      if (normalizedConcentrationUnit.contains('ui/ml')) {
        normalizedConcentration = concentration; // já está em UI/mL
      } else {
        normalizedConcentration = concentration; // assumir UI/mL
      }
    } else if (isDoseInG) {
      // Dose em g - normalizar concentração para g/mL
      if (normalizedConcentrationUnit.contains('mg/ml')) {
        normalizedConcentration = concentration / 1000; // mg/mL para g/mL
      } else if (normalizedConcentrationUnit.contains('g/ml')) {
        normalizedConcentration = concentration; // já está em g/mL
      } else {
        normalizedConcentration = concentration; // assumir g/mL
      }
    } else {
      // Fallback: assumir mcg
      if (normalizedConcentrationUnit.contains('mg/ml')) {
        normalizedConcentration = concentration * 1000; // mg/mL para mcg/mL
      } else {
        normalizedConcentration = concentration; // assumir mcg/mL
      }
    }
    
    // Calcular mL/h
    return doseTotalPerHour / normalizedConcentration;
  }
}
