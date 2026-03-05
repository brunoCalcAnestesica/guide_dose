import 'package:flutter/material.dart';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDifenidramina {
  static const String nome = 'Difenidramina';
  static const String idBulario = 'difenidramina';

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardDifenidramina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return _buildCardDifenidramina(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardDifenidramina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anti-histamínico H1', '1ª geração, sedativo'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 50mg/mL', '1mL | Benadryl®'),
        _linhaPreparo('Cápsula/Comprimido', '25mg ou 50mg'),
        
        // 3. PREPARO
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Puro (sem diluir)', '50 mg/mL'),
        _linhaPreparo('50mg + 9mL SF', '5 mg/mL (diluída)'),
        _textoObs('Administrar IV LENTO (≥2 min) - risco de hipotensão'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS FIXOS - caixa verde
          _linhaIndicacaoDoseFixa(
            titulo: 'Reações alérgicas / Urticária',
            descricaoDose: '25-50 mg IV/IM a cada 4-6h (máx 400 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Anafilaxia (adjuvante)',
            descricaoDose: '50 mg IV lento (após adrenalina)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Reação distônica / Extrapiramidalismo',
            descricaoDose: '25-50 mg IV lento',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Sedação pré-operatória',
            descricaoDose: '25-50 mg IV/IM 30 min antes',
          ),
        ] else ...[
          // BOLUS PEDIÁTRICO - caixa azul calculada
          _linhaIndicacaoDoseCalculada(
            titulo: 'Reações alérgicas (≥2 anos)',
            descricaoDose: '1-1,25 mg/kg IV/IM a cada 6h (máx 50 mg/dose)',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 1.25,
            doseMaxima: 50,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Anafilaxia pediátrica (adjuvante)',
            descricaoDose: '1-2 mg/kg IV lento (máx 50 mg)',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            doseMaxima: 50,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Extrapiramidalismo pediátrico',
            descricaoDose: '1 mg/kg IV lento (máx 50 mg)',
            dosePorKg: 1.0,
            doseMaxima: 50,
            unidade: 'mg',
            peso: peso,
          ),
        ],
        
        // SEM INFUSÃO CONTÍNUA (não é indicado)
        
        // 6. OBSERVAÇÕES (6 mais importantes)
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início IV: 15-30 min | Duração: 4-6h'),
        _textoObs('SEDAÇÃO INTENSA - efeito anticolinérgico central'),
        _textoObs('CI: <2 anos, glaucoma ângulo fechado'),
        _textoObs('Idoso: maior risco de confusão/retenção urinária'),
        _textoObs('Potencializa depressores do SNC e álcool'),
        _textoObs('NÃO é 1ª linha em anafilaxia (usar adrenalina)'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(text: texto),
                  if (marca.isNotEmpty) ...[
                    const TextSpan(
                        text: ' | ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: marca,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    required String unidade,
    required double peso,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
  }) {
    String? textoDose;
    bool doseLimite = false;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseMin.toStringAsFixed(0)}-${doseMax.toStringAsFixed(0)} $unidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            descricaoDose,
            style: const TextStyle(fontSize: 13),
          ),
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Text(
                doseLimite ? 'Dose: $textoDose (máx atingida)' : 'Dose: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
