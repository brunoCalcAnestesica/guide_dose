import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHeliox {
  static const String nome = 'Heliox';
  static const String idBulario = 'heliox';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/heliox.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Heliox tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHeliox(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardHeliox(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeliox._textoObs(
            'Mistura gasosa terapêutica - Hélio + Oxigênio'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeliox._linhaPreparo(
            'Cilindro 80% hélio + 20% O₂', 'Primeira escolha se SpO₂ >94%'),
        MedicamentoHeliox._linhaPreparo(
            'Cilindro 70% hélio + 30% O₂', 'Se necessário maior FiO₂'),
        MedicamentoHeliox._linhaPreparo(
            'Cilindro 60% hélio + 40% O₂', 'Se necessário FiO₂ mais alto'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeliox._linhaPreparo(
            'Conectar cilindro', 'Fluxômetro calibrado para heliox'),
        MedicamentoHeliox._linhaPreparo(
            'Máscara facial', 'Não reinalante com vedação adequada'),
        MedicamentoHeliox._linhaPreparo(
            'Fluxo', '6-15 L/min (ajustar conforme idade)'),
        MedicamentoHeliox._linhaPreparo(
            'Umidificação', 'Se uso prolongado (>1 hora)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeliox._linhaIndicacaoFluxo(
          titulo: 'Obstrução de vias aéreas superiores (crupe)',
          fluxoMin: isAdulto ? 10 : 6,
          fluxoMax: isAdulto ? 15 : 8,
        ),
        MedicamentoHeliox._linhaIndicacaoFluxo(
          titulo: 'Edema de glote',
          fluxoMin: isAdulto ? 10 : 6,
          fluxoMax: isAdulto ? 15 : 10,
        ),
        MedicamentoHeliox._linhaIndicacaoFluxo(
          titulo: 'Estridor pós-extubação',
          fluxoMin: isAdulto ? 10 : 6,
          fluxoMax: isAdulto ? 15 : 10,
        ),
        if (isAdulto) ...[
          MedicamentoHeliox._linhaIndicacaoFluxo(
            titulo: 'Estenose traqueal',
            fluxoMin: 10,
            fluxoMax: 15,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeliox._textoObs('Início de ação: IMEDIATO (efeito físico)'),
        MedicamentoHeliox._textoObs('Duração: enquanto mantida a inalação'),
        MedicamentoHeliox._textoObs('Hélio: 1/7 da densidade do ar'),
        MedicamentoHeliox._textoObs(
            'Reduz resistência ao fluxo aéreo em 40-60%'),
        MedicamentoHeliox._textoObs('Converte fluxo turbulento em laminar'),
        MedicamentoHeliox._textoObs('Melhora ventilação alveolar'),
        MedicamentoHeliox._textoObs('Reduz trabalho respiratório'),
        MedicamentoHeliox._textoObs(
            'Gás inerte (sem efeito farmacológico sistêmico)'),
        MedicamentoHeliox._textoObs('Eliminação imediata após cessação'),
        MedicamentoHeliox._textoObs('Fluxo neonatos/lactentes: 6-8 L/min'),
        MedicamentoHeliox._textoObs('Fluxo crianças: 8-10 L/min'),
        MedicamentoHeliox._textoObs('Fluxo adolescentes/adultos: 10-15 L/min'),
        MedicamentoHeliox._textoObs('Máscara não reinalante obrigatória'),
        MedicamentoHeliox._textoObs('Vedação adequada essencial'),
        MedicamentoHeliox._textoObs(
            'Monitorar SpO₂ continuamente (objetivo >92%)'),
        MedicamentoHeliox._textoObs(
            'Resposta clínica: geralmente em 15-30 minutos'),
        MedicamentoHeliox._textoObs(
            'Usar como PONTE para terapias definitivas'),
        MedicamentoHeliox._textoObs('NÃO usar como monoterapia'),
        MedicamentoHeliox._textoObs(
            'Associar corticoides e/ou adrenalina nebulizada'),
        MedicamentoHeliox._textoObs(
            'Máxima eficácia: obstruções de vias aéreas SUPERIORES'),
        MedicamentoHeliox._textoObs(
            'Menos eficaz em broncoespasmo (vias inferiores)'),
        MedicamentoHeliox._textoObs(
            'Efeito colateral curioso: voz aguda (Donald Duck)'),
        MedicamentoHeliox._textoObs('Contraindicado se necessário FiO₂ >40%'),
        MedicamentoHeliox._textoObs(
            'Contraindicado em pneumotórax não tratado'),
        MedicamentoHeliox._textoObs('RISCO: hipoxemia se FiO₂ inadequada'),
        MedicamentoHeliox._textoObs(
            'Fluxômetro DEVE ser calibrado para heliox'),
        MedicamentoHeliox._textoObs('Sem interações medicamentosas'),
        MedicamentoHeliox._textoObs('Compatível com nebulizações simultâneas'),
        MedicamentoHeliox._textoObs('Seguro na gravidez e lactação'),
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

  static Widget _linhaIndicacaoFluxo({
    required String titulo,
    required int fluxoMin,
    required int fluxoMax,
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Fluxo: $fluxoMin–$fluxoMax L/min',
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
