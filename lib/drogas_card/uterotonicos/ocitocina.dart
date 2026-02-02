import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';
import '../../theme/app_colors.dart';

class MedicamentoOcitocina {
  static const String nome = 'Ocitocina';
  static const String idBulario = 'ocitocina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/ocitocina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Ocitocina é APENAS para adultos (uso obstétrico)
    if (!isAdulto) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardOcitocina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardOcitocina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Uterotônico', 'Hormônio peptídico natural'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 5 UI/mL', '1mL | Syntocinon®'),
        _linhaPreparo('Ampola 10 UI/mL', '1mL'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('30 UI + 500mL SG5%', '60 mUI/mL (HPP)'),
        _linhaPreparo('10 UI + 500mL SG5%', '20 mUI/mL (indução)'),
        _textoObs('USO EXCLUSIVAMENTE OBSTÉTRICO'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        // BOLUS - caixa verde
        _linhaIndicacaoDoseFixa(
          titulo: 'Cesárea (profilaxia HPP)',
          descricaoDose: '3-5 UI IV lento ou 10 UI IM após placenta',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'HPP - bolus inicial',
          descricaoDose: '10 UI IM ou 5 UI IV lento',
        ),
        // INFUSÃO - caixa laranja
        _linhaIndicacaoInfusao(
          titulo: 'Indução trabalho de parto',
          descricaoDose: '1-2 mUI/min, ↑1-2 mUI cada 30 min (máx 20 mUI/min)',
        ),
        _linhaIndicacaoInfusao(
          titulo: 'HPP - manutenção',
          descricaoDose: '20-40 mUI/min IV contínua',
        ),
        
        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusao(peso),
        
        // 6. OBSERVAÇÕES (6 mais importantes)
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 3-5 min | Meia-vida: 3-5 min'),
        _textoObs('Monitorar contrações e FCF continuamente'),
        _textoObs('HIPERESTIMULAÇÃO: parar infusão, decúbito lateral'),
        _textoObs('Risco de intoxicação hídrica (hiponatremia) em altas doses'),
        _textoObs('CI: desproporção cefalopélvica, sofrimento fetal'),
        _textoObs('Bolus IV rápido pode causar hipotensão'),
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

  static Widget _linhaIndicacaoDoseFixa({
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
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
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

  static Widget _buildConversorInfusao(double peso) {
    // Concentrações em mUI/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '30 UI + 500mL SG5% (60 mUI/mL)': 60.0, // mUI/mL - HPP
      '10 UI + 500mL SG5% (20 mUI/mL)': 20.0, // mUI/mL - indução
    };

    return ConversaoInfusaoSliderFixo(
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mUI/min',
      doseMin: 1,
      doseMax: 40,
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

// Widget para infusão contínua SEM peso (doses fixas em mUI/min)
class ConversaoInfusaoSliderFixo extends StatefulWidget {
  final Map<String, double> opcoesConcentracoes;
  final double doseMin;
  final double doseMax;
  final String unidade;

  const ConversaoInfusaoSliderFixo({
    Key? key,
    required this.opcoesConcentracoes,
    required this.doseMin,
    required this.doseMax,
    required this.unidade,
  }) : super(key: key);

  @override
  State<ConversaoInfusaoSliderFixo> createState() =>
      _ConversaoInfusaoSliderFixoState();
}

class _ConversaoInfusaoSliderFixoState
    extends State<ConversaoInfusaoSliderFixo> {
  late String concentracaoSelecionada;
  late double dose;
  late double mlHora;
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Selecionar a concentração mais alta como padrão (menor volume de infusão)
    if (widget.opcoesConcentracoes.isNotEmpty) {
      String chaveComMaiorConcentracao = widget.opcoesConcentracoes.keys.first;
      double maiorConcentracao = widget.opcoesConcentracoes.values.first;
      
      for (final entry in widget.opcoesConcentracoes.entries) {
        if (entry.value > maiorConcentracao) {
          maiorConcentracao = entry.value;
          chaveComMaiorConcentracao = entry.key;
        }
      }
      
      concentracaoSelecionada = chaveComMaiorConcentracao;
    } else {
      concentracaoSelecionada = '';
    }
    dose = widget.doseMin.clamp(widget.doseMin, widget.doseMax);
    mlHora = _calcularMlHora();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 280,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: widget.opcoesConcentracoes.length,
                          itemBuilder: (context, index) {
                            final opcao = widget.opcoesConcentracoes.keys
                                .elementAt(index);
                            final isSelected = opcao == concentracaoSelecionada;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade100,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                title: Text(
                                  opcao,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 18,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    concentracaoSelecionada = opcao;
                                    mlHora = _calcularMlHora();
                                  });
                                  _removeOverlay();
                                },
                                tileColor: Colors.transparent,
                                hoverColor:
                                    AppColors.primary.withValues(alpha: 0.05),
                                splashColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  double _calcularMlHora() {
    final conc = widget.opcoesConcentracoes[concentracaoSelecionada];
    if (conc == null || conc == 0) return 0;

    // dose em mUI/min, conc em mUI/mL
    // ml/h = (dose em mUI/min × 60) / conc em mUI/mL
    double mlHora = (dose * 60) / conc;
    return mlHora;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _isDropdownOpen
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Colors.white,
                border: Border.all(
                  color: _isDropdownOpen
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  width: _isDropdownOpen ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _isDropdownOpen
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      concentracaoSelecionada.isNotEmpty
                          ? concentracaoSelecionada
                          : 'Selecionar Solução',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _isDropdownOpen
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: concentracaoSelecionada.isNotEmpty
                            ? (_isDropdownOpen
                                ? AppColors.primary
                                : Colors.black87)
                            : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isDropdownOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _isDropdownOpen
                          ? AppColors.primary
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${dose.toStringAsFixed(2)} ${widget.unidade}',
                style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              '${mlHora.toStringAsFixed(1)} mL/h',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ],
        ),
        Slider(
          value: dose.clamp(widget.doseMin, widget.doseMax),
          min: widget.doseMin,
          max: widget.doseMax,
          divisions: ((widget.doseMax - widget.doseMin) * 99).round(),
          label: '${dose.toStringAsFixed(2)}',
          onChanged: (double value) {
            setState(() {
              dose = value;
              mlHora = _calcularMlHora();
            });
          },
        ),
      ],
    );
  }
}
