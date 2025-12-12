class SharedData {
  static double? peso;
  static double? altura;
  static double? idade;
  static String sexo = 'Masculino';
  static String idadeTipo = 'anos';

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


