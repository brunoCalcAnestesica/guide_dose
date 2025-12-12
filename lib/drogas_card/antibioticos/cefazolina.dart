import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCefazolina {
  static const String nome = 'Cefazolina';
  static const String idBulario = 'cefazolina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cefazolina.json');
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
      conteudo: _buildCardCefazolina(
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
    // Cefazolina tem indicações para todas as faixas etárias
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
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia cirúrgica',
          descricaoDose: '2 g IV 30-60 min antes da incisão (repetir após 4h)',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções leves a moderadas',
          descricaoDose: '1 g IV/IM a cada 8h',
          unidade: 'mg',
          doseFixa: 1000,
          peso: peso,
        ),
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves',
          descricaoDose: '1-2 g IV a cada 6-8h (máximo 6 g/dia)',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções de pele e partes moles',
          descricaoDose: '1 g IV a cada 8h',
          unidade: 'mg',
          doseFixa: 1000,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções pediátricas gerais',
          descricaoDose: '25-50 mg/kg/dia divididos a cada 6-8h',
          unidade: 'mg',
          dosePorKgMinima: 25,
          dosePorKgMaxima: 50,
          doseMaxima: 6000,
          peso: peso,
        ),
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia cirúrgica pediátrica',
          descricaoDose: '25 mg/kg IV 30-60 min antes da incisão',
          unidade: 'mg',
          dosePorKg: 25,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves pediátricas',
          descricaoDose: '50 mg/kg/dia divididos a cada 6h (máximo 6 g/dia)',
          unidade: 'mg',
          dosePorKg: 50,
          doseMaxima: 6000,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
            titulo: 'Recém-nascido prematuro',
            descricaoDose: '20 mg/kg/dose IV a cada 12h',
            unidade: 'mg',
            dosePorKg: 20,
            peso: peso,
          ),
          MedicamentoCefazolina._linhaIndicacaoDoseCalculada(
            titulo: 'Recém-nascido termo',
            descricaoDose: '20 mg/kg/dose IV a cada 8h',
            unidade: 'mg',
            dosePorKg: 20,
            peso: peso,
          ),
        ],
      ];
    }
  }

  static Widget _buildCardCefazolina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico beta-lactâmico, cefalosporina de primeira geração'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCefazolina._linhaPreparo('Pó liofilizado: 500 mg, 1 g, 2 g', 'Frasco-ampola para reconstituição'),
        MedicamentoCefazolina._linhaPreparo('Compatível com SF 0,9% e SG 5%', 'Para diluição'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCefazolina._linhaPreparo('Reconstituir com 2-10 mL de diluente', 'Para IV direta (100-200 mg/mL)'),
        MedicamentoCefazolina._linhaPreparo('Infusão: diluir 1 g em 50-100 mL SF', 'Infusão em 15-30 min'),
        MedicamentoCefazolina._linhaPreparo('IM: diluir em lidocaína 1% sem epinefrina', 'Reduz dor local'),
        MedicamentoCefazolina._linhaPreparo('Usar solução em até 6h (ambiente) ou 24h (geladeira)', 'Após reconstituição'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCefazolina._textoObs('Cefalosporina de primeira geração - bactericida tempo-dependente'),
        MedicamentoCefazolina._textoObs('Ativa contra MSSA, Streptococcus spp. e algumas Enterobacteriaceae'),
        MedicamentoCefazolina._textoObs('NÃO ativa contra MRSA, Enterococcus spp. e Pseudomonas'),
        MedicamentoCefazolina._textoObs('Boa penetração em pele, tecidos moles, osso e trato geniturinário'),
        MedicamentoCefazolina._textoObs('Excreção renal (90% inalterada) - ajustar em insuficiência renal'),
        MedicamentoCefazolina._textoObs('Meia-vida: 1,5-2 horas (prolongada em IRC)'),
        MedicamentoCefazolina._textoObs('Monitorizar função renal, especialmente em idosos'),
        MedicamentoCefazolina._textoObs('Reação cruzada com penicilinas em até 10% dos casos'),
        MedicamentoCefazolina._textoObs('Aumenta risco de nefrotoxicidade com aminoglicosídeos'),
        MedicamentoCefazolina._textoObs('Pode prolongar tempo de protrombina (INR)'),
        MedicamentoCefazolina._textoObs('Categoria B na gestação - considerada segura'),
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
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
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
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