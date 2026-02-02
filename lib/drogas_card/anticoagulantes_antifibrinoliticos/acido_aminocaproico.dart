import 'package:flutter/material.dart';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAcidoAminocaproico {
  static const String nome = 'Ácido Aminocaproico';
  static const String idBulario = 'acido_aminocaproico';

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAcidoAminocaproico(context, peso, isAdulto),
    );
  }

  static Widget _buildCardAcidoAminocaproico(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoSimples('Antifibrinolítico - Análogo sintético da lisina'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 5g/20mL', '250 mg/mL'),
        _linhaPreparo('Frasco 5g/100mL', '50 mg/mL'),
        _linhaPreparo('Comprimido 500mg', 'Via oral'),
        
        // 3. PREPARO
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('5g + 250mL SF', '20 mg/mL (infusão)'),
        _linhaPreparo('Puro IV lento', 'máx 100 mL/h'),
        _linhaPreparo('Diluir em SF ou SG 5%', 'compatível'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Hiperfibrinólise cirúrgica',
            descricaoDose: 'Ataque: 4-5g IV em 1h → Manutenção: 1g/h por 8h',
            doseFixa: 'Ataque: 4-5g → Manut: 1g/h',
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia em coagulopatia',
            descricaoDose: '100-150 mg/kg IV em 1h (máx 10g)',
            unidade: 'mg',
            dosePorKgMinima: 100,
            dosePorKgMaxima: 150,
            doseMaxima: 10000,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção pós-carga',
            descricaoDose: '1-2 g/h IV contínua por até 8h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia oral',
            descricaoDose: '1-1,5g VO 6/6h (máx 6g/dia)',
            doseFixa: '1-1,5g VO 6/6h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia pediátrica',
            descricaoDose: '100 mg/kg IV em 1h (máx 5g)',
            unidade: 'mg',
            dosePorKg: 100,
            doseMaxima: 5000,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção pediátrica',
            descricaoDose: '33 mg/kg/h IV contínua (máx 18g/dia)',
          ),
        ],
        
        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusao(peso),
        
        // 6. OBSERVAÇÕES (6 principais)
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Alternativa ao ácido tranexâmico (10x menos potente)'),
        _textoObs('Contraindicado: hematúria de origem renal alta'),
        _textoObs('Não usar com concentrado de fator IX (trombose)'),
        _textoObs('Ajustar dose se ClCr < 50 mL/min'),
        _textoObs('Infusão rápida causa hipotensão e bradicardia'),
        _textoObs('Meia-vida: 1-2 horas'),
      ],
    );
  }

  static Widget _textoSimples(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }

  static Widget _linhaPreparo(String texto, String detalhe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(text: texto),
                  if (detalhe.isNotEmpty) ...[
                    const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: detalhe, style: const TextStyle(fontStyle: FontStyle.italic)),
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
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
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
    required String unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
    required double peso,
  }) {
    String textoDose;

    if (dosePorKg != null) {
      double dose = dosePorKg * peso;
      if (doseMaxima != null && dose > doseMaxima) dose = doseMaxima;
      textoDose = '${dose.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) doseMax = doseMaxima;
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    } else {
      textoDose = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          if (textoDose.isNotEmpty) ...[
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
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget para indicações de infusão contínua (sem cálculo)
  static Widget _linhaIndicacaoInfusao({
    required String titulo,
    required String descricaoDose,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  static Widget _buildConversorInfusao(double peso) {
    return _ConversorInfusaoAcidoAminocaproico(peso: peso);
  }
}

class _ConversorInfusaoAcidoAminocaproico extends StatefulWidget {
  final double peso;

  const _ConversorInfusaoAcidoAminocaproico({required this.peso});

  @override
  State<_ConversorInfusaoAcidoAminocaproico> createState() => _ConversorInfusaoAcidoAminocaproicoState();
}

class _ConversorInfusaoAcidoAminocaproicoState extends State<_ConversorInfusaoAcidoAminocaproico> {
  double doseSelecionada = 0.5; // g/h
  String diluicaoSelecionada = '5 g/100 mL (50 mg/mL)';
  
  final Map<String, double> diluicoes = {
    '5 g/100 mL (50 mg/mL)': 50.0, // mg/mL
  };

  @override
  Widget build(BuildContext context) {
    final concentracao = diluicoes[diluicaoSelecionada] ?? 50.0;
    final doseEmMgH = doseSelecionada * 1000; // converter g/h para mg/h
    final mlH = doseEmMgH / concentracao; // mg/h ÷ mg/mL = mL/h

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversor de Infusão',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          
          // Dropdown para diluição
          DropdownButton<String>(
            value: diluicaoSelecionada,
            isExpanded: true,
            onChanged: (val) => setState(() => diluicaoSelecionada = val!),
            items: diluicoes.entries.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(e.key, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Slider para dose
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dose: ${doseSelecionada.toStringAsFixed(1)} g/h',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${mlH.toStringAsFixed(1)} mL/h',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          
          Slider(
            value: doseSelecionada,
            min: 0.1,
            max: 2.0,
            divisions: 19,
            label: '${doseSelecionada.toStringAsFixed(1)} g/h',
            onChanged: (val) => setState(() => doseSelecionada = val),
          ),
          
          const SizedBox(height: 4),
          Text(
            'Peso: ${widget.peso.toStringAsFixed(1)} kg | Concentração: ${concentracao.toStringAsFixed(0)} mg/mL',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}