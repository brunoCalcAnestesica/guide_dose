import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoGlucagon {
  static const String nome = 'Glucagon';
  static const String idBulario = 'glucagon';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/glucagon.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Glucagon tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardGlucagon(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardGlucagon(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlucagon._textoObs(
            'Hormônio pancreático - Agente hiperglicemiante'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlucagon._linhaPreparo(
            'Frasco-ampola 1mg (1UI) liofilizado', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlucagon._linhaPreparo(
            'Reconstituir com 1mL', 'Água destilada ou soro fisiológico'),
        MedicamentoGlucagon._linhaPreparo(
            'Agitar suavemente', 'Até dissolução completa'),
        MedicamentoGlucagon._linhaPreparo(
            'Administrar', 'IM, IV ou SC conforme indicação'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoGlucagon._linhaIndicacaoDoseFixa(
            titulo: 'Hipoglicemia severa',
            descricaoDose: '1mg IM ou IV',
            doseFixa: '1 mg (1 frasco)',
          ),
          MedicamentoGlucagon._linhaIndicacaoDoseFixa(
            titulo: 'Hipoglicemia por diabetes tipo 1',
            descricaoDose: '1mg IM',
            doseFixa: '1 mg (1 frasco)',
          ),
          MedicamentoGlucagon._linhaIndicacaoDoseFixa(
            titulo: 'Hipoglicemia por sulfonilureias',
            descricaoDose: '1mg IM ou IV',
            doseFixa: '1 mg (1 frasco)',
          ),
        ] else ...[
          MedicamentoGlucagon._linhaIndicacaoDoseCalculada(
            titulo: 'Hipoglicemia pediátrica',
            descricaoDose: '0,03mg/kg IM ou IV (máx 1mg)',
            unidade: 'mg',
            dosePorKg: 0.03,
            peso: peso,
            doseMaxima: 1.0,
          ),
          MedicamentoGlucagon._linhaIndicacaoDoseCalculada(
            titulo: 'Hipoglicemia neonatal',
            descricaoDose: '0,02-0,03mg/kg IM (máx 0,5mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.02,
            dosePorKgMaxima: 0.03,
            peso: peso,
            doseMaxima: 0.5,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlucagon._textoObs(
            'Hormônio pancreático que estimula glicogenólise hepática'),
        MedicamentoGlucagon._textoObs('Início de ação: 10-15 minutos IM'),
        MedicamentoGlucagon._textoObs('Início de ação: 5-10 minutos IV'),
        MedicamentoGlucagon._textoObs('Pico de efeito: 30 minutos'),
        MedicamentoGlucagon._textoObs('Duração: 60-90 minutos'),
        MedicamentoGlucagon._textoObs(
            'Mobiliza glicose dos estoques hepáticos de glicogênio'),
        MedicamentoGlucagon._textoObs(
            'Alternativa quando acesso IV não disponível'),
        MedicamentoGlucagon._textoObs('Pode ser administrado IM, IV ou SC'),
        MedicamentoGlucagon._textoObs(
            'Via IM preferencial em emergências extra-hospitalares'),
        MedicamentoGlucagon._textoObs(
            'Reconstituir imediatamente antes do uso'),
        MedicamentoGlucagon._textoObs('Usar imediatamente após reconstituição'),
        MedicamentoGlucagon._textoObs('Dose máxima adultos: 1mg'),
        MedicamentoGlucagon._textoObs('Dose máxima pediatria: 1mg'),
        MedicamentoGlucagon._textoObs('Dose máxima neonatos: 0,5mg'),
        MedicamentoGlucagon._textoObs(
            'Efeitos adversos: náuseas, vômitos (comuns)'),
        MedicamentoGlucagon._textoObs('Monitorar glicemia após administração'),
        MedicamentoGlucagon._textoObs(
            'Se sem resposta em 15min: administrar glicose IV'),
        MedicamentoGlucagon._textoObs(
            'Garantir aporte de glicose após reversão'),
        MedicamentoGlucagon._textoObs('Risco de hipoglicemia rebote'),
        MedicamentoGlucagon._textoObs(
            'Menos efetivo em alcoolismo crônico (estoques reduzidos)'),
        MedicamentoGlucagon._textoObs('Menos efetivo em desnutrição grave'),
        MedicamentoGlucagon._textoObs('Contraindicado em feocromocitoma'),
        MedicamentoGlucagon._textoObs('Contraindicado em insulinoma'),
        MedicamentoGlucagon._textoObs('Pode causar hipertensão transitória'),
        MedicamentoGlucagon._textoObs('Categoria B na gravidez'),
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
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
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
      textoDose =
          '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
