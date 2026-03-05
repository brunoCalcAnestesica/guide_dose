import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoIntralipid {
  static const String nome = 'Intralipid 20%';
  static const String idBulario = 'intralipid';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/intralipid.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardIntralipid(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardIntralipid(
      context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardIntralipid(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Emulsão lipídica intravenosa'),
        _textoObs('Antídoto para toxicidade por anestésicos locais (LAST)'),
        _textoObs('Sequestrador lipofílico de fármacos'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Emulsão lipídica 20%', 'Frasco 100mL, 250mL, 500mL'),
        _linhaPreparo('Intralipid®, Lipofundin®', 'Principais marcas'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Administrar puro (não diluir)', 'Via IV exclusiva'),
        _linhaPreparo('Usar equipo sem filtro', 'Filtro retém partículas lipídicas'),
        _linhaPreparo('Agitar suavemente antes de usar', 'Homogeneizar emulsão'),
        _linhaPreparo('Descartar se houver separação de fases', 'Verificar integridade'),
        const SizedBox(height: 16),
        const Text('Indicações - LAST (Toxicidade por Anestésico Local)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('PROTOCOLO ASRA 2020', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('INICIAR IMEDIATAMENTE ao suspeitar de LAST'),
        _textoObs('Manter RCP durante administração se necessário'),
        _textoObs('Dose máxima total: 12 mL/kg de peso magro'),
        _textoObs('Propofol NÃO é substituto (contém apenas 10% de lipídeo)'),
        _textoObs('Evitar vasopressina, bloqueadores de canal de cálcio e beta-bloqueadores'),
        _textoObs('Monitorar por pelo menos 4-6h após estabilização'),
        _textoObs('Pode causar pancreatite, síndrome de sobrecarga lipídica'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria) {
    // Dose máxima baseada em peso magro (usar 12 mL/kg como limite)
    double doseMaximaTotal = 12 * peso;
    if (doseMaximaTotal > 1200) doseMaximaTotal = 1200; // Limite prático de 1200mL

    return [
      _linhaIndicacaoDoseCalculada(
        titulo: '1. BOLUS INICIAL',
        descricaoDose: '1,5 mL/kg IV em bolus (1-2 minutos)',
        unidade: 'mL',
        dosePorKg: 1.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: '2. INFUSÃO CONTÍNUA',
        descricaoDose: '0,25 mL/kg/min IV (iniciar imediatamente após bolus)',
        unidade: 'mL/min',
        dosePorKg: 0.25,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: '3. BOLUS ADICIONAL (se instabilidade persistir)',
        descricaoDose: 'Repetir 1,5 mL/kg a cada 3-5 min (máx 2 bolus adicionais)',
        unidade: 'mL',
        dosePorKg: 1.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: '4. DOBRAR INFUSÃO (se instabilidade persistir)',
        descricaoDose: 'Aumentar para 0,5 mL/kg/min',
        unidade: 'mL/min',
        dosePorKg: 0.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'DOSE MÁXIMA TOTAL',
        descricaoDose: '12 mL/kg nos primeiros 30 minutos',
        unidade: 'mL',
        dosePorKg: 12,
        peso: peso,
        doseMaxima: 1200,
      ),
    ];
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
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
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
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.red.shade200,
                ),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
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
