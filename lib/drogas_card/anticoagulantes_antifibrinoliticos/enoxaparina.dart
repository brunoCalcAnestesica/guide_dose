import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEnoxaparina {
  static const String nome = 'Enoxaparina';
  static const String idBulario = 'enoxaparina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/enoxaparina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardEnoxaparina(
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
    // Enoxaparina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardEnoxaparina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Anticoagulante de baixo peso molecular'),
        const Text('• Heparina de baixo peso molecular (HBPM)'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Enoxaparina 40 mg/0,4 mL - Seringa pré-cheia'),
        const Text('• Enoxaparina 60 mg/0,6 mL - Seringa pré-cheia'),
        const Text('• Enoxaparina 80 mg/0,8 mL - Seringa pré-cheia'),
        const Text('• Enoxaparina 100 mg/1 mL - Seringa pré-cheia'),
        const Text('• Enoxaparina 120 mg/0,8 mL - Seringa pré-cheia'),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Administrar via subcutânea (SC)'),
        const Text('• Rotacionar locais de aplicação'),
        const Text('• Não massagear após aplicação'),
        const Text('• Usar seringa pré-cheia ou reconstituir conforme bula'),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        _buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEnoxaparina._textoObs('Anticoagulante de baixo peso molecular'),
        MedicamentoEnoxaparina._textoObs('Profilaxia e tratamento de trombose venosa'),
        MedicamentoEnoxaparina._textoObs('Síndrome coronariana aguda'),
        MedicamentoEnoxaparina._textoObs('Monitorar hemorragias e sangramentos'),
        MedicamentoEnoxaparina._textoObs('Cautela em insuficiência renal'),
        MedicamentoEnoxaparina._textoObs('Evitar administração intramuscular'),
        MedicamentoEnoxaparina._textoObs('Monitorar plaquetas em uso prolongado'),
      ],
    );
  }

  static Widget _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        
        if (isAdulto) ...[
          MedicamentoEnoxaparina._linhaIndicacaoDoseCalculada(
            titulo: 'Profilaxia de TVP',
            descricaoDose: '40 mg SC 1x/dia',
            unidade: 'mg',
            dosePorKg: 40,
            peso: peso,
          ),
          const SizedBox(height: 8),
          MedicamentoEnoxaparina._linhaIndicacaoDoseCalculada(
            titulo: 'Tratamento de TVP/EP',
            descricaoDose: '1,5 mg/kg SC 1x/dia (máx 150 mg)',
            unidade: 'mg',
            dosePorKg: 1.5,
            doseMaxima: 150,
            peso: peso,
          ),
          const SizedBox(height: 8),
          MedicamentoEnoxaparina._linhaIndicacaoDoseCalculada(
            titulo: 'SCA sem supradesnivelamento',
            descricaoDose: '1 mg/kg SC 2x/dia',
            unidade: 'mg',
            dosePorKg: 1.0,
            peso: peso,
          ),
          const SizedBox(height: 8),
          MedicamentoEnoxaparina._linhaIndicacaoDoseCalculada(
            titulo: 'Profilaxia cirúrgica',
            descricaoDose: '40 mg SC 1x/dia',
            unidade: 'mg',
            dosePorKg: 40,
            peso: peso,
          ),
        ] else ...[
          MedicamentoEnoxaparina._linhaIndicacaoDoseCalculada(
            titulo: 'Tratamento de TVP pediátrica',
            descricaoDose: '1,5 mg/kg SC 2x/dia',
            unidade: 'mg',
            dosePorKg: 1.5,
            peso: peso,
          ),
          const SizedBox(height: 8),
          MedicamentoEnoxaparina._linhaIndicacaoDoseCalculada(
            titulo: 'Profilaxia pediátrica',
            descricaoDose: '0,75 mg/kg SC 2x/dia',
            unidade: 'mg',
            dosePorKg: 0.75,
            peso: peso,
          ),
        ],
      ],
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
    bool excedeMaxima = false;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        excedeMaxima = true;
        doseCalculada = doseMaxima;
      }
      // Formatar dose com decimais apropriados
      String doseFormatada = doseCalculada % 1 == 0 
          ? doseCalculada.toInt().toString() 
          : doseCalculada.toStringAsFixed(1);
      textoDose = '$doseFormatada $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
        doseMin = doseMin > doseMaxima ? doseMaxima : doseMin;
      }
      // Formatar doses com decimais apropriados
      String doseMinFormatada = doseMin % 1 == 0 
          ? doseMin.toInt().toString() 
          : doseMin.toStringAsFixed(1);
      String doseMaxFormatada = doseMax % 1 == 0 
          ? doseMax.toInt().toString() 
          : doseMax.toStringAsFixed(1);
      textoDose = '$doseMinFormatada–$doseMaxFormatada $unidade';
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
          if (textoDose != null && textoDose.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Dose calculada: $textoDose${excedeMaxima ? ' (máxima atingida)' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
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