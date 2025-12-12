import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSugamadex {
  static const String nome = 'Sugamadex';
  static const String idBulario = 'sugamadex';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/sugamadex.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    final faixaEtaria = SharedData.faixaEtaria;
    // Sugammadex NÃO recomendado para neonatos e lactentes (<2 anos)
    return faixaEtaria != 'Neonato' && faixaEtaria != 'Lactente';
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    // Verificar se deve mostrar o card para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria()) {
      return const SizedBox.shrink();
    }

    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardSugamadex(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSugamadex(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSugamadex._textoObs('Reversor seletivo bloqueio neuromuscular - Antagonista bloqueadores esteroidais'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSugamadex._linhaPreparo('Frasco 200mg/2mL (100mg/mL)', 'Bridion®'),
        MedicamentoSugamadex._linhaPreparo('Frasco 500mg/5mL (100mg/mL)', 'Bridion®'),
        MedicamentoSugamadex._linhaPreparo('Início: 1-3 min | Reversão completa', 'Rápido'),
        MedicamentoSugamadex._linhaPreparo('Meia-vida: 2 horas', 'Excreção renal >95%'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSugamadex._linhaPreparo('Pronto uso - administrar puro', 'Direto do frasco'),
        MedicamentoSugamadex._linhaPreparo('Pode diluir em SF 0,9% ou SG 5%', 'Estável 48h refrigerado'),
        MedicamentoSugamadex._linhaPreparo('Bolus rápido IV (máx 10 seg)', 'Não diluir rotineiramente'),
        MedicamentoSugamadex._linhaPreparo('Armazenamento: 2-25°C', 'Não congelar'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSugamadex._linhaIndicacaoDoseCalculada(
          titulo: 'Bloqueio moderado (TOF 2 respostas)',
          descricaoDose: '2 mg/kg IV bolus rápido (máx 10 seg)',
          unidade: 'mg',
          dosePorKg: 2.0,
          peso: peso,
        ),
        MedicamentoSugamadex._linhaIndicacaoDoseCalculada(
          titulo: 'Bloqueio profundo (POT 1-2 ou sem TOF)',
          descricaoDose: '4 mg/kg IV bolus rápido (máx 10 seg)',
          unidade: 'mg',
          dosePorKg: 4.0,
          peso: peso,
        ),
        MedicamentoSugamadex._linhaIndicacaoDoseCalculada(
          titulo: 'Reversão imediata pós-rocurônio 1,2mg/kg',
          descricaoDose: '16 mg/kg IV bolus (emergência - substitui succinilcolina)',
          unidade: 'mg',
          dosePorKg: 16.0,
          peso: peso,
        ),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSugamadex._textoObs('Ciclodextrina modificada - encapsula seletivamente rocurônio/vecurônio'),
        MedicamentoSugamadex._textoObs('Reverte rapidamente bloqueios neuromusculares esteroidais'),
        MedicamentoSugamadex._textoObs('NÃO interfere receptores nicotínicos ou acetilcolinesterase'),
        MedicamentoSugamadex._textoObs('Sem efeitos colinérgicos (vs neostigmina): sem bradicardia, broncoespasmo, salivação'),
        MedicamentoSugamadex._textoObs('Específico para: rocurônio, vecurônio (bloqueadores ESTEROIDAIS)'),
        MedicamentoSugamadex._textoObs('NÃO reverte: cisatracúrio, atracúrio, mivacúrio (benzilisoquinolínicos)'),
        MedicamentoSugamadex._textoObs('ATENÇÃO: Contraindicado insuficiência renal grave (ClCr <30 mL/min)'),
        MedicamentoSugamadex._textoObs('ATENÇÃO: Reduz eficácia anticoncepcionais hormonais (método adicional 7 dias)'),
        MedicamentoSugamadex._textoObs('Monitorar: TOF (função neuromuscular), sinais vitais, recurarização'),
        MedicamentoSugamadex._textoObs('Risco recurarização se dose insuficiente'),
        MedicamentoSugamadex._textoObs('NÃO recomendado: neonatos e lactentes (<2 anos)'),
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
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;
    String? textoVolume;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      // Sugammadex 100 mg/mL
      double volumeML = doseCalculada / 100;
      textoVolume = '${volumeML.toStringAsFixed(1)} mL';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
      // Sugammadex 100 mg/mL
      double volumeMinML = doseMin / 100;
      double volumeMaxML = doseMax / 100;
      textoVolume = '${volumeMinML.toStringAsFixed(1)}–${volumeMaxML.toStringAsFixed(1)} mL';
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Dose: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (textoVolume != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Volume: $textoVolume (100mg/mL)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                        fontSize: 12,
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
      child: Text(
        texto.startsWith('•') ? texto : '• $texto',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
