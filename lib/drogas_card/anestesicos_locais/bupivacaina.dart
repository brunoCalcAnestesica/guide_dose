import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBupivacaina {
  static const String nome = 'Bupivacaína';
  static const String idBulario = 'bupivacaina_infiltracao';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/bupivacaina_infiltracao.json');
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
      conteudo: _buildCardBupivacaina(
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
    // Bupivacaína tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Uso em procedimentos cirúrgicos específicos
        return true;
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

  static Widget _buildCardBupivacaina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anestésico local', 'Amida - Bloqueador canais Na+'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 0,75%', '7,5 mg/mL'),
        _linhaPreparo('Frasco 0,5%', '5 mg/mL'),
        _linhaPreparo('Frasco 0,25%', '2,5 mg/mL'),
        _linhaPreparo('Com adrenalina 1:200.000', 'Vasoconstritor'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('0,5% + SF (1:1)', '0,25% = 2,5 mg/mL'),
        _linhaPreparo('0,5% + SF (1:3)', '0,125% = 1,25 mg/mL'),
        _linhaPreparo('Aspirar antes de injetar', 'Evitar via IV'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Infiltração (sem vasoconstritor)',
            descricaoDose: 'Dose máxima: 2 mg/kg (máx 175mg)',
            unidade: 'mg',
            dosePorKg: 2.0,
            doseMaxima: 175,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Infiltração (com adrenalina)',
            descricaoDose: 'Dose máxima: 3 mg/kg (máx 225mg)',
            unidade: 'mg',
            dosePorKg: 3.0,
            doseMaxima: 225,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Cateter peridural/periférico',
            descricaoDose: '0,1-0,4 mg/kg/h (0,125-0,25%)',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Infiltração pediátrica',
            descricaoDose: 'Dose máxima: 2 mg/kg',
            unidade: 'mg',
            dosePorKg: 2.0,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Cateter pediátrico',
            descricaoDose: '0,1-0,2 mg/kg/h (0,125%)',
          ),
        ],
        
        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua (Cateteres)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusaoCateteres(peso, isAdulto),
        
        // 6. OBSERVAÇÕES (6 mais importantes)
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('CARDIOTÓXICA - ter Intralipid 20% disponível'),
        _textoObs('Duração: 4-12 horas (maior dos AL)'),
        _textoObs('Monitorizar 30 min após administração'),
        _textoObs('Injeção lenta e fracionada (aspirar sempre)'),
        _textoObs('Não misturar com soluções alcalinas'),
        _textoObs('Sinais toxicidade: zumbido, gosto metálico, convulsão'),
      ],
    );
  }

  static Widget _linhaIndicacaoInfusao({
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
    required String unidade,
    double? dosePorKg,
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double dose = dosePorKg * peso;
      if (doseMaxima != null && dose > doseMaxima) dose = doseMaxima;
      textoDose = '${dose.toStringAsFixed(0)} $unidade';
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
                'Dose máxima calculada: $textoDose',
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

  static Widget _buildConversorInfusaoCateteres(double peso, bool isAdulto) {
    // Ordenar da maior para menor concentração
    final opcoesConcentracoes = {
      '0,25% (2,5 mg/mL)': 2.5, // mg/mL
      '0,125% (1,25 mg/mL)': 1.25, // mg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.1,
        doseMax: 0.4,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {'0,125% (1,25 mg/mL)': 1.25},
        unidade: 'mg/kg/h',
        doseMin: 0.1,
        doseMax: 0.2,
      );
    }
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}