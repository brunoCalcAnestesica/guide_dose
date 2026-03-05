class SharedData {
  static double? peso = 70;
  static double? altura = 176;
  static double? idade = 33;
  static String sexo = 'Masculino';
  static String idadeTipo = 'anos';
  static double? creatinina; // null = função renal normal

  /// Retorna true se a função renal está normal (creatinina não informada ou <= 1.2)
  static bool get funcaoRenalNormal {
    return creatinina == null || creatinina! <= 1.2;
  }

  /// Calcula o Clearance de Creatinina (ClCr) em mL/min
  /// Usa Cockcroft-Gault para adultos e Schwartz para pediátricos
  /// Retorna null se não houver dados suficientes
  static double? get clCr {
    if (creatinina == null || creatinina! <= 0) return null;
    if (idade == null || idade! <= 0) return null;

    // Pediátrico: Schwartz
    if (idade! < 18) {
      if (altura == null || altura! <= 0) return null;
      return (0.413 * altura!) / creatinina!;
    }

    // Adulto: Cockcroft-Gault
    if (peso == null || peso! <= 0) return null;
    double valor = ((140 - idade!) * peso!) / (72 * creatinina!);
    if (sexo == 'Feminino') {
      valor *= 0.85;
    }
    return valor;
  }

  static String get faixaEtaria {
    if (idade == null) return '-';
    if (idade! < 0.083) return 'Recém-nascido';
    if (idade! < 1) return 'Lactente';
    if (idade! < 12) return 'Criança';
    if (idade! < 18) return 'Adolescente';
    if (idade! < 60) return 'Adulto';
    return 'Idoso';
  }
}
