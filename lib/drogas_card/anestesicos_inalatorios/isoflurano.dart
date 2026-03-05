import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoIsoflurano {
  static const String nome = 'Isoflurano';
  static const String idBulario = 'isoflurano';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/isoflurano.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Isoflurano tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardIsoflurano(
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

    return _buildCardIsoflurano(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardIsoflurano(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIsoflurano._textoObs(
            'Anestésico inalatório halogenado - Agente anestésico volátil'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIsoflurano._linhaPreparo('Frasco 100mL', ''),
        MedicamentoIsoflurano._linhaPreparo('Frasco 250mL', ''),
        MedicamentoIsoflurano._linhaPreparo('Concentração 100%', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIsoflurano._linhaPreparo(
            'Usar vaporizador específico', 'Calibrar antes do uso'),
        MedicamentoIsoflurano._linhaPreparo(
            'Preencher vaporizador', 'Verificar nível constantemente'),
        MedicamentoIsoflurano._linhaPreparo(
            'Compatível', 'Oxigênio (O₂) e Óxido Nitroso (N₂O)'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoIsoflurano._linhaIndicacaoTexto(
            titulo: 'Indução anestésica (em O₂)',
            descricaoDose: '1,5-3% (CAM 1,15%)',
            textoConcentracao: 'Concentração: 1,5-3%',
          ),
          MedicamentoIsoflurano._linhaIndicacaoTexto(
            titulo: 'Indução anestésica (em N₂O/O₂)',
            descricaoDose: '0,5-1,5%',
            textoConcentracao: 'Concentração: 0,5-1,5%',
          ),
          MedicamentoIsoflurano._linhaIndicacaoTexto(
            titulo: 'Manutenção anestésica cirúrgica',
            descricaoDose: '0,5-2% (ajustar conforme profundidade)',
            textoConcentracao: 'Concentração: 0,5-2%',
          ),
        ] else ...[
          MedicamentoIsoflurano._linhaIndicacaoTexto(
            titulo: 'Indução anestésica pediátrica',
            descricaoDose: '1,5-3% em O₂ ou N₂O/O₂',
            textoConcentracao: 'Concentração: 1,5-3%',
          ),
          MedicamentoIsoflurano._linhaIndicacaoTexto(
            titulo: 'Manutenção anestésica pediátrica',
            descricaoDose: '1-2% (CAM maior em crianças)',
            textoConcentracao: 'Concentração: 1-2%',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIsoflurano._textoObs(
            'CAM (Concentração Alveolar Mínima): 1,15%'),
        MedicamentoIsoflurano._textoObs(
            'Coeficiente sangue/gás: 1,4 (indução moderada)'),
        MedicamentoIsoflurano._textoObs('Coeficiente óleo/gás: 98 (potência)'),
        MedicamentoIsoflurano._textoObs('Início de ação: 2-3 minutos'),
        MedicamentoIsoflurano._textoObs('Recuperação: 5-10 minutos'),
        MedicamentoIsoflurano._textoObs(
            'Metabolização: hepática mínima (0,2%)'),
        MedicamentoIsoflurano._textoObs('Excreção: pulmonar (>99% inalterado)'),
        MedicamentoIsoflurano._textoObs(
            'Mecanismo: potencializa GABA-A, inibe NMDA'),
        MedicamentoIsoflurano._textoObs(
            'Produz anestesia geral dose-dependente'),
        MedicamentoIsoflurano._textoObs('Relaxamento muscular moderado'),
        MedicamentoIsoflurano._textoObs('Broncodilatador (útil em asmáticos)'),
        MedicamentoIsoflurano._textoObs('Vasodilatação periférica'),
        MedicamentoIsoflurano._textoObs(
            'Reduz débito cardíaco e PA (dose-dependente)'),
        MedicamentoIsoflurano._textoObs('Mantém FC relativamente estável'),
        MedicamentoIsoflurano._textoObs(
            'Depressão respiratória dose-dependente'),
        MedicamentoIsoflurano._textoObs('Aumenta fluxo sanguíneo cerebral'),
        MedicamentoIsoflurano._textoObs('Pode aumentar PIC (contraindicado)'),
        MedicamentoIsoflurano._textoObs('Neuroproteção em isquemia cerebral'),
        MedicamentoIsoflurano._textoObs(
            'Potencializa bloqueadores neuromusculares'),
        MedicamentoIsoflurano._textoObs('Dose máxima indução: 3%'),
        MedicamentoIsoflurano._textoObs('Dose máxima manutenção: 2%'),
        MedicamentoIsoflurano._textoObs(
            'Monitorar profundidade anestésica (BIS)'),
        MedicamentoIsoflurano._textoObs(
            'Monitorar PA, FC, SpO₂, EtCO₂ continuamente'),
        MedicamentoIsoflurano._textoObs(
            'Monitorar concentração expirada (EtISO)'),
        MedicamentoIsoflurano._textoObs('RISCO: Hipertermia maligna (raro)'),
        MedicamentoIsoflurano._textoObs(
            'RISCO: Depressão cardiovascular em doses altas'),
        MedicamentoIsoflurano._textoObs('RISCO: Hepatite (raríssimo, <0,01%)'),
        MedicamentoIsoflurano._textoObs(
            'Contraindicado: hipertermia maligna (história)'),
        MedicamentoIsoflurano._textoObs(
            'Contraindicado: hipertensão intracraniana'),
        MedicamentoIsoflurano._textoObs('Contraindicado: hepatopatia grave'),
        MedicamentoIsoflurano._textoObs(
            'Cautela: coronariopatia (pode causar roubo coronariano)'),
        MedicamentoIsoflurano._textoObs('Cautela: hipovolemia (vasodilatação)'),
        MedicamentoIsoflurano._textoObs(
            'Categoria C na gravidez (evitar 1º trimestre)'),
        MedicamentoIsoflurano._textoObs('Seguro na lactação após recuperação'),
        MedicamentoIsoflurano._textoObs(
            'Usar vaporizador calibrado específico'),
        MedicamentoIsoflurano._textoObs(
            'NÃO intercambiar vaporizadores entre agentes'),
        MedicamentoIsoflurano._textoObs('Armazenar em local fresco (15-30°C)'),
        MedicamentoIsoflurano._textoObs('Proteger da luz'),
        MedicamentoIsoflurano._textoObs(
            'Não inflamável em concentrações clínicas'),
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

  static Widget _linhaIndicacaoTexto({
    required String titulo,
    required String descricaoDose,
    required String textoConcentracao,
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
              textoConcentracao,
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
