import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../shared_data.dart';
import 'medicamento_data.dart';
import 'medicamento_info_page.dart';

/// Card principal do medicamento - layout estilo Doses Rápidas (minimalista)
class MedicamentoCard extends StatefulWidget {
  final MedicamentoData medicamento;
  final String idioma;
  final String? indicacaoDestacada;
  final String? termoPesquisa;

  const MedicamentoCard({
    super.key,
    required this.medicamento,
    required this.idioma,
    this.indicacaoDestacada,
    this.termoPesquisa,
  });

  @override
  State<MedicamentoCard> createState() => _MedicamentoCardState();
}

class _MedicamentoCardState extends State<MedicamentoCard> {
  double _doseInfusao = 0.05;
  int _concentracaoSelecionada = 0;
  final Map<String, double> _dosesInfusaoFixa = {};
  final Map<String, int> _concentracaoInfusaoFixa = {};
  bool? _ultimaFaixaEtariaAdulto; // Para detectar mudança de faixa etária

  double get _peso => SharedData.peso ?? 70;
  bool get _isAdulto =>
      SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

  @override
  void initState() {
    super.initState();
    _inicializarSliders();
  }

  void _inicializarSliders() {
    // Slider principal - encontra o slider correto para a faixa etária
    final slider = _getSliderParaIdade();
    if (slider != null) {
      final faixa = _isAdulto ? slider.adulto : slider.pediatrico;
      _doseInfusao = faixa.doseMin;
    }
    _concentracaoSelecionada = 0; // Reset da concentração selecionada

    // Sliders para infusões com dose fixa (mcg/min)
    for (final ind in widget.medicamento.indicacoes) {
      if (ind.isInfusao && !ind.parametros.unidade.contains('/kg')) {
        _dosesInfusaoFixa[ind.titulo] = ind.parametros.doseMin ?? 0;
        _concentracaoInfusaoFixa[ind.titulo] = 0;
      }
    }
    
    _ultimaFaixaEtariaAdulto = _isAdulto;
  }

  /// Verifica se a faixa etária mudou e reinicializa os sliders se necessário
  void _verificarMudancaFaixaEtaria() {
    if (_ultimaFaixaEtariaAdulto != _isAdulto) {
      _inicializarSliders();
    }
  }

  /// Encontra o slider de infusão correto para a faixa etária atual
  SliderInfusaoData? _getSliderParaIdade() {
    for (final slider in widget.medicamento.slidersInfusao) {
      if (_isAdulto && slider.adulto.doseMax > 0) {
        return slider;
      } else if (!_isAdulto && slider.pediatrico.doseMax > 0) {
        return slider;
      }
    }
    return null;
  }

  /// Converte o valor de concentração do JSON para a unidade usada na fórmula mL/h.
  /// Quando [concentracaoEmMcg] é true, valor está em mcg/mL; quando false, em mg/mL.
  /// A fórmula usa (dose * fatorTempo) / concentracao, então concentração deve estar
  /// na mesma unidade de massa que a dose (mcg com mcg, mg com mg).
  double _concentracaoParaCalculoMlHora(double valor, String unidade,
      {required bool concentracaoEmMcg}) {
    final u = unidade.toLowerCase();
    // mg/h e g/h: concentração está sempre em mg/mL ou g/mL (nunca mcg/mL)
    if (u.contains('/h') && (u.contains('mg') || u.contains('g'))) {
      return valor;
    }
    if (u.contains('mcg')) {
      return concentracaoEmMcg ? valor : valor * 1000; // mg/mL → mcg/mL
    }
    if (u.contains('mg')) {
      return concentracaoEmMcg ? valor / 1000 : valor; // mcg/mL → mg/mL ou já mg/mL
    }
    return valor; // U/mL ou outro
  }

