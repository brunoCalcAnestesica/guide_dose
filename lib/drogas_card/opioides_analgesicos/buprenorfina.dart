import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBuprenorfina {
  static const String nome = 'Buprenorfina';
  static const String idBulario = 'buprenorfina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/buprenorfina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
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
      conteudo: _buildCardBuprenorfina(
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
    // Buprenorfina tem indicações limitadas em pediatria
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Uso restrito - apenas em casos específicos
        return false;
      case 'Lactente':
      case 'Criança':
        // Uso off-label e restrito
        return false;
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
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dor moderada a intensa - Sublingual',
          descricaoDose: '3-6 mcg/kg SL a cada 6-8h (efeito teto; máximo prático ~2,4 mg/dia)',
          unidade: 'mcg',
          dosePorKgMinima: 3,
          dosePorKgMaxima: 6,
          doseMaxima: 400,
          peso: peso,
        ),
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dor moderada a intensa - IV/IM',
          descricaoDose: '4-8 mcg/kg IV/IM a cada 6-8h (máximo usual 0,6 mg/dia)',
          unidade: 'mcg',
          dosePorKgMinima: 4,
          dosePorKgMaxima: 8,
          doseMaxima: 600,
          peso: peso,
        ),
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dor crônica - Filme bucal (Belbuca®)',
          descricaoDose: '75-900 mcg a cada 12h (titulando conforme resposta)',
          unidade: 'mcg',
          doseMinima: 75,
          doseMaxima: 900,
          peso: peso,
        ),
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dor crônica - Transdérmico',
          descricaoDose: '5-20 mcg/h (trocar a cada 7 dias)',
          unidade: 'mcg/h',
          doseMinima: 5,
          doseMaxima: 20,
          peso: peso,
        ),
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dependência de opioides - SL',
          descricaoDose: '2-4 mg SL inicial, titular até 16 mg/dia (máximo 24 mg/dia). Iniciar em abstinência objetiva (COWS ≥ 8-12)',
          unidade: 'mg',
          doseMinima: 2,
          doseMaxima: 4,
          peso: peso,
        ),
      ];
    } else {
      // Adolescente (uso restrito)
      return [
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dor moderada a intensa - Adolescente (off-label)',
          descricaoDose: '2-4 mcg/kg SL a cada 6-8h (uso restrito, ambiente controlado)',
          unidade: 'mcg',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 4,
          doseMaxima: 200,
          peso: peso,
        ),
        MedicamentoBuprenorfina._linhaIndicacaoDoseCalculada(
          titulo: 'Dor pós-operatória - IV/IM (off-label)',
          descricaoDose: '3-6 mcg/kg IV/IM a cada 6-8h (ambiente hospitalar)',
          unidade: 'mcg',
          dosePorKgMinima: 3,
          dosePorKgMaxima: 6,
          doseMaxima: 300,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardBuprenorfina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Analgésico opioide, agonista parcial de receptores μ-opioides'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBuprenorfina._linhaPreparo('Comprimidos sublinguais: 200 mcg, 400 mcg, 2 mg, 8 mg', 'Via sublingual'),
        MedicamentoBuprenorfina._linhaPreparo('Adesivo transdérmico: 5, 10, 15, 20 mcg/h', 'Trocar a cada 7 dias'),
        MedicamentoBuprenorfina._linhaPreparo('Solução injetável: 0,3 mg/mL', 'Via IV/IM'),
        MedicamentoBuprenorfina._linhaPreparo('Filmes bucais: 75-900 mcg', 'Absorção transmucosa'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBuprenorfina._linhaPreparo('Sublingual: não cortar ou mastigar', 'Deixar dissolver completamente'),
        MedicamentoBuprenorfina._linhaPreparo('Transdérmico: aplicar em pele íntegra', 'Região torácica, deltoide ou lateral'),
        MedicamentoBuprenorfina._linhaPreparo('IV/IM: diluir com SF 0,9% se necessário', 'Administrar em 2-3 min (IV)'),
        MedicamentoBuprenorfina._linhaPreparo('Filmes bucais (Belbuca®): 75-900 mcg a cada 12h', 'Não mastigar/cortar; evitar líquidos quentes'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBuprenorfina._textoObs('Agonista parcial com efeito teto para depressão respiratória'),
        MedicamentoBuprenorfina._textoObs('Meia-vida longa: 20-70 horas (média 37h)'),
        MedicamentoBuprenorfina._textoObs('Alta afinidade aos receptores μ - dificulta antagonismo'),
        MedicamentoBuprenorfina._textoObs('Menor risco de overdose comparado a agonistas plenos'),
        MedicamentoBuprenorfina._textoObs('Efeito antidepressivo por antagonismo κ'),
        MedicamentoBuprenorfina._textoObs('Monitorizar sinais de depressão respiratória'),
        MedicamentoBuprenorfina._textoObs('Evitar associação com benzodiazepínicos e outros depressores do SNC; se necessário, usar com monitorização contínua em ambiente habilitado'),
        MedicamentoBuprenorfina._textoObs('Reversão com naloxona pode ser parcial; considerar bolus repetidos e infusão contínua'),
        MedicamentoBuprenorfina._textoObs('Cuidado com interações com inibidores CYP3A4'),
        MedicamentoBuprenorfina._textoObs('Pode precipitar abstinência em usuários de agonistas plenos'),
        MedicamentoBuprenorfina._textoObs('Preferir buprenorfina/naloxona para dependência, exceto gestantes (monocomponente)'),
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
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
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
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
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
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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