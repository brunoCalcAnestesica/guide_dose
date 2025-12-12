import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoInsulinaRegular {
  static const String nome = 'Insulina Regular';
  static const String idBulario = 'insulina_regular';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle
        .loadString('assets/medicamentos/insulina_regular.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Insulina Regular tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardInsulinaRegular(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardInsulinaRegular(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoInsulinaRegular._textoObs(
            'Hormônio pancreático - Hipoglicemiante - Insulina de ação rápida'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoInsulinaRegular._linhaPreparo('Frasco 10mL (100 UI/mL)', ''),
        MedicamentoInsulinaRegular._linhaPreparo('Caneta 3mL (100 UI/mL)', ''),
        MedicamentoInsulinaRegular._linhaPreparo(
            'Cartucho 3mL (100 UI/mL)', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoInsulinaRegular._linhaPreparo(
            'Via SC', 'Pronta para uso - agitar suavemente'),
        MedicamentoInsulinaRegular._linhaPreparo(
            'Via IV (cetoacidose)', 'Diluir 100 UI em 100mL SF 0,9% (1 UI/mL)'),
        MedicamentoInsulinaRegular._linhaPreparo(
            'Infusão SC contínua (bomba)', 'Usar solução pura (100 UI/mL)'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoInsulinaRegular._linhaIndicacaoTexto(
            titulo: 'Cetoacidose diabética (CAD)',
            descricaoDose:
                'Bolus: 0,1 UI/kg IV → Infusão: 0,1 UI/kg/h IV até glicemia 200-250 mg/dL',
            textoCalculo:
                'Bolus inicial: ${(0.1 * peso).toStringAsFixed(1)} UI\nInfusão inicial: 0,1 UI/kg/h',
          ),
          MedicamentoInsulinaRegular._linhaIndicacaoTexto(
            titulo: 'Hiperglicemia aguda (sem CAD)',
            descricaoDose:
                'Escala de correção: Glicemia >150 mg/dL → iniciar com 4-6 UI SC',
            textoCalculo: 'Dose inicial sugerida: 4-6 UI',
          ),
          MedicamentoInsulinaRegular._linhaIndicacaoTexto(
            titulo: 'Controle perioperatório',
            descricaoDose:
                'Alvo glicêmico 140-180 mg/dL → Ajustar dose conforme protocolo',
            textoCalculo: 'Dose individualizada conforme protocolo',
          ),
          MedicamentoInsulinaRegular._linhaIndicacaoTexto(
            titulo: 'Hiperpotassemia (adjuvante)',
            descricaoDose: '10 UI IV + 50mL SG 50% (25g glicose) em bolus',
            textoCalculo: 'Dose fixa: 10 UI + 25g glicose',
          ),
        ] else ...[
          MedicamentoInsulinaRegular._linhaIndicacaoTexto(
            titulo: 'Cetoacidose diabética pediátrica',
            descricaoDose:
                'Infusão: 0,05-0,1 UI/kg/h IV (NÃO fazer bolus inicial)',
            textoCalculo:
                'Infusão inicial: ${(0.05 * peso).toStringAsFixed(2)}-${(0.1 * peso).toStringAsFixed(2)} UI/h',
          ),
          MedicamentoInsulinaRegular._linhaIndicacaoTexto(
            titulo: 'Diabetes tipo 1 pediátrico',
            descricaoDose: '0,5-1 UI/kg/dia SC dividido em múltiplas doses',
            textoCalculo:
                'Dose diária total: ${(0.5 * peso).toStringAsFixed(1)}-${(1.0 * peso).toStringAsFixed(1)} UI/dia',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoInsulinaRegular._buildConversorInfusao(peso, isAdulto),

        const SizedBox(height: 16),

        // Observações
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoInsulinaRegular._textoObs('Início SC: 30-60 minutos'),
        MedicamentoInsulinaRegular._textoObs('Pico SC: 2-4 horas'),
        MedicamentoInsulinaRegular._textoObs('Duração SC: 6-8 horas'),
        MedicamentoInsulinaRegular._textoObs('Meia-vida: 4-6 horas'),
        MedicamentoInsulinaRegular._textoObs('Início IV: IMEDIATO'),
        MedicamentoInsulinaRegular._textoObs('Duração IV: 30-60 minutos'),
        MedicamentoInsulinaRegular._textoObs(
            'Promove captação de glicose pelos tecidos (músculo, adipócitos)'),
        MedicamentoInsulinaRegular._textoObs(
            'Inibe produção hepática de glicose'),
        MedicamentoInsulinaRegular._textoObs('Inibe lipólise'),
        MedicamentoInsulinaRegular._textoObs('Promove síntese proteica'),
        MedicamentoInsulinaRegular._textoObs(
            'Ativa transportadores GLUT-4 na membrana celular'),
        MedicamentoInsulinaRegular._textoObs(
            'RISCO DE HIPOGLICEMIA - monitorar glicemia rigorosamente'),
        MedicamentoInsulinaRegular._textoObs(
            'MONITORAR GLICEMIA DE HORA EM HORA durante infusão IV'),
        MedicamentoInsulinaRegular._textoObs(
            'RISCO DE HIPOPOTASSEMIA - monitorar K+ durante infusão IV'),
        MedicamentoInsulinaRegular._textoObs(
            'Ajustar dose conforme glicemia, dieta, atividade física'),
        MedicamentoInsulinaRegular._textoObs(
            'Cetoacidose: NÃO reduzir glicemia >100 mg/dL/h (risco de edema cerebral)'),
        MedicamentoInsulinaRegular._textoObs(
            'Quando glicemia <250 mg/dL na CAD: associar SG 5% + manter insulina'),
        MedicamentoInsulinaRegular._textoObs(
            'Via IV: usar bomba de infusão (adsorção em equipo)'),
        MedicamentoInsulinaRegular._textoObs(
            'Via SC: rodiziar locais de aplicação (lipodistrofia)'),
        MedicamentoInsulinaRegular._textoObs(
            'Aplicar 30 min antes das refeições (via SC)'),
        MedicamentoInsulinaRegular._textoObs(
            'Nunca administrar IM de rotina (absorção errática)'),
        MedicamentoInsulinaRegular._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoInsulinaRegular._textoObs(
            'Armazenar refrigerado (2-8°C) antes da abertura'),
        MedicamentoInsulinaRegular._textoObs(
            'Após abertura: temperatura ambiente por até 28 dias'),
        MedicamentoInsulinaRegular._textoObs(
            'Descartar se mudança de cor, precipitação ou cristalização'),
        MedicamentoInsulinaRegular._textoObs(
            'Reduzir dose em insuficiência renal grave'),
        MedicamentoInsulinaRegular._textoObs(
            'Monitorar glicemia em insuficiência hepática'),
        MedicamentoInsulinaRegular._textoObs(
            'Betabloqueadores podem mascarar sintomas de hipoglicemia'),
        MedicamentoInsulinaRegular._textoObs(
            'Glicocorticoides aumentam necessidade de insulina'),
        MedicamentoInsulinaRegular._textoObs(
            'Categoria B na gravidez (segura, ajustar dose)'),
        MedicamentoInsulinaRegular._textoObs(
            'Segura na lactação (pode necessitar redução de dose)'),
        MedicamentoInsulinaRegular._textoObs(
            'Ter glicose IV 50% disponível para hipoglicemia grave'),
        MedicamentoInsulinaRegular._textoObs(
            'Sintomas de hipoglicemia: sudorese, tremor, taquicardia, confusão'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '500 UI em 250mL SF 0,9% (2 UI/mL)': 2.0, // UI/mL - concentrada
      '100 UI em 100mL SF 0,9% (1 UI/mL)': 1.0, // UI/mL - padrão adulto
      '50 UI em 50mL SF 0,9% (1 UI/mL)': 1.0, // UI/mL - padrão pediátrico
      '100 UI em 250mL SF 0,9% (0,4 UI/mL)': 0.4, // UI/mL - diluição estendida
      '50 UI em 100mL SF 0,9% (0,5 UI/mL)': 0.5, // UI/mL - pediátrico diluído
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'UI/kg/h',
        doseMin: 0.02,
        doseMax: 0.2,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'UI/kg/h',
        doseMin: 0.05,
        doseMax: 0.1,
      );
    }
  }

  static Widget _linhaIndicacaoTexto({
    required String titulo,
    required String descricaoDose,
    required String textoCalculo,
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
              textoCalculo,
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
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
