import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoOxidoNitrico {
  static const String nome = 'Óxido Nítrico';
  static const String idBulario = 'oxidonitrico';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/oxidonitrico.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    // Óxido nítrico tem uso muito específico - principalmente neonatal
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardOxidoNitrico(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Óxido nítrico inalatório: uso primário em neonatos, pediátrico e adultos em situações específicas
    // Sem uso em idosos de rotina
    return faixaEtaria != 'Idoso';
  }

  static Widget _buildCardOxidoNitrico(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitrico._textoObs('Vasodilatador pulmonar seletivo, gás terapêutico inalatório'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitrico._linhaPreparo('Gás comprimido 100 ppm, 800 ppm ou 1000 ppm', 'NO em N₂ balanceado'),
        MedicamentoOxidoNitrico._linhaPreparo('Cilindros D (425L), E (660L), H/K (6900L)', 'Cor: cinza com faixa verde'),
        MedicamentoOxidoNitrico._linhaPreparo('Pressão: ~2000 psi (cilindro cheio)', 'Uso hospitalar exclusivo'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitrico._linhaPreparo('Conectar cilindro NO ao sistema ventilador', 'Módulo injetor específico (INOmax DS®)'),
        MedicamentoOxidoNitrico._linhaPreparo('Sistema mistura NO com gás inspiratório (ar + O₂)', 'Proporção automática ao fluxo'),
        MedicamentoOxidoNitrico._linhaPreparo('Calibrar sensores NO/NO₂ antes uso', 'Span gas de calibração'),
        MedicamentoOxidoNitrico._linhaPreparo('Verificar alarmes funcionando', 'Alta/baixa NO, alta NO₂, falha cilindro'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitrico._textoObs('Vasodilatador pulmonar seletivo - não causa hipotensão sistêmica'),
        MedicamentoOxidoNitrico._textoObs('ATENÇÃO: Monitorar MetHb a cada 4-8h (manter <5%)'),
        MedicamentoOxidoNitrico._textoObs('ATENÇÃO: Monitorar NO₂ continuamente (limite <2 ppm, máx 5 ppm)'),
        MedicamentoOxidoNitrico._textoObs('NUNCA suspender abruptamente - efeito rebote grave (↑PAP, ↓PaO₂)'),
        MedicamentoOxidoNitrico._textoObs('Desmame gradual: reduzir 5 ppm a cada 4-6h até 5 ppm, depois 1 ppm/vez'),
        MedicamentoOxidoNitrico._textoObs('Ter azul de metileno 1-2 mg/kg IV disponível (emergência MetHb >20%)'),
        MedicamentoOxidoNitrico._textoObs('Reduz necessidade ECMO em 38-40% em HPPN neonatal'),
        MedicamentoOxidoNitrico._textoObs('Doses >40 ppm raramente trazem benefício adicional'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
        indicacoes.addAll([
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Hipertensão Pulmonar Persistente Neonatal (HPPN)',
            descricaoDose: 'Indicação: RN ≥34 semanas gestação, IO >25, insuficiência respiratória hipoxêmica',
            doseFixa: '20 ppm (inicial)',
          ),
          const SizedBox(height: 8),
          MedicamentoOxidoNitrico._textoObs('• Avaliar resposta em 30-60 min: ↑PaO₂ >20 mmHg ou ↓IO >10% = respondedor'),
          MedicamentoOxidoNitrico._textoObs('• Se resposta insuficiente: aumentar para 40 ppm (dose máxima)'),
          MedicamentoOxidoNitrico._textoObs('• Duração típica: 4-5 dias (máximo 14-21 dias)'),
          MedicamentoOxidoNitrico._textoObs('• Meta: IO <10-15, PaO₂ >60 mmHg, FiO₂ <60%'),
          const SizedBox(height: 8),
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Síndrome Aspiração Meconial com HPPN',
            descricaoDose: 'Combinar NO com surfactante pulmonar',
            doseFixa: '20-40 ppm',
          ),
        ]);
        break;
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Cardiopatia Congênita Pós-Operatória',
            descricaoDose: 'Hipoxemia pós-cirurgia cardíaca com hipertensão pulmonar',
            doseFixa: '10-20 ppm (inicial)',
          ),
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Crise Hipertensiva Pulmonar',
            descricaoDose: 'Titular dose conforme PAP e saturação O₂',
            doseFixa: '20-40 ppm',
          ),
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'SDRA Pediátrica (off-label)',
            descricaoDose: 'Melhora oxigenação temporária, sem benefício mortalidade',
            doseFixa: '5-20 ppm',
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
        indicacoes.addAll([
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Teste Vasodilatador Pulmonar (Cateterismo)',
            descricaoDose: 'Avaliar resposta em HAP - critério: ↓PAP >10 mmHg ou >20% basal',
            doseFixa: '10-40 ppm por 5-10 min',
          ),
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Cardiopatia Congênita Pós-Op (adulto)',
            descricaoDose: 'Hipoxemia pós-cirurgia com hipertensão pulmonar',
            doseFixa: '10-20 ppm',
          ),
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'SDRA Moderada-Grave (off-label)',
            descricaoDose: 'Uso controverso - melhora oxigenação temporária, sem redução mortalidade',
            doseFixa: '5-20 ppm',
          ),
          MedicamentoOxidoNitrico._linhaIndicacaoDoseFixa(
            titulo: 'Transplante Pulmonar',
            descricaoDose: 'Prevenção lesão isquemia-reperfusão (protocolo específico)',
            doseFixa: '10-20 ppm',
          ),
        ]);
        break;
    }

    return indicacoes;
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
