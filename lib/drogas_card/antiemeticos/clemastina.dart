import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoClemastina {
  static const String nome = 'Clemastina';
  static const String idBulario = 'clemastina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/farmacoteca/024_clemastina.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap;
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Verificar se há indicações para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink(); // Não exibe o card se não há indicações
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardClemastina(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Clemastina tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
      case 'Lactente':
      case 'Criança':
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        return true;
      default:
        return false;
    }
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        MedicamentoClemastina._linhaIndicacaoDoseCalculada(
          titulo: 'Reações alérgicas',
          descricaoDose: '1-2 mg IV a cada 8-12h',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoClemastina._linhaIndicacaoDoseCalculada(
          titulo: 'Urticária aguda',
          descricaoDose: '1-2 mg IV a cada 8-12h',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoClemastina._linhaIndicacaoDoseCalculada(
          titulo: 'Angioedema',
          descricaoDose: '1-2 mg IV a cada 8-12h',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoClemastina._linhaIndicacaoDoseCalculada(
          titulo: 'Dermatite de contato',
          descricaoDose: '1-2 mg IV a cada 8-12h',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 2,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        MedicamentoClemastina._linhaIndicacaoDoseCalculada(
          titulo: 'Reações alérgicas pediátricas',
          descricaoDose: '0,025-0,05 mg/kg IV a cada 8-12h',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          peso: peso,
        ),
        MedicamentoClemastina._linhaIndicacaoDoseCalculada(
          titulo: 'Urticária aguda pediátrica',
          descricaoDose: '0,025-0,05 mg/kg IV a cada 8-12h',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido' || faixaEtaria == 'Lactente') ...[
          MedicamentoClemastina._linhaIndicacaoDoseCalculada(
            titulo: 'Reações alérgicas neonatais',
            descricaoDose: '0,025 mg/kg IV a cada 12h (dose mínima)',
            unidade: 'mg',
            dosePorKg: 0.025,
            peso: peso,
          ),
        ],
        if (faixaEtaria == 'Criança' || faixaEtaria == 'Adolescente') ...[
          MedicamentoClemastina._linhaIndicacaoDoseCalculada(
            titulo: 'Angioedema pediátrico',
            descricaoDose: '0,025-0,05 mg/kg IV a cada 8-12h',
            unidade: 'mg',
            dosePorKgMinima: 0.025,
            dosePorKgMaxima: 0.05,
            peso: peso,
          ),
        ],
      ];
    }
  }

  static Widget _buildCardClemastina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antihistamínico H1 de primeira geração, antialérgico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClemastina._linhaPreparo('Ampola 1 mg/mL (2 mL)', 'Tavegil®, genérico'),
        MedicamentoClemastina._linhaPreparo('Comprimido 1 mg', 'Via oral'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClemastina._linhaPreparo('Via IV direta ou em acesso venoso periférico', 'Administrar lentamente em 2-3 minutos'),
        MedicamentoClemastina._linhaPreparo('Pode ser administrado IM se necessário', 'Como alternativa à via IV'),
        MedicamentoClemastina._linhaPreparo('Pronto para uso', 'Não requer diluição'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClemastina._textoObs('Antihistamínico H1 de primeira geração'),
        MedicamentoClemastina._textoObs('Bloqueia receptores H1 periféricos e centrais'),
        MedicamentoClemastina._textoObs('Efeito sedativo e anticolinérgico significativo'),
        MedicamentoClemastina._textoObs('Início de ação: 15-30 minutos IV'),
        MedicamentoClemastina._textoObs('Pico de ação: 2-4 horas'),
        MedicamentoClemastina._textoObs('Duração: 8-12 horas'),
        MedicamentoClemastina._textoObs('Metabolização hepática via CYP3A4'),
        MedicamentoClemastina._textoObs('Excreção renal e biliar'),
        MedicamentoClemastina._textoObs('Atravessa barreira hematoencefálica'),
        MedicamentoClemastina._textoObs('Sedação, sonolência, fadiga'),
        MedicamentoClemastina._textoObs('Boca seca, visão turva, retenção urinária'),
        MedicamentoClemastina._textoObs('Tontura, cefaleia, náusea'),
        MedicamentoClemastina._textoObs('Taquicardia, arritmias (doses altas)'),
        MedicamentoClemastina._textoObs('Categoria B na gestação'),
        MedicamentoClemastina._textoObs('Excretado no leite materno'),
        MedicamentoClemastina._textoObs('Potencializa efeitos de depressores do SNC'),
        MedicamentoClemastina._textoObs('Interage com álcool e sedativos'),
        MedicamentoClemastina._textoObs('Cuidado em glaucoma de ângulo fechado'),
        MedicamentoClemastina._textoObs('Cuidado em hipertrofia prostática'),
        MedicamentoClemastina._textoObs('Cuidado em epilepsia (pode reduzir limiar convulsivo)'),
        MedicamentoClemastina._textoObs('Evitar dirigir ou operar máquinas'),
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
                    const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      if (doseFixa < 1) {
        textoDose = '${doseFixa.toStringAsFixed(3)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      }
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(3)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      // Verificar se dose mínima não ultrapassou a máxima
      if (doseMin > doseMax) doseMin = doseMax;
      if (doseMin < 1 && doseMax < 1) {
        textoDose = '${doseMin.toStringAsFixed(3)}–${doseMax.toStringAsFixed(3)} $unidade';
      } else if (doseMin < 1) {
        textoDose = '${doseMin.toStringAsFixed(3)}–${doseMax.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
      }
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(1)}–${doseMaxima.toStringAsFixed(1)} $unidade';
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
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (doseLimite) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dose limitada por segurança',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}