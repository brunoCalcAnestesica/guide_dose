import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAngiotensinaII {
  static const String nome = 'Angiotensina II';
  static const String idBulario = 'angiotensina_ii';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/angiotensina_ii.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Angiotensina II: uso apenas em adultos
    if (!isAdulto) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAngiotensinaII(
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

    return _buildCardAngiotensinaII(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardAngiotensinaII(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Vasopressor', 'Peptídeo vasoativo endógeno'),
        _linhaPreparo('Mecanismo', 'Agonista receptor AT1'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 2,5mg/mL', '1mL (2,5mg) | Giapreza®'),
        _linhaPreparo('Frasco 2,5mg/mL', '2mL (5mg)'),
        
        // 3. PREPARO
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('2,5mg + 250mL SF/SG5%', '10.000 ng/mL'),
        _linhaPreparo('5mg + 500mL SF/SG5%', '10.000 ng/mL'),
        _textoObs('Via central ou periférica de grande calibre'),
        _textoObs('Estável por 24h em temperatura ambiente'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaIndicacaoInfusao(
          titulo: 'Choque vasodilatador refratário',
          descricaoDose: 'Iniciar 20 ng/kg/min, titular a cada 5 min',
        ),
        _linhaIndicacaoInfusao(
          titulo: 'Dose de manutenção',
          descricaoDose: '1,25-40 ng/kg/min (titular para PAM ≥65)',
        ),
        _linhaIndicacaoInfusao(
          titulo: 'Choque séptico (adjuvante a catecolaminas)',
          descricaoDose: '20-40 ng/kg/min (se noradrenalina >0,2 mcg/kg/min)',
        ),
        
        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusao(peso),
        
        // 6. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 5 min | Meia-vida: <1 min'),
        _textoObs('INDICAÇÃO: choque refratário a catecolaminas'),
        _textoObs('Reduzir catecolaminas conforme resposta'),
        _textoObs('RISCO: trombose arterial/venosa (profilaxia TEV)'),
        _textoObs('CI: uso concomitante com IECA/BRA (antagonismo)'),
        _textoObs('NÃO usar em pediatria (sem estudos)'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso) {
    final opcoesConcentracoes = {
      '5mg + 500mL (10.000 ng/mL)': 10000.0,
      '2,5mg + 250mL (10.000 ng/mL)': 10000.0,
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'ng/kg/min',
      doseMin: 1.25,
      doseMax: 40,
      concentracaoEmMcg: false, // concentração em ng/mL
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

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
