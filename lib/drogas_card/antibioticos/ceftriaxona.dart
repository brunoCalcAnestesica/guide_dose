import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCeftriaxona {
  static const String nome = 'Ceftriaxona';
  static const String idBulario = 'ceftriaxona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ceftriaxona.json');
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
      conteudo: _buildCardCeftriaxona(
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
    // Ceftriaxona tem indicações para todas as faixas etárias
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
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções comuns',
          descricaoDose: '1-2 g IV 1x/dia',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Meningite bacteriana',
          descricaoDose: '2 g IV a cada 12h',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia comunitária',
          descricaoDose: '1-2 g IV 1x/dia',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções urinárias complicadas',
          descricaoDose: '1-2 g IV 1x/dia',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Gonorreia não complicada',
          descricaoDose: '250 mg IM dose única',
          unidade: 'mg',
          doseFixa: 250,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Neurossífilis',
          descricaoDose: '2 g IV a cada 12h',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia cirúrgica',
          descricaoDose: '1-2 g IV 30-60 min antes da incisão',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções pediátricas gerais',
          descricaoDose: '50-100 mg/kg/dia IV 1x/dia',
          unidade: 'mg',
          dosePorKgMinima: 50,
          dosePorKgMaxima: 100,
          doseMaxima: 4000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Meningite bacteriana pediátrica',
          descricaoDose: '80-100 mg/kg/dia IV divididos a cada 12h',
          unidade: 'mg',
          dosePorKg: 80,
          doseMaxima: 4000,
          peso: peso,
        ),
        MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves pediátricas',
          descricaoDose: '100 mg/kg/dia IV 1x/dia',
          unidade: 'mg',
          dosePorKg: 100,
          doseMaxima: 4000,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          MedicamentoCeftriaxona._linhaIndicacaoDoseCalculada(
            titulo: 'Recém-nascido (evitar cálcio IV)',
            descricaoDose: '50 mg/kg/dia IV 1x/dia',
            unidade: 'mg',
            dosePorKg: 50,
            peso: peso,
          ),
        ],
      ];
    }
  }

  static Widget _buildCardCeftriaxona(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico beta-lactâmico, cefalosporina de terceira geração'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCeftriaxona._linhaPreparo('Pó liofilizado: 250 mg, 500 mg, 1 g, 2 g', 'Frasco-ampola para reconstituição'),
        MedicamentoCeftriaxona._linhaPreparo('Reconstituir com água estéril, lidocaína 1%, SF 0,9% ou SG 5%', 'Conforme via de administração'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCeftriaxona._linhaPreparo('1 g IV: diluir em 10 mL água estéril', 'Administrar lentamente ou infundir em 30 min'),
        MedicamentoCeftriaxona._linhaPreparo('1 g IM: diluir em 3,5 mL lidocaína 1%', 'Sem epinefrina - reduz dor local'),
        MedicamentoCeftriaxona._linhaPreparo('Solução pronta: usar em até 6h (ambiente) ou 24h (geladeira)', 'Após reconstituição'),
        MedicamentoCeftriaxona._linhaPreparo('Incompatível com soluções contendo cálcio', 'Risco de precipitação fatal'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCeftriaxona._textoObs('Cefalosporina de terceira geração - bactericida tempo-dependente'),
        MedicamentoCeftriaxona._textoObs('Amplo espectro: gram-positivos e gram-negativos'),
        MedicamentoCeftriaxona._textoObs('Excelente penetração no LCR - opção preferencial em meningites'),
        MedicamentoCeftriaxona._textoObs('Meia-vida longa (6-9h) - permite dose única diária'),
        MedicamentoCeftriaxona._textoObs('Ativa contra: S. pneumoniae, N. meningitidis, H. influenzae'),
        MedicamentoCeftriaxona._textoObs('NÃO ativa contra: Enterococcus spp., P. aeruginosa, ESBL'),
        MedicamentoCeftriaxona._textoObs('Excreção: renal (33-67%) e biliar/fecal'),
        MedicamentoCeftriaxona._textoObs('Ligação a proteínas: 85-95%'),
        MedicamentoCeftriaxona._textoObs('Volume de distribuição: 0,1-0,2 L/kg'),
        MedicamentoCeftriaxona._textoObs('Boa penetração em: SNC, trato urinário, pulmões, pele, ossos'),
        MedicamentoCeftriaxona._textoObs('Categoria B na gestação - considerada segura'),
        MedicamentoCeftriaxona._textoObs('Reação cruzada com penicilinas em até 10% dos casos'),
        MedicamentoCeftriaxona._textoObs('Aumenta risco de nefrotoxicidade com aminoglicosídeos'),
        MedicamentoCeftriaxona._textoObs('Pode prolongar tempo de protrombina (INR)'),
        MedicamentoCeftriaxona._textoObs('CONTRAINDICADO: neonatos recebendo cálcio IV'),
        MedicamentoCeftriaxona._textoObs('Evitar hiperbilirrubinemia neonatal (competição por albumina)'),
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