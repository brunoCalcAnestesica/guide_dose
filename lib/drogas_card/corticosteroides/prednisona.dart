import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPrednisona {
  static const String nome = 'Prednisona';
  static const String idBulario = 'prednisona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/prednisona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Prednisona tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPrednisona(
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

    return _buildCardPrednisona(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardPrednisona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Glicocorticoide sintético - Corticosteroide oral'),
        _textoObs(
            'Pró-droga: convertida em prednisolona (forma ativa) no fígado'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 5mg', 'Meticorten®, Predsim®'),
        _linhaPreparo('Comprimido 20mg', 'Meticorten®'),
        _linhaPreparo('Solução oral 1mg/mL (prednisolona)', 'Predsim®'),
        _linhaPreparo('Solução oral 3mg/mL (prednisolona)', 'Prelone®'),

        const SizedBox(height: 16),

        // Equivalência
        const Text('Equivalência de Corticoides',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _equivalenciaCorticoides(),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações e Doses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Asma aguda / Exacerbação de DPOC',
            descricaoDose: '40-60 mg VO/dia por 5-7 dias',
            doseFixa: '40-60 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Doenças autoimunes (dose inicial)',
            descricaoDose: '0,5-1 mg/kg/dia VO (máx 80 mg/dia)',
            doseFixa: '40-80 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Artrite reumatoide (dose baixa)',
            descricaoDose: '5-10 mg VO/dia',
            doseFixa: '5-10 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Reação alérgica',
            descricaoDose: '40-60 mg VO dose única ou curta',
            doseFixa: '40-60 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'COVID-19 (se O2 suplementar)',
            descricaoDose: '40 mg VO/dia por até 10 dias',
            doseFixa: '40 mg/dia',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Asma aguda pediátrica',
            descricaoDose: '1-2 mg/kg/dia VO por 3-5 dias (máx 60 mg/dia)',
            unidade: 'mg/dia',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
            doseMaxima: 60,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Laringite/Crupe pediátrico',
            descricaoDose: '1-2 mg/kg VO dose única (máx 60 mg)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
            doseMaxima: 60,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Anti-inflamatório pediátrico',
            descricaoDose: '0,5-2 mg/kg/dia VO',
            unidade: 'mg/dia',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 2.0,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Síndrome nefrótica pediátrica',
            descricaoDose: '2 mg/kg/dia VO (máx 60 mg/dia) por 4-6 semanas',
            unidade: 'mg/dia',
            dosePorKg: 2.0,
            peso: peso,
            doseMaxima: 60,
          ),
        ],

        const SizedBox(height: 16),

        // Observações
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Administrar pela manhã (simula ritmo circadiano)'),
        _textoObs('Tomar com alimentos para reduzir irritação gástrica'),
        _textoObs('Desmame gradual se uso > 7-14 dias'),
        _textoObs('Início de ação: 1-2 horas'),
        _textoObs('Pico de efeito: 1-2 horas'),
        _textoObs('Duração: 12-36 horas'),
        _textoObs('Meia-vida biológica: 18-36 horas'),
        _textoObs('Metabolismo hepático (conversão em prednisolona)'),

        const SizedBox(height: 16),

        // Efeitos adversos
        const Text('Efeitos Adversos (uso prolongado)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObsDestaque('Supressão adrenal'),
        _textoObs('Hiperglicemia'),
        _textoObs('Osteoporose'),
        _textoObs('Imunossupressão'),
        _textoObs('Síndrome de Cushing'),
        _textoObs('Úlcera péptica'),
        _textoObs('Retenção hídrica'),
        _textoObs('Alterações de humor'),

        const SizedBox(height: 16),

        // Contraindicações
        const Text('Contraindicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Infecções fúngicas sistêmicas não tratadas'),
        _textoObs('Hipersensibilidade ao fármaco'),
        _textoObs('Vacinas de vírus vivo (relativa)'),

        const SizedBox(height: 8),
        _textoObs('Categoria C na gravidez'),
      ],
    );
  }

  static Widget _equivalenciaCorticoides() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Equivalência anti-inflamatória:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 4),
          Text('• Prednisona 5 mg = Prednisolona 5 mg',
              style: TextStyle(fontSize: 12)),
          Text('• Prednisona 5 mg = Metilprednisolona 4 mg',
              style: TextStyle(fontSize: 12)),
          Text('• Prednisona 5 mg = Dexametasona 0,75 mg',
              style: TextStyle(fontSize: 12)),
          Text('• Prednisona 5 mg = Hidrocortisona 20 mg',
              style: TextStyle(fontSize: 12)),
        ],
      ),
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
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
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

  static Widget _textoObsDestaque(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
