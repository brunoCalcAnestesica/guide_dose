/// Classe para armazenar dados do paciente atual.
/// 
/// Esta classe é usada para fornecer contexto à IA sobre o paciente.
/// Adapte conforme seu modelo de dados.
class SharedData {
  static double? peso = 70;
  static double? altura = 176;
  static double? idade = 33;
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

  /// Reseta os dados para valores padrão
  static void reset() {
    peso = null;
    altura = null;
    idade = null;
    sexo = '';
    idadeTipo = 'anos';
  }

  /// Atualiza os dados do paciente
  static void update({
    double? novoPeso,
    double? novaAltura,
    double? novaIdade,
    String? novoSexo,
    String? novoIdadeTipo,
  }) {
    if (novoPeso != null) peso = novoPeso;
    if (novaAltura != null) altura = novaAltura;
    if (novaIdade != null) idade = novaIdade;
    if (novoSexo != null) sexo = novoSexo;
    if (novoIdadeTipo != null) idadeTipo = novoIdadeTipo;
  }
}