  /// Opções de concentração para os sliders de infusão fixa (U/min, mcg/min).
  /// Usa o slider da faixa etária se existir; senão usa o primeiro slider do medicamento,
  /// para que o usuário possa escolher a concentração mesmo quando o slider principal
  /// só existe para outra faixa (ex.: vasopressina adulto tem indicações U/min, slider principal é só pediátrico).
  List<OpcaoConcentracaoData> _getOpcoesConcentracaoParaInfusaoFixa() {
    final slider = _getSliderParaIdade();
    if (slider != null && slider.opcoesConcentracao.isNotEmpty) {
      return slider.opcoesConcentracao;
    }
    if (widget.medicamento.slidersInfusao.isNotEmpty &&
        widget.medicamento.slidersInfusao.first.opcoesConcentracao.isNotEmpty) {
      return widget.medicamento.slidersInfusao.first.opcoesConcentracao;
    }
    return <OpcaoConcentracaoData>[];
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se a faixa etária mudou e reinicializa sliders se necessário
    _verificarMudancaFaixaEtaria();
    
    final med = widget.medicamento;

    // Filtra indicações pela faixa etária e ordena: infusões por último
    final indicacoesFiltradas = med.indicacoes.where((ind) {
      if (_isAdulto) {
        return ind.parametros.isAdulto;
      } else {
        return ind.parametros.isPediatrico;
      }
    }).toList()
      ..sort((a, b) => (a.isInfusao ? 1 : 0).compareTo(b.isInfusao ? 1 : 0));

    final sliderInf = _getSliderParaIdade();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nome + classe + ícone info
            _buildHeader(med),

            const SizedBox(height: 8),

            // Indicações - estilo minimalista
            if (indicacoesFiltradas.isNotEmpty)
              ...indicacoesFiltradas.map((ind) => _buildIndicacaoRow(ind)),

            // Slider de infusão (mostra para /kg ou /h: mcg/kg/min, mg/kg/h, mg/h, g/h)
            // Unidades como mcg/min ou mg/min aparecem inline na indicação
            if (sliderInf != null && 
                (sliderInf.unidade.contains('/kg') || sliderInf.unidade.contains('/h'))) ...[
              const SizedBox(height: 12),
              _buildInfusaoSection(sliderInf),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MedicamentoData med) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: InkWell(
            onTap: _abrirInfoPage,
            borderRadius: BorderRadius.circular(8),
            child: _buildHighlightedText(
              med.nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        // Botão de info
        InkWell(
          onTap: _abrirInfoPage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Verifica se o ajuste renal está ativo para uma indicação
  bool _precisaAjusteRenal(IndicacaoData ind) {
    final clCr = SharedData.clCr;
    final threshold = ind.parametros.clCrThreshold;
    final fator = ind.parametros.fatorAjusteRenal;
    return threshold != null &&
        fator != null &&
        clCr != null &&
        clCr < threshold;
  }

  Widget _buildIndicacaoRow(IndicacaoData ind) {
    String resultado = _calcularDose(ind);
    final isDestacada = widget.indicacaoDestacada == ind.titulo;
    final temAjusteRenal = _precisaAjusteRenal(ind);

    // Para infusão sem /kg (mcg/min, mg/min, mg/h): slider inline APENAS se não existir slider principal com mesma unidade
    if (ind.isInfusao && !ind.parametros.unidade.contains('/kg')) {
      final sliderInf = _getSliderParaIdade();
      final u = ind.parametros.unidade.toLowerCase();
      final indicacaoEhMgOuGh = u.contains('/h') && (u.contains('mg') || u.contains('g'));
      final temSliderPrincipalMgGh = sliderInf != null &&
          sliderInf.unidade.contains('/h') &&
          (sliderInf.unidade.toLowerCase().contains('mg') || sliderInf.unidade.toLowerCase().contains('g'));
      // Se já existe slider principal mg/h ou g/h, mostrar como linha simples (evita duplicar sliders)
      if (indicacaoEhMgOuGh && temSliderPrincipalMgGh) {
        // Cai no bloco abaixo (linha simples para infusão)
      } else {
        return _buildInfusaoFixaSlider(ind, isDestacada: isDestacada);
      }
    }

    // Para infusão: indicação e resultado na mesma linha (nada oculto)
    if (ind.isInfusao) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: isDestacada ? const EdgeInsets.all(6) : EdgeInsets.zero,
        decoration: isDestacada
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildHighlightedText(
                    ind.titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDestacada ? AppColors.primary : null,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      resultado,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: temAjusteRenal
                            ? Colors.orange.shade700
                            : AppColors.primary,
                      ),
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
            if (temAjusteRenal) _buildAjusteRenalInfo(ind),
          ],
        ),
      );
    }

    // Indicação e resultado na mesma linha; descrição abaixo
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: isDestacada ? const EdgeInsets.all(6) : EdgeInsets.zero,
      decoration: isDestacada
          ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildHighlightedText(
                  ind.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDestacada ? AppColors.primary : null,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    resultado,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: temAjusteRenal
                          ? Colors.orange.shade700
                          : AppColors.primary,
                    ),
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4),
            child: _buildHighlightedText(
              ind.descricaoDose,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          if (temAjusteRenal) _buildAjusteRenalInfo(ind),
        ],
      ),
    );
  }

  /// Constrói linha de informação sobre ajuste renal aplicado
  Widget _buildAjusteRenalInfo(IndicacaoData ind) {
    final clCr = SharedData.clCr;
    final fator = ind.parametros.fatorAjusteRenal;

    // Proteção contra valores nulos
    if (clCr == null || fator == null) {
      return const SizedBox.shrink();
    }

    final percentualReducao = ((1 - fator) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 14, color: Colors.orange.shade700),
            const SizedBox(width: 4),
            Text(
              'ClCr ${clCr.toStringAsFixed(0)} mL/min → reduzido $percentualReducao%',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói texto com highlight do termo de pesquisa (exibe todo o texto, sem truncar).
  /// [maxLines] opcional: ex. 1 para título em uma linha (FittedBox pode escalar).
  Widget _buildHighlightedText(String text, {TextStyle? style, int? maxLines}) {
    final corBase = style?.color ?? Colors.black87;
    final estiloBase = (style ?? const TextStyle(fontSize: 14))
        .copyWith(color: corBase);
    final termo = widget.termoPesquisa;
    if (termo == null || termo.isEmpty) {
      return Text(
        text,
        style: estiloBase,
        maxLines: maxLines,
      );
    }

    final termoLower = _removerAcentos(termo.toLowerCase());
    final textLower = _removerAcentos(text.toLowerCase());
    final index = textLower.indexOf(termoLower);

    if (index == -1) {
      return Text(
        text,
        style: estiloBase,
        maxLines: maxLines,
      );
    }

    // Encontra a posição correspondente no texto original
    final antes = text.substring(0, index);
    final match = text.substring(index, index + termo.length);
    final depois = text.substring(index + termo.length);

    return RichText(
      maxLines: maxLines,
      text: TextSpan(
        style: estiloBase,
        children: [
          TextSpan(text: antes),
          TextSpan(
            text: match,
            style: TextStyle(
              color: Colors.black87,
              fontSize: estiloBase.fontSize,
              backgroundColor: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: depois),
        ],
      ),
    );
  }

  String _removerAcentos(String texto) {
    const comAcento = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñçÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝŸÑÇ';
    const semAcento = 'aaaaaaeeeeiiiioooooouuuuyyncAAAAAAEEEEIIIIOOOOOUUUUYYNC';

    for (int i = 0; i < comAcento.length; i++) {
      texto = texto.replaceAll(comAcento[i], semAcento[i]);
    }
    return texto;
  }

  Widget _buildInfusaoFixaSlider(IndicacaoData ind,
      {bool isDestacada = false}) {
    final doseMin = ind.parametros.doseMin ?? 0;
    final doseMax = ind.parametros.doseMax ?? 10;
    final unidade = ind.parametros.unidade;
    final doseAtual = _dosesInfusaoFixa[ind.titulo] ?? doseMin;
    final concIndex = _concentracaoInfusaoFixa[ind.titulo] ?? 0;

    // Opções de concentração: do slider da idade ou do primeiro slider (ex: adulto vasopressina usa U/min mas slider principal é só pediátrico)
    final opcoesConcentracao = _getOpcoesConcentracaoParaInfusaoFixa();
    final sliderRef = _getSliderParaIdade() ?? (widget.medicamento.slidersInfusao.isNotEmpty ? widget.medicamento.slidersInfusao.first : null);
    final valorConc = opcoesConcentracao.isNotEmpty
        ? opcoesConcentracao[concIndex].valor.toDouble()
        : 10.0;

    // Para mg/h e g/h: concentração está SEMPRE em mg/mL, usar valor direto (evita conversão errada)
    final u = unidade.toLowerCase();
    final isMgOuGhPorHora = u.contains('/h') && (u.contains('mg') || u.contains('g'));
    final concentracao = isMgOuGhPorHora
        ? valorConc
        : (sliderRef != null
            ? _concentracaoParaCalculoMlHora(valorConc, unidade, concentracaoEmMcg: sliderRef.concentracaoEmMcg)
            : valorConc);

    // Calcula mL/h baseado na unidade da dose (evita divisão por zero)
    double mlHora;
    if (concentracao <= 0) {
      mlHora = 0;
    } else if (unidade.contains('/h')) {
      // Para doses em g/h ou mg/h: converte para mg e divide pela concentração (mg/mL)
      final fator = unidade.contains('g/h') ? 1000.0 : 1.0;
      mlHora = (doseAtual * fator) / concentracao;
    } else {
      // Para doses em mcg/min ou mg/min: (dose * 60) / concentracao = mL/h
      mlHora = (doseAtual * 60) / concentracao;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: isDestacada ? const EdgeInsets.all(6) : EdgeInsets.zero,
      decoration: isDestacada
          ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicação e faixa na mesma linha (indicação pode usar até 2 linhas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildHighlightedText(
                  ind.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDestacada ? AppColors.primary : null,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_formatDoseInfusao(doseMin, unidade)}-${_formatDoseInfusao(doseMax, unidade)} $unidade',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          if (opcoesConcentracao.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButton<int>(
                value: concIndex.clamp(0, opcoesConcentracao.length - 1),
                isDense: true,
                isExpanded: true,
                underline: const SizedBox(),
                alignment: Alignment.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                selectedItemBuilder: (context) => opcoesConcentracao
                    .map((op) => Center(
                          child: Text(
                            op.rotulo,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
                items: opcoesConcentracao.asMap().entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Center(
                      child: Text(
                        entry.value.rotulo,
                        textAlign: TextAlign.center,
                      ),
                  ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(
                        () => _concentracaoInfusaoFixa[ind.titulo] = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Slider
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: doseAtual.clamp(doseMin, doseMax),
                min: doseMin,
                max: doseMax,
                divisions: _divisionsSliderInfusaoFixa(doseMin, doseMax),
                onChanged: (value) {
                  setState(() => _dosesInfusaoFixa[ind.titulo] = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Resultado: dose + mL/h
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${mlHora.toStringAsFixed(1)} mL/h',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${_formatDoseInfusao(doseAtual, unidade)} $unidade',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                if (mlHora > 500)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Valor alto — confira peso, dose e concentração',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calcularDose(IndicacaoData ind) {
    // Verifica se precisa aplicar ajuste renal
    final clCr = SharedData.clCr;
    final threshold = ind.parametros.clCrThreshold;
    final fator = ind.parametros.fatorAjusteRenal;
    final precisaAjusteRenal =
        threshold != null && fator != null && clCr != null && clCr < threshold;

    if (ind.isCalculada) {
      // Dose calculada com faixa (ex: 1-2 mg/kg)
      if (ind.parametros.dosePorKgMin != null && ind.parametros.dosePorKgMax != null) {
        double doseMin = ind.parametros.dosePorKgMin! * _peso;
        double doseMax = ind.parametros.dosePorKgMax! * _peso;

        // Aplica ajuste renal se necessário
        if (precisaAjusteRenal) {
          doseMin = doseMin * fator;
          doseMax = doseMax * fator;
        }

        // Aplica dose máxima se definida
        if (ind.parametros.doseMaxima != null) {
          if (doseMax > ind.parametros.doseMaxima!) {
            doseMax = ind.parametros.doseMaxima!;
          }
          if (doseMin > doseMax) {
            doseMin = doseMax;
          }
        }

        String resultado = '${_formatNumber(doseMin)}-${_formatNumber(doseMax)} ${ind.parametros.unidade}';
        if (precisaAjusteRenal) {
          resultado += ' ⚠️';
        }
        return resultado;
      }
      // Dose calculada única (ex: 0.01 mg/kg)
      else if (ind.parametros.dosePorKg != null) {
        double dose = ind.parametros.dosePorKg! * _peso;

        // Aplica ajuste renal se necessário
        if (precisaAjusteRenal) {
          dose = dose * fator;
        }

        if (ind.parametros.doseMaxima != null &&
            dose > ind.parametros.doseMaxima!) {
          dose = ind.parametros.doseMaxima!;
        }

        String resultado = '${_formatNumber(dose)} ${ind.parametros.unidade}';
        if (precisaAjusteRenal) {
          resultado += ' ⚠️'; // Indica ajuste renal aplicado
        }
        return resultado;
      }
    } else if (ind.isFixa && ind.parametros.doseFixa != null) {
      // Para dose fixa: calcula dose ajustada se houver ajuste renal
      if (precisaAjusteRenal) {
        // Tenta extrair valor numérico da dose fixa
        final doseOriginal = _extrairValorNumerico(ind.parametros.doseFixa!);
        if (doseOriginal != null) {
          final doseAjustada = doseOriginal * fator;
          final unidade = _extrairUnidade(ind.parametros.doseFixa!);
          return '${_formatNumber(doseAjustada)} $unidade ⚠️';
        }
        // Se não conseguir extrair, mostra original com alerta
        return '${ind.parametros.doseFixa!} ⚠️';
      }
      return ind.parametros.doseFixa!;
    } else if (ind.isInfusao) {
      if (ind.parametros.doseMin != null && ind.parametros.doseMax != null) {
        double doseMin = ind.parametros.doseMin!;
        double doseMax = ind.parametros.doseMax!;

        // Aplica ajuste renal se necessário
        if (precisaAjusteRenal) {
          doseMin = doseMin * fator;
          doseMax = doseMax * fator;
          return '${_formatNumber(doseMin)}-${_formatNumber(doseMax)} ${ind.parametros.unidade} ⚠️';
        }
        return '${ind.parametros.doseMin}-${ind.parametros.doseMax} ${ind.parametros.unidade}';
      }
    }
    return '—';
  }

  /// Extrai o valor numérico de uma string de dose (ex: "4-6 g" -> 5, "2 g" -> 2)
  double? _extrairValorNumerico(String doseStr) {
    // Remove espaços extras
    final limpo = doseStr.trim();

    // Tenta extrair faixa (ex: "4-6")
    final regexFaixa = RegExp(r'(\d+(?:[.,]\d+)?)\s*[-–]\s*(\d+(?:[.,]\d+)?)');
    final matchFaixa = regexFaixa.firstMatch(limpo);
    if (matchFaixa != null) {
      final min = double.tryParse(matchFaixa.group(1)!.replaceAll(',', '.'));
      final max = double.tryParse(matchFaixa.group(2)!.replaceAll(',', '.'));
      if (min != null && max != null) {
        return (min + max) / 2; // Usa média da faixa
      }
    }

    // Tenta extrair valor único (ex: "2")
    final regexUnico = RegExp(r'(\d+(?:[.,]\d+)?)');
    final matchUnico = regexUnico.firstMatch(limpo);
    if (matchUnico != null) {
      return double.tryParse(matchUnico.group(1)!.replaceAll(',', '.'));
    }

    return null;
  }

  /// Extrai a unidade de uma string de dose (ex: "4-6 g" -> "g")
  String _extrairUnidade(String doseStr) {
    // Remove números e traços, pega o resto
    final semNumeros = doseStr.replaceAll(RegExp(r'[\d.,\-–\s]+'), '').trim();
    return semNumeros.isNotEmpty ? semNumeros : 'g';
  }
  Widget _buildInfusaoSection(SliderInfusaoData slider) {
    final faixa = _isAdulto ? slider.adulto : slider.pediatrico;
    final valorConc = slider.opcoesConcentracao.isNotEmpty
        ? slider.opcoesConcentracao[_concentracaoSelecionada].valor.toDouble()
        : 10.0;
    // Concentração em mcg/mL para a fórmula (dose em mcg/min * 60 = mcg/h → mL/h)
    final concentracao = _concentracaoParaCalculoMlHora(
      valorConc,
      slider.unidade,
      concentracaoEmMcg: slider.concentracaoEmMcg,
    );

    // Verifica se a dose é por kg (contém "/kg" na unidade)
    final isDosePorKg = slider.unidade.toLowerCase().contains('/kg');
    final isInfusaoPediatricaUkgMin = slider.unidade == 'U/kg/min';
    final isMcgKgMin = slider.unidade == 'mcg/kg/min';

    // Se for dose por kg, multiplica pelo peso; senão, usa dose fixa
    final doseEfetiva = isDosePorKg ? _doseInfusao * _peso : _doseInfusao;
    final mlHora = concentracao > 0
        ? (doseEfetiva * slider.fatorTempo) / concentracao
        : 0.0;

    // mcg/kg/min com faixa pequena (ex.: Fentanil 0,01–0,08): 3 casas decimais (milésima)
    final decimaisExibicao = isMcgKgMin && faixa.doseMax <= 0.1
        ? 3
        : (isInfusaoPediatricaUkgMin ? 4 : 2);
    final divisions = _divisionsSliderPrincipal(faixa.doseMin, faixa.doseMax, slider.unidade);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Escolha da solução preparada (sempre exibir quando houver opções)
        if (slider.opcoesConcentracao.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<int>(
              value: _concentracaoSelecionada
                  .clamp(0, slider.opcoesConcentracao.length - 1),
              isDense: true,
              isExpanded: true,
              underline: const SizedBox(),
              alignment: Alignment.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              selectedItemBuilder: (context) => slider.opcoesConcentracao
                  .map((op) => Center(
                        child: Text(
                          op.rotulo,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
              items: slider.opcoesConcentracao.asMap().entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Center(
                    child: Text(
                      entry.value.rotulo,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _concentracaoSelecionada = value);
                }
              },
            ),
          ),
          const SizedBox(height: 4),
        ],

        // Slider
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: _doseInfusao.clamp(faixa.doseMin, faixa.doseMax),
              min: faixa.doseMin,
              max: faixa.doseMax,
              divisions: divisions,
              onChanged: (value) {
                setState(() => _doseInfusao = value);
              },
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Resultado
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${mlHora.toStringAsFixed(1)} mL/h',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${_doseInfusao.toStringAsFixed(decimaisExibicao)} ${slider.unidade}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (mlHora > 500)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Valor alto — confira peso, dose e concentração',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _abrirInfoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicamentoInfoPage(
          medicamento: widget.medicamento,
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  /// Formata dose de infusão para exibição. mcg/kg/min com valor ≤ 0,1: 3 casas (milésima).
  String _formatDoseInfusao(double value, String unidade) {
    if (unidade == 'mcg/kg/min' && value <= 0.1 && value >= 0) {
      return value.toStringAsFixed(3);
    }
    if (unidade.contains('/min') || unidade.contains('mcg')) {
      return value.toStringAsFixed(2);
    }
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  /// Divisões do slider principal. mcg/kg/min com faixa pequena: passo milésimo (0,001). U/kg/min: decamilésimo.
  int _divisionsSliderPrincipal(double doseMin, double doseMax, String unidade) {
    final range = (doseMax - doseMin).abs();
    if (unidade == 'U/kg/min' && range < 0.01) {
      return (range * 10000).round().clamp(10, 500);
    }
    // mcg/kg/min com faixa ≤ 0,2 (ex.: Fentanil 0,01–0,08): variação milésima (0,001)
    if (unidade == 'mcg/kg/min' && range <= 0.2) {
      return (range * 1000).round().clamp(10, 500);
    }
    return ((range * 100).round().clamp(1, 1000));
  }

  /// Número de divisões do slider de infusão fixa (U/min, mcg/min).
  /// Faixa pequena (<0,1): muitos passos; faixa 0,1–1 (ex: 0,2–0,4 hemorragia varicosa): passo centesimal (0,01).
  int _divisionsSliderInfusaoFixa(double doseMin, double doseMax) {
    final range = (doseMax - doseMin).abs();
    if (range < 0.1) {
      return (range * 1000).round().clamp(10, 500);
    }
    if (range >= 0.1 && range <= 1.0) {
      return (range * 100).round().clamp(10, 100);
    }
    return (range * 10).round().clamp(1, 100);
  }
}
