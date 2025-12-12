import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEmulsaoLipidica {
  static const String nome = 'Emulsão Lipídica';
  static const String idBulario = 'emulsaolipidica';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/emulsaolipidica.json');
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
      conteudo: _buildCardEmulsaoLipidica(
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
    // Emulsão lipídica tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardEmulsaoLipidica(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Antídoto para intoxicação por anestésicos locais'),
        const Text('• Emulsão lipídica para tratamento de emergência'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Emulsão lipídica 20% - Frasco 250 mL'),
        const Text('• Emulsão lipídica 20% - Frasco 500 mL'),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Administrar via IV diretamente'),
        const Text('• Não requer diluição prévia'),
        const Text('• Infusão rápida inicial: 1,5 mL/kg em 1 minuto'),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        _buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEmulsaoLipidica._textoObs('Antídoto de primeira linha para intoxicação por anestésicos locais'),
        MedicamentoEmulsaoLipidica._textoObs('Iniciar imediatamente em caso de suspeita de intoxicação'),
        MedicamentoEmulsaoLipidica._textoObs('Monitorar sinais vitais durante a administração'),
        MedicamentoEmulsaoLipidica._textoObs('Pode ser repetida se necessário após 5 minutos'),
        MedicamentoEmulsaoLipidica._textoObs('Contraindicada em alergia a óleo de soja'),
        MedicamentoEmulsaoLipidica._textoObs('Armazenar em temperatura ambiente'),
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
          MedicamentoEmulsaoLipidica._linhaIndicacaoDoseCalculada(
            titulo: 'Intoxicação por anestésicos locais',
            descricaoDose: 'Bólus inicial: 1,5 mL/kg IV (máx 100 mL)',
            unidade: 'mL',
            dosePorKg: 1.5,
            doseMaxima: 100,
            peso: peso,
          ),
        ] else ...[
          MedicamentoEmulsaoLipidica._linhaIndicacaoDoseCalculada(
            titulo: 'Intoxicação por anestésicos locais',
            descricaoDose: 'Bólus inicial: 1,5 mL/kg IV',
            unidade: 'mL',
            dosePorKg: 1.5,
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