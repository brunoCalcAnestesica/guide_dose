import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoOxidoNitroso {
  static const String nome = 'Óxido Nitroso';
  static const String idBulario = 'oxidonitroso';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/oxidonitroso.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardOxidoNitroso(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardOxidoNitroso(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitroso._textoObs('Anestésico geral inalatório, analgésico, gás ansiolítico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitroso._linhaPreparo('Gás comprimido 100% N₂O', 'Cilindros C/D/E/G/H'),
        MedicamentoOxidoNitroso._linhaPreparo('Entonox® 50% N₂O + 50% O₂', 'Mistura fixa em cilindro único'),
        MedicamentoOxidoNitroso._linhaPreparo('Cor cilindro: Azul (N₂O puro)', 'Azul/Branco (Entonox®)'),
        MedicamentoOxidoNitroso._linhaPreparo('Pressão: ~750 psi (cheio a 20°C)', 'Uso hospitalar/odontológico'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitroso._linhaPreparo('Conectar cilindro ao fluxômetro/vaporizador', 'Máquina anestesia ou sistema portátil'),
        MedicamentoOxidoNitroso._linhaPreparo('Programar concentração: 30-70% N₂O', 'Sempre com mínimo 30% O₂'),
        MedicamentoOxidoNitroso._linhaPreparo('Fluxo total: 5-10 L/min (adulto), 3-5 L/min (pediátrico)', 'Titular conforme resposta'),
        MedicamentoOxidoNitroso._linhaPreparo('Entonox®: máscara com válvula demanda', 'Autoadministração'),
        MedicamentoOxidoNitroso._linhaPreparo('Ativar sistema scavenging', 'Evacuação gases expirados'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOxidoNitroso._textoObs('Anestésico fraco (CAM 105-110%) - usar sempre combinado'),
        MedicamentoOxidoNitroso._textoObs('Analgesia potente (equivalente morfina 10-15 mg em 50% N₂O)'),
        MedicamentoOxidoNitroso._textoObs('Onset/offset muito rápidos (2-5 min início, 4-5 min eliminação)'),
        MedicamentoOxidoNitroso._textoObs('ATENÇÃO: Administrar O₂ 100% por 5-10 min após suspender (hipóxia difusional)'),
        MedicamentoOxidoNitroso._textoObs('ATENÇÃO: Expansão cavidades gasosas - contraindicado em pneumotórax, íleo'),
        MedicamentoOxidoNitroso._textoObs('Náuseas/vômitos comuns (20-30% pacientes) - ter antiemético disponível'),
        MedicamentoOxidoNitroso._textoObs('Concentração máxima: 70% N₂O (mínimo 30% O₂ obrigatório)'),
        MedicamentoOxidoNitroso._textoObs('Uso prolongado >4-6h: risco inativação vitamina B12'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
        indicacoes.addAll([
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Sedação Procedimentos (>1 mês)',
            descricaoDose: 'Concentração: 30-50% N₂O + 50-70% O₂ via máscara facial',
            doseFixa: '30-50% N₂O',
          ),
          const SizedBox(height: 8),
          MedicamentoOxidoNitroso._textoObs('• Sempre com oxímetro de pulso e monitoração clínica contínua'),
          MedicamentoOxidoNitroso._textoObs('• Titular concentração até sedação leve (paciente responsivo)'),
          MedicamentoOxidoNitroso._textoObs('• Evitar uso prolongado em neonatos (risco toxicidade B12)'),
        ]);
        break;
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Sedoanalgesia Consciente (Procedimentos)',
            descricaoDose: 'Concentração: 30-50% N₂O + 50-70% O₂',
            doseFixa: '30-50% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Odontologia Pediátrica',
            descricaoDose: 'Concentração: 30-40% N₂O + 60-70% O₂ via máscara nasal',
            doseFixa: '30-40% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Redução Ansiedade Pré-Procedimento',
            descricaoDose: 'Concentração: 20-30% N₂O (ansiólise leve)',
            doseFixa: '20-30% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Componente Anestesia Geral',
            descricaoDose: 'Concentração: 50-70% N₂O + sevoflurano/propofol',
            doseFixa: '50-70% N₂O',
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
        indicacoes.addAll([
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Analgesia Procedimentos Curtos',
            descricaoDose: 'Suturas, curativos, punções - 50% N₂O + 50% O₂ (Entonox®)',
            doseFixa: '50% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Analgesia Obstétrica (Trabalho de Parto)',
            descricaoDose: 'Entonox® 50/50 autoadministrado (paciente inala início contração)',
            doseFixa: '50% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Sedação Odontologia',
            descricaoDose: 'Concentração: 30-50% N₂O + 50-70% O₂',
            doseFixa: '30-50% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Componente Anestesia Geral Balanceada',
            descricaoDose: 'Concentração: 50-70% N₂O (reduz CAM voláteis 30-40%)',
            doseFixa: '50-70% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Sedação Endoscopias/Pequenos Procedimentos',
            descricaoDose: 'Concentração: 30-50% N₂O + sedação IV leve',
            doseFixa: '30-50% N₂O',
          ),
        ]);
        break;
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Analgesia Procedimentos (reduzir concentração)',
            descricaoDose: 'Concentração: 30-40% N₂O + 60-70% O₂ (idosos mais sensíveis)',
            doseFixa: '30-40% N₂O',
          ),
          MedicamentoOxidoNitroso._linhaIndicacaoDoseFixa(
            titulo: 'Componente Anestesia Geral',
            descricaoDose: 'Concentração: 50-60% N₂O (reduzir 10-20% vs adultos)',
            doseFixa: '50-60% N₂O',
          ),
          const SizedBox(height: 8),
          MedicamentoOxidoNitroso._textoObs('• Titular cuidadosamente - idosos mais sensíveis à sedação'),
          MedicamentoOxidoNitroso._textoObs('• Risco aumentado NVPO e hipotensão (associação com outros sedativos)'),
          MedicamentoOxidoNitroso._textoObs('• Atenção em DPOC grave (dependência drive hipóxico)'),
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
              'Concentração: $doseFixa',
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
