import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCefuroxima {
  static const String nome = 'Cefuroxima';
  static const String idBulario = 'cefuroxima';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cefuroxima.json');
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
      conteudo: _buildCardCefuroxima(
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
    // Cefuroxima tem indicações para todas as faixas etárias
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
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções respiratórias superiores',
          descricaoDose: '250-500 mg VO a cada 12h (axetil)',
          unidade: 'mg',
          doseMinima: 250,
          doseMaxima: 500,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia comunitária',
          descricaoDose: '750 mg IV a cada 8h',
          unidade: 'mg',
          doseFixa: 750,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves',
          descricaoDose: '1,5 g IV a cada 8h (máximo 6 g/dia)',
          unidade: 'mg',
          doseFixa: 1500,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções urinárias',
          descricaoDose: '250-500 mg VO a cada 12h',
          unidade: 'mg',
          doseMinima: 250,
          doseMaxima: 500,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções de pele e partes moles',
          descricaoDose: '750 mg IV a cada 8h',
          unidade: 'mg',
          doseFixa: 750,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Gonorreia não complicada',
          descricaoDose: '1,5 g IM dose única',
          unidade: 'mg',
          doseFixa: 1500,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Tratamento sequencial (IV→VO)',
          descricaoDose: '750 mg IV → 250 mg VO a cada 12h',
          unidade: 'mg',
          doseFixa: 250,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções pediátricas gerais',
          descricaoDose: '30-100 mg/kg/dia IV divididos a cada 8h',
          unidade: 'mg',
          dosePorKgMinima: 30,
          dosePorKgMaxima: 100,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções respiratórias pediátricas',
          descricaoDose: '20-30 mg/kg/dia VO em 2 doses',
          unidade: 'mg',
          dosePorKgMinima: 20,
          dosePorKgMaxima: 30,
          doseMaxima: 500,
          peso: peso,
        ),
        MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves pediátricas',
          descricaoDose: '100 mg/kg/dia IV divididos a cada 8h',
          unidade: 'mg',
          dosePorKg: 100,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
            titulo: 'Recém-nascido (≤7 dias)',
            descricaoDose: '30-60 mg/kg/dia IV divididos a cada 12h',
            unidade: 'mg',
            dosePorKgMinima: 30,
            dosePorKgMaxima: 60,
            peso: peso,
          ),
          MedicamentoCefuroxima._linhaIndicacaoDoseCalculada(
            titulo: 'Recém-nascido (>7 dias)',
            descricaoDose: '30-60 mg/kg/dia IV divididos a cada 8h',
            unidade: 'mg',
            dosePorKgMinima: 30,
            dosePorKgMaxima: 60,
            peso: peso,
          ),
        ],
      ];
    }
  }

  static Widget _buildCardCefuroxima(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico beta-lactâmico, cefalosporina de segunda geração'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCefuroxima._linhaPreparo('VO (axetil): comprimidos 250 mg, 500 mg', 'Suspensão 125 mg/5 mL, 250 mg/5 mL'),
        MedicamentoCefuroxima._linhaPreparo('IV/IM (sódica): 750 mg, 1,5 g', 'Pó para reconstituição'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCefuroxima._linhaPreparo('IV direta: 750 mg em 6 mL água estéril', 'Administrar em 3-5 min'),
        MedicamentoCefuroxima._linhaPreparo('Infusão: diluir em 50-100 mL SF 0,9%', 'Infusão em 15-30 min'),
        MedicamentoCefuroxima._linhaPreparo('IM: reconstituir com lidocaína 1%', 'Sem epinefrina - reduz dor local'),
        MedicamentoCefuroxima._linhaPreparo('VO: administrar após refeições', 'Aumenta absorção do axetil'),
        MedicamentoCefuroxima._linhaPreparo('Suspensão oral: agitar bem antes de usar', 'Armazenar refrigerada até 10 dias'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCefuroxima._textoObs('Cefalosporina de segunda geração - bactericida tempo-dependente'),
        MedicamentoCefuroxima._textoObs('Amplo espectro: gram-positivos e gram-negativos'),
        MedicamentoCefuroxima._textoObs('Estável frente a beta-lactamases de H. influenzae e M. catarrhalis'),
        MedicamentoCefuroxima._textoObs('Boa penetração em tecidos e fluidos corporais'),
        MedicamentoCefuroxima._textoObs('Ativa contra: S. pneumoniae, H. influenzae, E. coli, K. pneumoniae'),
        MedicamentoCefuroxima._textoObs('NÃO ativa contra: MRSA, Enterococcus spp., P. aeruginosa, ESBL'),
        MedicamentoCefuroxima._textoObs('Meia-vida: 1,1-1,5 horas'),
        MedicamentoCefuroxima._textoObs('Ligação a proteínas: 33-50%'),
        MedicamentoCefuroxima._textoObs('Volume de distribuição: 0,2-0,3 L/kg'),
        MedicamentoCefuroxima._textoObs('Excreção renal: 90% inalterada em 24h'),
        MedicamentoCefuroxima._textoObs('Atravessa barreira placentária e hematoencefálica (meninges inflamadas)'),
        MedicamentoCefuroxima._textoObs('Ideal para transição IV→VO (terapia sequencial)'),
        MedicamentoCefuroxima._textoObs('Categoria B na gestação - considerada segura'),
        MedicamentoCefuroxima._textoObs('Reação cruzada com penicilinas em até 10% dos casos'),
        MedicamentoCefuroxima._textoObs('Aumenta risco de nefrotoxicidade com aminoglicosídeos'),
        MedicamentoCefuroxima._textoObs('Probenecida aumenta meia-vida da forma IV'),
        MedicamentoCefuroxima._textoObs('Antiácidos reduzem absorção oral'),
        MedicamentoCefuroxima._textoObs('Pode interferir em testes de glicose urinária'),
        MedicamentoCefuroxima._textoObs('Evitar em meningites graves (preferir ceftriaxona)'),
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