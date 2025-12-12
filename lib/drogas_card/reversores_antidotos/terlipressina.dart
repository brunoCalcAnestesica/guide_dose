import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTerlipressina {
  static const String nome = 'Terlipressina';
  static const String idBulario = 'terlipressina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/terlipressina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    final faixaEtaria = SharedData.faixaEtaria;
    // Terlipressina é usada principalmente em adultos (hemorragia varicosa, hepatorrenal)
    // Uso pediátrico é off-label e muito limitado
    return faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso' || 
           faixaEtaria == 'Adolescente' || faixaEtaria == 'Criança';
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
      conteudo: _buildCardTerlipressina(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardTerlipressina(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text(
          'Análogo sintético vasopressina - Vasoconstritor esplâncnico seletivo',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTerlipressina._linhaPreparo('Ampola/frasco 1mg/5mL (0,2mg/mL)', 'Glypressin®'),
        MedicamentoTerlipressina._linhaPreparo('Ampola 2mg/10mL (0,2mg/mL)', 'Haemipress®'),
        MedicamentoTerlipressina._linhaPreparo('Início: 15-30 min | Pico: 1-2h', 'Conversão gradual em lisina-vasopressina'),
        MedicamentoTerlipressina._linhaPreparo('Duração: 4-6h', 'vs Vasopressina 5-10 min'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTerlipressina._linhaPreparo('Pronto uso - administrar direto', 'Já 0,2 mg/mL'),
        MedicamentoTerlipressina._linhaPreparo('Pode diluir em SF 0,9% se preferir', 'Ex: 1mg em 10mL'),
        MedicamentoTerlipressina._linhaPreparo('IV bolus LENTO - 5 minutos', 'NUNCA rápido (risco isquemia)'),
        MedicamentoTerlipressina._linhaPreparo('Armazenamento: 2-8°C refrigerado', 'Estável 25°C por 30 dias'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoTerlipressina._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia digestiva alta (varizes esofágicas)',
            descricaoDose: 'Ataque: 2mg IV lento (5 min). Manutenção: 1mg IV a cada 4-6h até 5 dias',
            doseFixa: '2mg → 1mg',
          ),
          MedicamentoTerlipressina._linhaIndicacaoDoseFixa(
            titulo: 'Síndrome hepatorrenal tipo 1',
            descricaoDose: '0,5-2mg IV a cada 4-6h (titular conforme creatinina) + albumina',
            doseFixa: '0,5-2mg',
          ),
          MedicamentoTerlipressina._linhaIndicacaoDoseFixa(
            titulo: 'Choque séptico refratário a noradrenalina',
            descricaoDose: '1-2mg IV bolus (dose única ou repetir 4-6h)',
            doseFixa: '1-2mg',
          ),
        ] else ...[
          MedicamentoTerlipressina._linhaIndicacaoDoseCalculada(
            titulo: 'Uso pediátrico (off-label - literatura limitada)',
            descricaoDose: '0,02-0,04 mg/kg IV lento a cada 4-6h (máx 2mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 0.02,
            dosePorKgMaxima: 0.04,
            doseMaxima: 2.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTerlipressina._textoObs('Pró-fármaco - convertido em lisina-vasopressina (ativo) por enzimas endoteliais'),
        MedicamentoTerlipressina._textoObs('Vasoconstritor esplâncnico seletivo - reduz pressão portal 30-50%'),
        MedicamentoTerlipressina._textoObs('PADRÃO OURO hemorragia varicosa esofágica (controla sangramento)'),
        MedicamentoTerlipressina._textoObs('Duração prolongada (4-6h) - permite bolus intermitentes (vs vasopressina contínua)'),
        MedicamentoTerlipressina._textoObs('Seletividade V1 > V2 - menos retenção hídrica vs vasopressina'),
        MedicamentoTerlipressina._textoObs('Seguro cirrose avançada - clearance independente fígado/rim'),
        MedicamentoTerlipressina._textoObs('ATENÇÃO: Administrar IV LENTO (5 min) - NUNCA bolus rápido'),
        MedicamentoTerlipressina._textoObs('ATENÇÃO: Risco isquemia periférica (dedos, extremidades - palidez, cianose)'),
        MedicamentoTerlipressina._textoObs('ATENÇÃO: Risco isquemia mesentérica/coronariana (raro - suspender)'),
        MedicamentoTerlipressina._textoObs('Contraindicado: doença coronariana ativa, arteriopatia periférica grave'),
        MedicamentoTerlipressina._textoObs('Monitorar: PA, FC, ECG, perfusão periférica, débito sangramento'),
        MedicamentoTerlipressina._textoObs('Efeitos frequentes: palidez, cólicas abdominais, diarreia, bradicardia'),
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

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
    required String doseFixa,
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
          Text(
            descricaoDose,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
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
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        texto.startsWith('•') ? texto : '• $texto',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
