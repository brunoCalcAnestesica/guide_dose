import 'package:flutter/material.dart';
import 'shared_data.dart';
import 'theme/app_theme.dart';
import 'dart:math';


class FisiologiaPage extends StatefulWidget {
  const FisiologiaPage({super.key});

  @override
  State<FisiologiaPage> createState() => _FisiologiaPageState();
}
class _FisiologiaPageState extends State<FisiologiaPage> {
  @override
  Widget build(BuildContext context) {
    // Verificar se os dados estão preenchidos antes de usar
    if (SharedData.peso == null || SharedData.altura == null || SharedData.idade == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Parâmetros de Fisiologia'),
        ),
        body: const Center(
          child: Text(
            'Por favor, preencha os dados de Peso, Altura e Idade na aba Paciente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // Agora que sabemos que os valores não são null, podemos usá-los
    double peso = SharedData.peso!;
    double altura = SharedData.altura!;
    double idade = SharedData.idade!;
    double imcPaciente = calcularIMC(peso, altura);
    String classificacaoIMC = classificarIMC(imcPaciente, idade);
    double pesoIdeal = calcularPesoIdeal(altura, idade, SharedData.sexo);
    double pesoParaDispositivos = idade >= 18 ? pesoIdeal : peso;
    String tuboComCuffTexto = calcularTuboOrotraquealComCuff(idade, peso, altura, SharedData.sexo);
    double tuboComCuffNumero = _extrairPrimeiroNumero(tuboComCuffTexto);

    // Cálculos





    return Scaffold(
      appBar: AppBar(
        title: const Text('Parâmetros de Fisiologia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ListView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + AppSpacing.screenPadding),
          children: [ //_________________________________ Retorno do Calculo

            _buildListaAntropometrica([
              _buildResultadoSimplesListaAntropometrica(
                'Peso Ideal',
                pesoIdeal,
                'kg',
              ),
              _buildResultadoSimplesValorPronto(
                'Peso Corrigido',
                calcularPesoCorrigido(peso, altura, idade, SharedData.sexo),
              ),
              _buildResultadoSimplesValorPronto(
                'Superfície Corporal Ajustada',
                calcularSuperficieCorporal(peso, altura, idade, SharedData.sexo),
              ),
              _buildResultadoSimplesListaAntropometrica(
                'IMC ($classificacaoIMC)', // <== Agora aparece a classificação
                imcPaciente,
                'kg/m²',
              ),
              _buildResultadoSimplesListaAntropometrica(
                'Percentual de Peso Ideal',
                calcularPercentualPesoIdeal(peso, altura, idade, SharedData.sexo),
                '%',
              ),
              _buildResultadoSimplesListaAntropometrica(
                'Peso para Altura',
                calcularPesoParaAltura(peso, altura, idade, SharedData.sexo),
                '%',
              ),

              ResultadoExpandido(
                subtitulo: 'Peso Esperado',
                valores: calcularPesoEsperado(idade, SharedData.sexo),
              ),
              ResultadoExpandido(
                subtitulo: 'Altura Esperada',
                valores: calcularAlturaEsperada(idade, SharedData.sexo),
              ),
              ResultadoExpandido(
                subtitulo: 'IMC Esperado',
                valores: calcularIMCEsperado(idade, SharedData.sexo),
              ),





            ]), // Dados Antropometricos

            _buildListaParametrosCirculatorios([
              ResultadoExpandido(
                subtitulo: 'FC',
                valores: calcularFrequenciaCardiacaEsperada(
                  idade,
                  peso,
                  altura,
                  SharedData.sexo,
                ),
              ),



              ResultadoExpandidoPressao(
                subtitulo: 'PA',
                valores: calcularPressaoArterialEsperada(
                  idade,
                  SharedData.sexo,
                  peso,
                  altura,
                ),
              ),

              _buildResultadoVentilatorio(
                'Volume Plasmático',
                calcularVolumePlasmatico(
                  idade,
                  peso,
                  SharedData.sexo,
                ),
                'mL',
              ),

              _buildResultadoSimplesListaAntropometrica(
                'Volume Diário de Infusão',
                calcularVolumeDiarioInfusao(peso, idade),
                'mL/dia',
              ),

              _buildResultadoSimplesListaAntropometrica(
                'Velocidade de Infusão',
                calcularVelocidadeInfusaoHora(peso, idade),
                'mL/h',
              ),
              _buildResultadoSimplesValorPronto(
                'TPC',
                () {
                  final reperfusao = calcularIntervaloReperfusaoCapilar(peso, altura, idade, SharedData.sexo);
                  return '${reperfusao['P5']} seg - ${reperfusao['P95']} seg';
                }(),
              ),
              _buildResultadoDispositivoExtra(
                'Hidratação Entérica',
                calcularVolumeReposicaoGastrica(
                  peso,
                  idade,
                ),
              ),
              _buildResultadoDispositivoExtra(
                'Creatinina Esperada',
                calcularCreatininaEsperada(
                  idade,
                  SharedData.sexo,
                ),
              ),



            ]), // Parâmetros Circulatórios

            _buildListaParametrosVentilatorios([
              // Dispositivos de via aérea: em adultos (>18 anos), o tamanho das
              // estruturas anatômicas (face, faringe) não aumenta com obesidade,
              // então usamos peso ideal. Em crianças, peso real correlaciona bem.
              _buildResultadoVentilatorio(
                'Máscara Facial',
                calcularMascaraFacial(
                  pesoParaDispositivos,
                  idade,
                ),
              ),

              _buildResultadoVentilatorio(
                'Cânula de Guedel ',
                calcularCanulaOroFaringea(
                  pesoParaDispositivos,
                  idade,
                ),
              ),
              _buildResultadoVentilatorio(
                'Cânula Nasofaringea',
                calcularCanulaNasoFaringea(
                  pesoParaDispositivos,
                  idade,
                ),
              ),
              _buildResultadoVentilatorio(
                'Tubo Laringeo',
                calcularCombitubo(
                  pesoParaDispositivos,
                  altura,
                ),
                '',
              ),

              _buildResultadoVentilatorio(
                'Máscara Laríngea',
                calcularMascaraLaringea(
                  pesoParaDispositivos,
                ),
                '',
              ),
              _buildResultadoVentilatorio(
                'Laringoscópio Reto',
                calcularLaminaRetaMiller(idade),
              ),

              _buildResultadoVentilatorio(
                'Laringoscópio Curvo',
                calcularLaminaCurvaMacintosh(idade),
              ),

              _buildResultadoVentilatorio(
                'TOT (com cuff)',
                tuboComCuffTexto,
                '',
              ),


              _buildResultadoVentilatorio(
                'TOT (sem cuff)',
                calcularTuboOrotraquealSemCuff(
                  idade,
                  peso,
                  altura,
                  SharedData.sexo,
                ),
                '',
              ),
              _buildResultadoVentilatorio(
                'Altura da Fixação',
                calcularAlturaFixacao(
                  idade,
                  peso,
                  altura,
                  SharedData.sexo,
                ),
                'cm',
              ),

              _buildResultadoVentilatorio(
                'Cânula de Traqueostomia',
                calcularCanulaTraqueostomia(
                  idade,
                  pesoParaDispositivos,
                  altura,
                  SharedData.sexo,
                ),
                '',
              ),

              _buildResultadoDispositivoExtra(
                'Cateter de Aspiração Brônquica',
                calcularBroncoCat(
                  tuboComCuffNumero, // Usa o TOT calculado
                ),
              ),

              _buildResultadoDispositivoExtra(
                'BroncoCat (TRS)',
                calcularTuboRobertshaw(
                  altura,
                  SharedData.sexo,
                  idade,
                ),
              ),
              _buildResultadoDispositivoExtra(
                'Fixação do Tubo Robertshaw',
                calcularFixacaoRobertshaw(
                  altura,
                  idade,
                ),
              ),


            ]), // Parâmetros Ventilatórios

            _buildListaParametrosRespiratorios([
              _buildResultadoVentilatorio(
                'Frequência Respiratória',
                calcularFrequenciaRespiratoria(idade),
                'rpm',
              ),
              // IMPORTANTE: Volume Corrente usa PESO IDEAL (não peso real)
              // para evitar volutrauma em obesos
              _buildResultadoVentilatorio(
                'Volume Corrente',
                calcularVolumeCorrente(pesoIdeal, idade),
                'mL',
              ),

              _buildResultadoVentilatorio(
                'Volume Minuto',
                calcularVolumeMinuto(
                  idade,
                  pesoIdeal, // Usa peso ideal
                ),
                'L/min',
              ),
              _buildResultadoVentilatorio(
                'Relação I:E',
                calcularRelacaoIE(idade),
                '',
              ),

              _buildResultadoVentilatorio(
                'Espaço Morto',
                calcularEspacoMorto(
                  idade,
                  pesoIdeal, // Usa peso ideal
                ),
                'mL',
              ),

              _buildResultadoVentilatorio(
                'Pressão de Pico',
                calcularPressaoDePico(
                  idade,
                ),
                'cmH₂O',
              ),


              _buildResultadoVentilatorio(
                'PEEP Sugerida',
                calcularPEEP(idade),
                'cmH₂O',
              ),

            ]),

            _buildListaDispositivosExtras([


              _buildResultadoDispositivoExtra(
                'Sonda Vesical de Demora',
                calcularSondaVesical(
                  idade,
                  SharedData.sexo,
                ),
              ),

              _buildResultadoDispositivoExtra(
                'Dreno de Kehr',
                calcularDrenoKehr(
                  idade,
                ),
              ),

              // SNG/SNE: calibre baseado em idade. Em adultos, peso ideal é mais
              // apropriado pois o diâmetro do esôfago não aumenta com obesidade
              _buildResultadoDispositivoExtra(
                'Sonda Nasogástrica (SNG)',
                calcularSondaNasogastrica(
                  idade,
                  pesoParaDispositivos,
                ),
              ),

              _buildResultadoDispositivoExtra(
                'Fixação da SNG',
                calcularFixacaoSNG(
                  pesoParaDispositivos,
                  altura,
                ),
              ),

              _buildResultadoDispositivoExtra(
                'Sonda Nasoentérica (SNE)',
                calcularSondaNasoenterica(
                  idade,
                  pesoParaDispositivos,
                ),
              ),
              _buildResultadoDispositivoExtra(
                'Fixação da SNE ',
                calcularFixacaoSondaNasoenterica(
                  altura,
                ),
              ),


              _buildResultadoDispositivoExtra(
                'Calibre recomendado',
                calcularCateterShilley(
                  altura: altura,
                  peso: pesoParaDispositivos,
                  idade: idade,
                  local: 'jugular',
                )['Calibre'] ?? '-',
              ),

              ResultadoExpandidoAcessoCentral(
                subtitulo: 'Acesso Central',
                jugular: calcularCateterShilley(
                  altura: altura,
                  peso: pesoParaDispositivos,
                  idade: idade,
                  local: 'jugular',
                ),
                subclavia: calcularCateterShilley(
                  altura: altura,
                  peso: pesoParaDispositivos,
                  idade: idade,
                  local: 'subclavia',
                ),
              ),

              ResultadoExpandidoCateterShilley(
                subtitulo: 'Cateter de Shilley',
                jugular: calcularCateterShilley(
                  altura: altura,
                  peso: pesoParaDispositivos,
                  idade: idade,
                  local: 'jugular',
                ),
                subclavia: calcularCateterShilley(
                  altura: altura,
                  peso: pesoParaDispositivos,
                  idade: idade,
                  local: 'subclavia',
                ),
                femoral: calcularCateterShilley(
                  altura: altura,
                  peso: pesoParaDispositivos,
                  idade: idade,
                  local: 'femoral',
                ),
              ),
            ]), // Parâmetros Respiratórios




          ], // Fecha o ListView

        ), // Fecha o Padding
      ), // Fecha o Scaffold
    ); // Fecha o build()
  }} // fecha State





class ResultadoExpandidoAcessoCentral extends StatefulWidget {
  final String subtitulo;
  final Map<String, String> jugular;
  final Map<String, String> subclavia;

  const ResultadoExpandidoAcessoCentral({
    Key? key,
    required this.subtitulo,
    required this.jugular,
    required this.subclavia,
  }) : super(key: key);

  @override
  State<ResultadoExpandidoAcessoCentral> createState() => _ResultadoExpandidoAcessoCentralState();
}

class _ResultadoExpandidoAcessoCentralState extends State<ResultadoExpandidoAcessoCentral> {
  bool expandido = false;

  @override
  Widget build(BuildContext context) {
    String calibreJugular = widget.jugular['Calibre'] ?? '-';
    String comprimentoJugular = widget.jugular['Comprimento'] ?? '-';
    String calibreSubclavia = widget.subclavia['Calibre'] ?? '-';
    String comprimentoSubclavia = widget.subclavia['Comprimento'] ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => expandido = !expandido),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(widget.subtitulo, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Icon(
                      expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  '$calibreJugular / $calibreSubclavia',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (expandido) ...[
            const SizedBox(height: 4),
            _linhaLocal('Jugular', calibreJugular, comprimentoJugular),
            const SizedBox(height: 2),
            _linhaLocal('Subclávia', calibreSubclavia, comprimentoSubclavia),
          ],
        ],
      ),
    );
  }

  Widget _linhaLocal(String titulo, String calibre, String comprimento) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14)),
        Text('$calibre / $comprimento', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}









































// PARAMETROS CIRCULATÓRIOS
double calcularPesoIdeal(double altura, double idade, String sexo) {
  if (idade < (1 / 30)) {
    // Menos de 1 mês de vida (RN)
    return 3.5;
  } else if (idade >= (1 / 30) && idade < 1) {
    // De 1 mês a 12 meses
    // Fórmula: (idade em meses + 9) / 2
    double idadeEmMeses = idade * 12;
    return (idadeEmMeses + 9) / 2;
  } else if (idade >= 1 && idade < 2) {
    // De 1 a 2 anos
    // Peso médio de 10 kg aos 12 meses, aumentando ~2.5 kg/ano
    return 10 + ((idade - 1) * 2.5);
  } else if (idade >= 2 && idade <= 10) {
    // Criança (2-10 anos)
    return (idade * 2) + 8;
  } else if (idade > 10 && idade < 18) {
    // Adolescente (10-18 anos)
    // Fórmula ajustada: considera crescimento mais acelerado
    if (sexo == 'Masculino') {
      return 30 + ((idade - 10) * 4.5); // ~30kg aos 10 anos, +4.5kg/ano
    } else {
      return 30 + ((idade - 10) * 4.0); // ~30kg aos 10 anos, +4kg/ano
    }
  } else {
    // Adultos (considera altura e sexo) - Fórmula de Devine
    if (sexo == 'Masculino') {
      return 50 + 0.91 * (altura - 152.4);
    } else {
      return 45.5 + 0.91 * (altura - 152.4);
    }
  }
}// Peso Ideal 1
Widget _buildResultadoSimplesListaAntropometrica(String subtitulo, double valor, String unidade) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          subtitulo,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          '${valor.toStringAsFixed(1)} $unidade',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
} // Peso Ideal 2
String calcularPesoCorrigido(double pesoAtual, double altura, double idade, String sexo) {
  if (pesoAtual == 0 || altura == 0 || idade == 0) {
    return '-';
  }

  // Buscar o peso ideal já considerando o sexo
  double pesoIdeal = calcularPesoIdeal(altura, idade, sexo);


  double pesoCorrigido;

  if (pesoAtual > pesoIdeal * 1.2) {
    pesoCorrigido = pesoIdeal + 0.4 * (pesoAtual - pesoIdeal);
  } else {
    pesoCorrigido = pesoAtual;
  }

  return '${pesoCorrigido.toStringAsFixed(1)} kg';
}  // Peso Corrigido 1
Widget _buildResultadoSimplesValorPronto(String subtitulo, String valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          subtitulo,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}  // Peso Corrigido 2

double _extrairPrimeiroNumero(String texto) {
  final match = RegExp(r'([0-9]+(?:[.,][0-9]+)?)').firstMatch(texto);
  if (match == null) return 0;
  final raw = match.group(1)!.replaceAll(',', '.');
  return double.tryParse(raw) ?? 0;
}

String calcularSuperficieCorporal(double peso, double altura, double idade, String sexo) {
  if (peso == 0 || altura == 0 || idade == 0) {
    return '-';
  }

  double bsa = sqrt((peso * altura) / 3600);

  // Ajuste baseado na idade
  double fatorCorrecao = 1.0;

  if (idade > 40 && idade <= 60) {
    fatorCorrecao -= (idade - 40) * 0.005;
  } else if (idade > 60) {
    fatorCorrecao -= (20 * 0.005) + ((idade - 60) * 0.01);
  }

  double bsaAjustado = bsa * fatorCorrecao;

  // Retorna apenas uma string
  return '${bsaAjustado.toStringAsFixed(2)} m²';
} // Superfície Corporal
Map<String, String> calcularPesoEsperado(double idade, String sexo) {
  double p5 = 0;
  double p50 = 0;
  double p95 = 0;

  if (idade < (1 / 30)) {
    // Neonatos (< 1 mês)
    p5 = (sexo == 'Masculino') ? 2.5 : 2.4;
    p50 = (sexo == 'Masculino') ? 3.5 : 3.4;
    p95 = (sexo == 'Masculino') ? 4.5 : 4.4;
  } else if (idade < 1) {
    // Lactentes (1 mês a 1 ano)
    // Usando curvas de crescimento aproximadas
    double idadeEmMeses = idade * 12;
    if (sexo == 'Masculino') {
      p50 = 4.0 + (idadeEmMeses * 0.6); // ~10 kg aos 12 meses
    } else {
      p50 = 3.8 + (idadeEmMeses * 0.55); // ~9.5 kg aos 12 meses
    }
    p5 = p50 * 0.82;
    p95 = p50 * 1.18;
  } else if (idade >= 1 && idade < 2) {
    // Criança pequena (1-2 anos)
    p50 = (sexo == 'Masculino') ? 10.0 + ((idade - 1) * 2.5) : 9.5 + ((idade - 1) * 2.3);
    p5 = p50 * 0.82;
    p95 = p50 * 1.18;
  } else if (idade >= 2 && idade <= 10) {
    // Crianças (2-10 anos)
    p50 = (sexo == 'Masculino') ? (idade * 2) + 8 : (idade * 2) + 7;
    p5 = p50 * 0.85;
    p95 = p50 * 1.15;
  } else if (idade > 10 && idade <= 18) {
    // Adolescentes (10-18 anos)
    // Fórmula ajustada: ~28-30 kg aos 10 anos, crescimento acelerado
    if (sexo == 'Masculino') {
      p50 = 30.0 + ((idade - 10) * 4.5); // ~66 kg aos 18 anos
    } else {
      p50 = 30.0 + ((idade - 10) * 3.8); // ~60 kg aos 18 anos
    }
    p5 = p50 * 0.80;
    p95 = p50 * 1.20;
  } else {
    // Adultos (> 18 anos)
    p50 = (sexo == 'Masculino') ? 70 : 60;
    p5 = p50 * 0.85;
    p95 = p50 * 1.15;
  }

  return {
    'P5': '${p5.toStringAsFixed(1)} kg',
    'P50': '${p50.toStringAsFixed(1)} kg',
    'P95': '${p95.toStringAsFixed(1)} kg',
  };
} // Peso Esperado
double calcularIMC(double peso, double altura) {
  if (peso == 0 || altura == 0) {
    return 0;
  }
  double alturaMetros = altura / 100; // transformar cm para metros
  return peso / (alturaMetros * alturaMetros);
} // IMC
String classificarIMC(double imc, double idade) {
  if (idade < 18) {
    return 'interpretar por percentil';
  }
  if (imc < 18.5) {
    return 'Abaixo do Peso';
  } else if (imc < 25) {
    return 'Normal';
  } else if (imc < 30) {
    return 'Sobrepeso';
  } else if (imc < 35) {
    return 'Obesidade Grau I';
  } else if (imc < 40) {
    return 'Obesidade Grau II';
  } else {
    return 'Obesidade Grau III';
  }
}
Map<String, String> calcularIMCEsperado(double idade, String sexo) {
  double p5 = 0;
  double p50 = 0;
  double p95 = 0;

  if (idade < (1 / 30)) {
    // Recém-nascido
    p5 = (sexo == 'Masculino') ? 11.5 : 11.0;
    p50 = (sexo == 'Masculino') ? 13.5 : 13.0;
    p95 = (sexo == 'Masculino') ? 15.5 : 15.0;
  } else if (idade < 2) {
    // Lactentes
    p5 = (sexo == 'Masculino') ? 15 : 14;
    p50 = (sexo == 'Masculino') ? 17 : 16;
    p95 = (sexo == 'Masculino') ? 19 : 18;
  } else if (idade >= 2 && idade <= 10) {
    // Crianças
    p5 = (sexo == 'Masculino') ? 14 : 13.5;
    p50 = (sexo == 'Masculino') ? 16 : 15.5;
    p95 = (sexo == 'Masculino') ? 18 : 17.5;
  } else if (idade > 10 && idade <= 18) {
    // Adolescentes
    p5 = (sexo == 'Masculino') ? 17 : 17.5;
    p50 = (sexo == 'Masculino') ? 20 : 21;
    p95 = (sexo == 'Masculino') ? 24 : 25;
  } else {
    // Adultos
    p5 = (sexo == 'Masculino') ? 19 : 18;
    p50 = (sexo == 'Masculino') ? 22 : 21;
    p95 = (sexo == 'Masculino') ? 27 : 26;

    // Ajuste leve para idosos (>60 anos)
    if (idade > 60) {
      p5 -= 1;
      p50 -= 1;
      p95 -= 1;
    }
  }

  return {
    'P5': '${p5.toStringAsFixed(1)} kg/m²',
    'P50': '${p50.toStringAsFixed(1)} kg/m²',
    'P95': '${p95.toStringAsFixed(1)} kg/m²',
  };
}  // IMC esperado
Map<String, String> calcularAlturaEsperada(double idade, String sexo) {
  double p5 = 0;
  double p50 = 0;
  double p95 = 0;

  if (idade < (1 / 30)) {
    // Recém-nascido (1 dia)
    p5 = (sexo == 'Masculino') ? 48 : 47;
    p50 = (sexo == 'Masculino') ? 50 : 49;
    p95 = (sexo == 'Masculino') ? 52 : 51;
  } else if (idade < 2) {
    // Lactentes
    if (idade < 1) {
      // Até 1 ano
      p5 = (sexo == 'Masculino') ? 68 : 66;
      p50 = (sexo == 'Masculino') ? 75 : 73;
      p95 = (sexo == 'Masculino') ? 82 : 80;
    } else {
      // 1-2 anos
      p5 = (sexo == 'Masculino') ? 77 : 75;
      p50 = (sexo == 'Masculino') ? 85 : 83;
      p95 = (sexo == 'Masculino') ? 92 : 90;
    }
  } else if (idade >= 2 && idade <= 10) {
    // Crianças 2-10 anos
    p50 = (sexo == 'Masculino')
        ? 85 + ((idade - 2) * 6)
        : 83 + ((idade - 2) * 5.5);
    p5 = p50 - 5;
    p95 = p50 + 5;
  } else if (idade > 10 && idade <= 18) {
    // Adolescentes
    if (idade <= 13) {
      p50 = (sexo == 'Masculino')
          ? 135 + ((idade - 10) * 7)
          : 137 + ((idade - 10) * 6);
    } else {
      p50 = (sexo == 'Masculino')
          ? 156 + ((idade - 13) * 3)
          : 155 + ((idade - 13) * 2);
    }
    p5 = p50 - 7;
    p95 = p50 + 7;
  } else {
    // Adultos
    p50 = (sexo == 'Masculino') ? 175 : 162;
    p5 = (sexo == 'Masculino') ? 168 : 155;
    p95 = (sexo == 'Masculino') ? 182 : 169;

    // Ajuste para idosos (>60 anos)
    if (idade > 60) {
      double perda = (idade - 60) * 0.2; // 0.2 cm de perda por ano
      p5 -= perda;
      p50 -= perda;
      p95 -= perda;
    }
  }

  return {
    'P5': '${p5.toStringAsFixed(1)} cm',
    'P50': '${p50.toStringAsFixed(1)} cm',
    'P95': '${p95.toStringAsFixed(1)} cm',
  };
} //Altura Esperada
double calcularPercentualPesoIdeal(double pesoAtual, double altura, double idade, String sexo) {
  double pesoIdeal = calcularPesoIdeal(altura, idade, sexo);
  if (pesoIdeal == 0) return 0;
  return (pesoAtual / pesoIdeal) * 100;
} //  % Peso Ideal

double calcularPesoParaAltura(double pesoAtual, double altura, double idade, String sexo) {
  // Peso mediano esperado para a altura (independente da idade)
  // Usando aproximação baseada em curvas de crescimento OMS
  double pesoMedianoParaAltura;
  
  if (altura < 50) {
    // Recém-nascido muito pequeno
    pesoMedianoParaAltura = 3.0;
  } else if (altura < 75) {
    // Lactente (50-75 cm)
    pesoMedianoParaAltura = 3.0 + ((altura - 50) * 0.28);
  } else if (altura < 100) {
    // Criança pequena (75-100 cm)
    pesoMedianoParaAltura = 10.0 + ((altura - 75) * 0.32);
  } else if (altura < 120) {
    // Criança (100-120 cm)
    pesoMedianoParaAltura = 18.0 + ((altura - 100) * 0.5);
  } else if (altura < 150) {
    // Criança maior/pré-adolescente (120-150 cm)
    pesoMedianoParaAltura = 28.0 + ((altura - 120) * 0.8);
  } else {
    // Adolescente/Adulto (>150 cm)
    // Usa IMC de referência de 22 kg/m²
    double alturaMetros = altura / 100;
    pesoMedianoParaAltura = 22.0 * (alturaMetros * alturaMetros);
  }
  
  if (pesoMedianoParaAltura == 0) return 0;
  return (pesoAtual / pesoMedianoParaAltura) * 100;
} //  % Peso para Altura

// PARAMETROS HEMODINÂMICOS
Map<String, String> calcularFrequenciaCardiacaEsperada(double idade, double peso, double altura, String sexo) {
  double fcBase; // P50 base

  // Baseado na idade
  if (idade < (1 / 30)) {
    fcBase = 140;
  } else if (idade < 1) {
    fcBase = 130;
  } else if (idade < 2) {
    fcBase = 120;
  } else if (idade >= 2 && idade <= 6) {
    fcBase = 110;
  } else if (idade > 6 && idade <= 12) {
    fcBase = 95;
  } else if (idade > 12 && idade <= 18) {
    fcBase = 80;
  } else if (idade > 18 && idade <= 60) {
    fcBase = 75;
  } else {
    fcBase = 70;
  }

  // Ajuste por sexo
  if (sexo == 'Feminino' && idade > 1) {
    fcBase += 2;
  }

  // Ajuste por IMC (apenas para adultos)
  if (idade >= 18) {
    double imc = peso / pow((altura / 100), 2); // Altura em metros
    if (imc < 18.5) {
      fcBase -= 3; // magro/atlético -> FC menor em repouso
    } else if (imc > 30) {
      fcBase += 5; // obeso -> FC maior (sobrecarga cardíaca)
    }
  }

  // Cálculo dos percentis
  double p5 = fcBase * 0.85;
  double p50 = fcBase;
  double p95 = fcBase * 1.15;

  return {
    'P5': '${p5.round()} bpm',
    'P50': '${p50.round()} bpm',
    'P95': '${p95.round()} bpm',
  };
}  // Frequencia cardiaca
  // Frequencia cardiaca
Map<String, Map<String, String>> calcularPressaoArterialEsperada(double idade, String sexo, double peso, double altura) {
  double pasP5 = 0, pasP50 = 0, pasP95 = 0;
  double padP5 = 0, padP50 = 0, padP95 = 0;

  if (idade < (1 / 30)) {
    // Recém-nascido
    pasP5 = 50; pasP50 = 65; pasP95 = 80;
    padP5 = 30; padP50 = 40; padP95 = 50;
  } else if (idade < 1) {
    // Lactente
    pasP5 = 70; pasP50 = 80; pasP95 = 90;
    padP5 = 40; padP50 = 50; padP95 = 60;
  } else if (idade >= 1 && idade < 10) {
    // Crianças - Fórmula clássica: PAS normal = 90 + (idade × 2)
    pasP5 = 80 + (idade * 2);   // Limite inferior normal
    pasP50 = 90 + (idade * 2);  // Valor médio esperado
    pasP95 = 105 + (idade * 2); // Limite superior (pré-hipertensão)
    padP5 = 50 + idade;         // Diastólica limite inferior
    padP50 = 55 + idade;        // Diastólica média
    padP95 = 65 + idade;        // Diastólica limite superior
  } else if (idade >= 10 && idade <= 18) {
    // Adolescentes
    if (sexo == 'Masculino') {
      pasP5 = 90 + (idade - 10) * 1.5;
      pasP50 = 100 + (idade - 10) * 1.5;
      pasP95 = 110 + (idade - 10) * 1.5;
      padP5 = 60 + (idade - 10) * 1.2;
      padP50 = 65 + (idade - 10) * 1.2;
      padP95 = 70 + (idade - 10) * 1.2;
    } else {
      pasP5 = 88 + (idade - 10) * 1.2;
      pasP50 = 98 + (idade - 10) * 1.2;
      pasP95 = 108 + (idade - 10) * 1.2;
      padP5 = 58 + (idade - 10) * 1.0;
      padP50 = 63 + (idade - 10) * 1.0;
      padP95 = 68 + (idade - 10) * 1.0;
    }
  } else {
    // Adultos
    pasP5 = (idade <= 40) ? 105 : (idade <= 60) ? 110 : 115;
    pasP50 = (idade <= 40) ? 120 : (idade <= 60) ? 125 : 130;
    pasP95 = (idade <= 40) ? 135 : (idade <= 60) ? 140 : 145;

    padP5 = 65;
    padP50 = 75;
    padP95 = 85;
  }

  // Ajuste pequeno por peso e altura
  double pesoIdeal = (altura - 100) * 0.9;
  if (peso < pesoIdeal * 0.9) {
    pasP5 -= 2; pasP50 -= 2; pasP95 -= 2;
    padP5 -= 2; padP50 -= 2; padP95 -= 2;
  } else if (peso > pesoIdeal * 1.1) {
    pasP5 += 2; pasP50 += 2; pasP95 += 2;
    padP5 += 2; padP50 += 2; padP95 += 2;
  }

  // Cálculo das Pressões Médias
  double pamP5 = (pasP5 + 2 * padP5) / 3;
  double pamP50 = (pasP50 + 2 * padP50) / 3;
  double pamP95 = (pasP95 + 2 * padP95) / 3;

  return {
    'P5': {
      'Sistólica': '${pasP5.toStringAsFixed(0)} mmHg',
      'Diastólica': '${padP5.toStringAsFixed(0)} mmHg',
      'Média': '${pamP5.toStringAsFixed(0)} mmHg',
    },
    'P50': {
      'Sistólica': '${pasP50.toStringAsFixed(0)} mmHg',
      'Diastólica': '${padP50.toStringAsFixed(0)} mmHg',
      'Média': '${pamP50.toStringAsFixed(0)} mmHg',
    },
    'P95': {
      'Sistólica': '${pasP95.toStringAsFixed(0)} mmHg',
      'Diastólica': '${padP95.toStringAsFixed(0)} mmHg',
      'Média': '${pamP95.toStringAsFixed(0)} mmHg',
    },
  };
} //  Pressão Arterial
String calcularVolumePlasmatico(double idade, double peso, String sexo) {
  double volumeSanguineoTotal;
  double fatorPlasma = 0.55; // Plasma é ~55% do sangue total

  if (idade < (1 / 12)) {
    // Recém-nascido (< 1 mês): 80-90 mL/kg
    volumeSanguineoTotal = 85 * peso;
    fatorPlasma = 0.50; // RN tem mais hemácias proporcionalmente
  } else if (idade < 1) {
    // Lactente (1 mês - 1 ano): 75-80 mL/kg
    volumeSanguineoTotal = 78 * peso;
  } else if (idade < 12) {
    // Criança (1-12 anos): 70-75 mL/kg
    volumeSanguineoTotal = 72 * peso;
  } else if (idade < 18) {
    // Adolescente: 65-70 mL/kg
    volumeSanguineoTotal = (sexo == 'Feminino') ? 65 * peso : 70 * peso;
  } else {
    // Adulto: 60-70 mL/kg dependendo do sexo
    if (sexo == 'Feminino') {
      volumeSanguineoTotal = 65 * peso;
    } else {
      volumeSanguineoTotal = 70 * peso;
    }
  }

  // Calcular o volume plasmático
  double volumePlasmatico = volumeSanguineoTotal * fatorPlasma;

  return volumePlasmatico.toStringAsFixed(0); // Retorna só o número em mL
} // Volume Plasmático
double calcularVolumeDiarioInfusao(double peso, double idade) {
  if (peso <= 0) return 0;

  if (peso <= 10) {
    return peso * 100; // 100 mL/kg
  } else if (peso <= 20) {
    return 1000 + ((peso - 10) * 50); // 1000 mL + 50 mL/kg acima de 10 kg
  } else if (peso <= 70) {
    return 1500 + ((peso - 20) * 20); // 1500 mL + 20 mL/kg acima de 20 kg
  } else {
    // Em adultos maiores que 70kg, muitas diretrizes limitam em cerca de 2500 mL a 3000 mL
    return 2500;
  }
}  //Infusão por dia
double calcularVelocidadeInfusaoHora(double peso, double idade) {
  double volumeDiario = calcularVolumeDiarioInfusao(peso, idade);
  return volumeDiario / 24; // Dividido igualmente pelas 24 horas do dia
} // infusãopor hora
Map<String, String> calcularIntervaloReperfusaoCapilar(double peso, double altura, double idade, String sexo) {
  double tempoBase = 2.0;

  if (idade < 1) {
    tempoBase = 1.0;
  } else if (idade >= 1 && idade <= 5) {
    tempoBase = 1.5;
  } else if (idade > 5 && idade <= 12) {
    tempoBase = 2.0;
  } else if (idade > 60) {
    tempoBase = 2.5;
  }

  // Ajuste baseado no IMC
  double imc = peso / pow((altura / 100), 2);

  if (imc < 18.5) {
    tempoBase -= 0.3;
  } else if (imc > 30) {
    tempoBase += 0.3;
  }

  if (tempoBase < 1.0) tempoBase = 1.0;
  if (tempoBase > 3.0) tempoBase = 3.0;

  double p5 = tempoBase - 0.2;
  double p95 = tempoBase + 0.2;

  if (p5 < 0.8) p5 = 0.8;
  if (p95 > 3.2) p95 = 3.2;

  return {
    'P5': p5.toStringAsFixed(1),
    'P50': tempoBase.toStringAsFixed(1),
    'P95': p95.toStringAsFixed(1),
  };
} // Intervalo de perfusão capilar (1)

// PARAMETROS Ventilatório
String calcularMascaraFacial(double peso, double idade) {
  if (peso <= 5) {
    return '0';
  } else if (peso <= 10) {
    return '1';
  } else if (peso <= 20) {
    return '2';
  } else if (peso <= 30) {
    return '3';
  } else if (peso <= 70) {
    return '4';
  } else {
    return '5';
  }
}   // Mascara Facial
String calcularCanulaOroFaringea(double peso, double idade) {
  if (peso <= 5) {
    return '3 cm';
  } else if (peso <= 10) {
    return '4 cm';
  } else if (peso <= 20) {
    return '5 cm';
  } else if (peso <= 40) {
    return '7 cm';
  } else {
    return '9-10 cm';
  }
} // Canula Oro-Faringea
String calcularCanulaNasoFaringea(double peso, double idade) {
  if (peso <= 5) {
    return '3.0 - 3.5 mm';
  } else if (peso <= 10) {
    return '4.0 mm';
  } else if (peso <= 20) {
    return '4.5 - 5.0 mm';
  } else if (peso <= 40) {
    return '5.5 - 6.0 mm';
  } else {
    return '6.5 - 8.0 mm';
  }
} // Canula Naso-Faringea
String calcularCombitubo(double peso, double altura) {
  if (peso < 5) {
    return 'Transparente (0)';
  } else if (peso >= 5 && peso <= 10) {
    return 'Branco (0,5)';
  } else if (peso > 10 && peso <= 12) {
    return 'Amarelo (1)';
  } else if (peso > 12 && peso <= 25) {
    return 'Verde (2)';
  } else if (altura >= 125 && altura < 150) {
    return 'Laranja (2.5)';
  } else if (altura >= 150 && altura < 155) {
    return 'Amarelo (3)';
  } else if (altura >= 155 && altura <= 180) {
    return 'Vermelho (4)';
  } else {
    return 'Roxo (5)';
  }
} // Combitubo
String calcularMascaraLaringea(double peso) {
  if (peso < 5) {
    return '1'; // Tamanho 1 para neonatos (2-5 kg) - tamanho 0 não existe comercialmente
  } else if (peso <= 10) {
    return '1.5';
  } else if (peso <= 20) {
    return '2';
  } else if (peso <= 30) {
    return '2.5';
  } else if (peso <= 50) {
    return '3';
  } else if (peso <= 70) {
    return '4';
  } else if (peso <= 100) {
    return '5';
  } else {
    return '6';
  }
} // Mascara Laringea
String calcularLaminaRetaMiller(double idade) {
  if (idade < (1 / 12)) {
    return '0';
  } else if (idade < 1) {
    return '1';
  } else if (idade < 2) {
    return '1';
  } else if (idade <= 5) {
    return '1-2';
  } else if (idade <= 10) {
    return '2';
  } else {
    return '2-3';
  }
} // Lamina Reta Miller
String calcularLaminaCurvaMacintosh(double idade) {
  if (idade < 2) {
    return '1';
  } else if (idade <= 5) {
    return '2';
  } else if (idade <= 10) {
    return '2-3';
  } else {
    return '3-4';
  }
} // Lamina Curva Macintosh
String calcularTuboOrotraquealComCuff(double idade, double peso, double altura, String sexo) {
  double tamanhoEstimado;

  if (idade < (1 / 12)) { // Recém-nascido
    // Em neonatos, o peso é bom indicador do tamanho da traqueia
    if (peso < 1.5) {
      tamanhoEstimado = 2.5;
    } else if (peso < 2.5) {
      tamanhoEstimado = 3.0;
    } else if (peso < 3.5) {
      tamanhoEstimado = 3.5;
    } else {
      tamanhoEstimado = 3.5;
    }
  } else {
    // Aplica fórmula (idade/4) + 3.5 até atingir tamanho 7
    double tamanhoCalculado = (idade / 4) + 3.5;
    
    if (tamanhoCalculado < 7.0) {
      // Usa a fórmula para crianças até o tubo atingir 7
      tamanhoEstimado = tamanhoCalculado;
    } else {
      // Adultos (quando fórmula já daria >= 7)
      // IMPORTANTE: Tamanho da traqueia NÃO aumenta com obesidade
      // Usar apenas ALTURA como critério (traqueia correlaciona com altura)
      if (sexo == 'Feminino') {
        if (altura >= 165) {
          tamanhoEstimado = 7.5;
        } else {
          tamanhoEstimado = 7.0;
        }
      } else {
        if (altura >= 180) {
          tamanhoEstimado = 8.0;
        } else {
          tamanhoEstimado = 7.5;
        }
      }
    }
  }

  // Tubos disponíveis com cuff
  List<double> tubosDisponiveis = [2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0];

  // Buscar os dois tamanhos mais próximos
  double tuboMenor = tubosDisponiveis.first;
  double tuboMaior = tubosDisponiveis.last;

  for (int i = 0; i < tubosDisponiveis.length - 1; i++) {
    if (tamanhoEstimado >= tubosDisponiveis[i] && tamanhoEstimado <= tubosDisponiveis[i + 1]) {
      tuboMenor = tubosDisponiveis[i];
      tuboMaior = tubosDisponiveis[i + 1];
      break;
    }
  }

  // Resultado final formatado
  if (tamanhoEstimado == tuboMenor) {
    return '${tuboMenor.toStringAsFixed(1)} mm';
  } else {
    return '${tuboMenor.toStringAsFixed(1)} ou ${tuboMaior.toStringAsFixed(1)} mm';
  }
}String calcularTuboOrotraquealSemCuff(double idade, double peso, double altura, String sexo) {
  // Primeiro calcula o tubo COM cuff
  String tuboComCuffTexto = calcularTuboOrotraquealComCuff(idade, peso, altura, sexo);

  // Extrair os valores possíveis do texto
  List<String> partes = tuboComCuffTexto.split(' ou ');
  List<double> tamanhosComCuff = partes.map((p) => double.tryParse(p.split(' ').first) ?? 0.0).toList();

  // Agora, para cada valor encontrado, somar 0.5 mm
  List<String> tamanhosSemCuff = tamanhosComCuff.map((valor) => (valor + 0.5).toStringAsFixed(1)).toList();

  // Retornar o formato final
  if (tamanhosSemCuff.length == 1) {
    return '${tamanhosSemCuff[0]} mm';
  } else {
    return '${tamanhosSemCuff[0]} ou ${tamanhosSemCuff[1]} mm';
  }
}   // Tubo Oro Traqueal sem Cuff
String calcularAlturaFixacao(double idade, double peso, double altura, String sexo) {
  // Calcula o tubo COM cuff
  String tuboComCuffTexto = calcularTuboOrotraquealComCuff(idade, peso, altura, sexo);


  // Extrai o valor numérico (ex: "6.5 mm")
  double tuboComCuff = double.tryParse(tuboComCuffTexto.split(' ').first) ?? 0.0;

  // Multiplica o diâmetro por 3 para obter a altura de fixação
  double alturaFixacao = tuboComCuff * 3;

  // Agora retorna somente o número sem unidade
  return alturaFixacao.toStringAsFixed(0); // apenas número, sem "cm"
}  // Altura de Fixação
String calcularCanulaTraqueostomia(double idade, double peso, double altura, String sexo) {
  double tamanhoEstimado;

  if (idade < (1 / 12)) { // Recém-nascido até 1 mês
    tamanhoEstimado = 3.0;
  } else if (idade < 1) { // Lactentes
    tamanhoEstimado = 3.5;
  } else if (idade <= 2) { // Crianças 1-2 anos
    tamanhoEstimado = 3.5 + ((idade - 1) * 0.5);
  } else if (idade <= 12) { // Crianças 2-12 anos: fórmula (idade/4) + 3.5
    tamanhoEstimado = (idade / 4) + 3.5;
  } else {
    // Adolescentes e Adultos (> 12 anos)
    if (sexo == 'Feminino') {
      if (peso > 100 || altura > 180) {
        tamanhoEstimado = 7.5;
      } else {
        tamanhoEstimado = 7.0;
      }
    } else {
      if (peso > 100 || altura > 190) {
        tamanhoEstimado = 8.0;
      } else {
        tamanhoEstimado = 7.5;
      }
    }
  }

  // Lista de cânulas padrão disponíveis
  List<double> canulasDisponiveis = [3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0];

  // Encontrar os dois tamanhos mais prováveis
  double canulaMenor = canulasDisponiveis.first;
  double canulaMaior = canulasDisponiveis.last;

  for (int i = 0; i < canulasDisponiveis.length - 1; i++) {
    if (tamanhoEstimado >= canulasDisponiveis[i] && tamanhoEstimado <= canulasDisponiveis[i + 1]) {
      canulaMenor = canulasDisponiveis[i];
      canulaMaior = canulasDisponiveis[i + 1];
      break;
    }
  }

  // Se bater exatamente
  if (tamanhoEstimado == canulaMenor) {
    return '${canulaMenor.toStringAsFixed(1)} mm';
  }

  // Senão, sugerir duas opções
  return '${canulaMenor.toStringAsFixed(1)} ou ${canulaMaior.toStringAsFixed(1)} mm';
} // Canula Traqueostomia


// Cálculo do diâmetro do Cateter de Aspiração Brônquica
// Baseado no tamanho do tubo orotraqueal utilizado
String calcularBroncoCat(double tuboOrotraqueal) {
  if (tuboOrotraqueal <= 0) return '-';
  double diametroInterno = tuboOrotraqueal > 4
      ? tuboOrotraqueal - 0.5
      : tuboOrotraqueal;
  double cateterIdealFr = diametroInterno * 3 * 0.5;

  // Arredondar para tamanho padrão comercial
  if (cateterIdealFr < 6) return '6 Fr';
  if (cateterIdealFr < 8) return '8 Fr';
  if (cateterIdealFr < 10) return '10 Fr';
  if (cateterIdealFr < 12) return '12 Fr';
  if (cateterIdealFr < 14) return '14 Fr';
  if (cateterIdealFr < 16) return '16 Fr';
  return '18 Fr';
}

// Cálculo do tamanho do tubo Robertshaw (BroncoCat)
String calcularTuboRobertshaw(double altura, String sexo, double idade) {
  if (idade < 12) {
    return 'Não recomendado';
  }
  if (sexo == 'Feminino') {
    return altura < 160 ? '35 Fr' : '37 Fr';
  } else {
    return altura < 170 ? '39 Fr' : '41 Fr';
  }
}


// Estimativa de fixação do tubo Robertshaw (em cm)
String calcularFixacaoRobertshaw(double altura, double idade) {
  if (altura <= 0 || idade < 12) return 'Não aplicável';

  double fixacao = (altura * 0.1) + 12;
  if (fixacao < 24) fixacao = 24;
  if (fixacao > 32) fixacao = 32;

  return '${fixacao.toStringAsFixed(0)} cm';
}

// Exibição recomendada no app
Widget buildResultadoRobertshaw(double altura, String sexo, double idade) {
  final calibre = calcularTuboRobertshaw(altura, sexo, idade);
  final fixacao = calcularFixacaoRobertshaw(altura, idade);

    return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tubo Robertshaw (BroncoCat)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calibre sugerido:', style: TextStyle(fontSize: 16)),
              Text(
                calibre,
                style: TextStyle(
                  fontSize: 16,
                  color: calibre.contains('Não recomendado') ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fixação estimada:', style: TextStyle(fontSize: 16)),
              Text(
                fixacao,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


// PARAMETROS Respiratórios
String calcularFrequenciaRespiratoria(double idade) {
  int min = 12;
  int max = 20;

  if (idade < (1 / 12)) { // Recém-nascido (< 1 mês)
    min = 30;
    max = 60;
  } else if (idade < 1) { // Lactente (1-12 meses)
    min = 25;
    max = 40;
  } else if (idade < 3) { // 1-3 anos
    min = 20;
    max = 30;
  } else if (idade < 6) { // 3-6 anos
    min = 18;
    max = 25;
  } else if (idade < 12) { // 6-12 anos
    min = 15;
    max = 20;
  } else if (idade < 18) { // Adolescente
    min = 12;
    max = 18;
  } else { // Adulto
    min = 12;
    max = 20;
  }

  return '$min - $max';
} // Frequência Respiratória
String calcularVolumeCorrente(double peso, double idade) {
  double volumeMin;
  double volumeMax;

  if (idade < (1 / 12)) { // Recém-nascido
    volumeMin = peso * 4;
    volumeMax = peso * 6;
  } else if (idade < 5) { // Lactente e criança pequena
    volumeMin = peso * 6;
    volumeMax = peso * 8;
  } else { // Criança maior e Adultos
    volumeMin = peso * 6;
    volumeMax = peso * 8;
  }

  return '${volumeMin.toStringAsFixed(0)} - ${volumeMax.toStringAsFixed(0)}';
} // Volume Corrente
String calcularPEEP(double idade) {
  double peepMin = 5.0;
  double peepMax = 5.0;

  if (idade < (1 / 12)) { // Recém-nascido
    peepMin = 4.0;
    peepMax = 6.0;
  } else if (idade < 1) { // Lactente
    peepMin = 4.0;
    peepMax = 6.0;
  } else if (idade <= 12) { // Crianças
    peepMin = 5.0;
    peepMax = 6.0;
  } else {
    // Adolescentes e Adultos
    peepMin = 5.0;
    peepMax = 5.0;
  }

  if (peepMin == peepMax) {
    return '${peepMin.toStringAsFixed(0)}';
  } else {
    return '${peepMin.toStringAsFixed(0)} - ${peepMax.toStringAsFixed(0)}';
  }
} // PEEP
String calcularVolumeMinuto(double idade, double peso) {
  double volumeCorrentePorKg;

  if (idade < (1 / 12)) { // Recém-nascido
    volumeCorrentePorKg = 5.0; // Média de 4-6 mL/kg (consistente com VC)
  } else if (idade < 1) { // Lactente
    volumeCorrentePorKg = 7.0; // Média de 6-8 mL/kg
  } else if (idade < 12) { // Criança
    volumeCorrentePorKg = 7.0;
  } else {
    volumeCorrentePorKg = 7.0; // Adolescente e Adulto (6-8 mL/kg, média 7)
  }

  // Calcula Volume Corrente (mL)
  double volumeCorrente = volumeCorrentePorKg * peso; // mL

  // Calcula Frequência Respiratória
  String frequenciaTexto = calcularFrequenciaRespiratoria(idade); // Ex: "30 - 60"
  int frequenciaMin = int.tryParse(frequenciaTexto.split(' - ')[0]) ?? 12;
  int frequenciaMax = int.tryParse(frequenciaTexto.split(' - ')[1]) ?? 20;

  // Calcula Volume Minuto Mínimo e Máximo
  double volumeMinutoMin = (volumeCorrente * frequenciaMin) / 1000; // resultado em Litros
  double volumeMinutoMax = (volumeCorrente * frequenciaMax) / 1000; // resultado em Litros

  return '${volumeMinutoMin.toStringAsFixed(1)} - ${volumeMinutoMax.toStringAsFixed(1)}';
} // Volume Minuto
String calcularRelacaoIE(double idade) {
  if (idade < (1 / 12)) { // Recém-nascido (até 1 mês)
    return '1:1 - 1:1.5';
  } else if (idade < 1) { // Lactente
    return '1:1.5 - 1:2';
  } else if (idade < 6) { // Criança pequena
    return '1:2';
  } else if (idade < 12) { // Criança maior
    return '1:2';
  } else if (idade < 18) { // Adolescente
    return '1:2';
  } else { // Adulto
    return '1:2'; // Padrão inicial VM; usar 1:3 ou maior apenas em DPOC
  }
} // Relação I/E
String calcularEspacoMorto(double idade, double peso) {
  // Espaço morto anatômico é aproximadamente 2.2 mL/kg ou 1/3 do VC
  // Em ventilação mecânica, adiciona-se o espaço morto do circuito
  double fatorEspacoMorto;

  if (idade < (1 / 12)) { // Recém-nascido (até 1 mês)
    fatorEspacoMorto = 2.2; // ~2.2 mL/kg anatômico
  } else if (idade < 1) { // Lactente
    fatorEspacoMorto = 2.2;
  } else if (idade < 8) { // Criança pequena
    fatorEspacoMorto = 2.2;
  } else {
    // Crianças maiores, adolescentes e adultos
    fatorEspacoMorto = 2.2;
  }

  double espacoMorto = fatorEspacoMorto * peso;

  // Espaço morto mínimo em adultos ~150 mL
  if (idade >= 18 && espacoMorto < 150) {
    espacoMorto = 150;
  }

  return espacoMorto.toStringAsFixed(0); // Retorna o valor arredondado (mL)
} // Espaço Morto
String calcularPressaoDePico(double idade) {
  int pipMin = 20;
  int pipMax = 25;

  if (idade < (1 / 12)) { // Recém-nascido
    pipMin = 15;
    pipMax = 20;
  } else if (idade < 1) { // Lactente
    pipMin = 18;
    pipMax = 22;
  } else if (idade <= 5) { // Criança pequena
    pipMin = 20;
    pipMax = 25;
  } else if (idade <= 18) { // Adolescente
    pipMin = 20;
    pipMax = 25;
  } else {
    // Adultos
    pipMin = 20;
    pipMax = 25;
  }

  if (pipMin == pipMax) {
    return '${pipMin.toString()}';
  } else {
    return '${pipMin.toString()} - ${pipMax.toString()}';
  }
} // Pressão de Pico

















//______________________________________ Regras de Exibição
 // Card Simples e Card Elabora
Widget _buildListaAntropometrica(List<Widget> resultados) {
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dados Antropométricos',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Título em negrito
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...resultados,
        ],
      ),
    ),
  );
}
Widget _buildListaParametrosCirculatorios(List<Widget> resultados) {
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parâmetros Circulatórios',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Deixa o título do card em negrito
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...resultados, // aqui entram os resultados (simples ou elaborados)
        ],
      ),
    ),
  );
}
Widget _buildResultadoVentilatorio(String subtitulo, String resultado, [String unidade = '']) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          flex: 6,
          child: Text(
            subtitulo,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            '$resultado ${unidade.isNotEmpty ? unidade : ''}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
Widget _buildListaParametrosVentilatorios(List<Widget> resultados) {
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parâmetros Ventilatórios',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Título do card em negrito
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...resultados, // aqui entram as linhas de resultados
        ],
      ),
    ),
  );
}
Widget _buildListaParametrosRespiratorios(List<Widget> resultados) {
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parâmetros Respiratórios',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...resultados, // Resultados aqui
        ],
      ),
    ),
  );
}













//_____________________________________ Informações extras

// Função de cálculo para Sonda Vesical de Demora
String calcularSondaVesical(double idade, String sexo) {
  if (idade < 1 / 30) {
    return '6 – 10 Fr';
  } else if (idade < 5) {
    return '8 – 10 Fr';
  } else if (idade < 12) {
    return '10 – 12 Fr';
  } else if (idade < 18) {
    return '12 – 14 Fr';
  } else {
    if (sexo == 'Masculino') {
      return '16 – 18 Fr';
    } else {
      return '14 – 16 Fr';
    }
  }
}

// Função de cálculo para o calibre da Sonda Nasogástrica
String calcularSondaNasogastrica(double idade, double peso) {
  if (idade < 1 / 12) { // Recém-nascido pré-termo
    return '5 – 6 Fr';
  } else if (idade < 1) { // Recém-nascido termo
    return '6 – 8 Fr';
  } else if (idade < 2) { // Lactentes
    return '8 – 10 Fr';
  } else if (idade < 6) { // Crianças pequenas
    return '10 – 12 Fr';
  } else if (idade < 12) { // Crianças maiores
    return '12 – 14 Fr';
  } else { // Adolescentes e adultos
    return (peso < 50) ? '14 Fr' : '16 – 18 Fr';
  }
}

// Função de cálculo para o calibre da Sonda Nasoentérica
String calcularSondaNasoenterica(double idade, double peso) {
  if (idade < 1 / 12) {
    return '6 Fr';
  } else if (idade < 1) {
    return '6 – 8 Fr';
  } else if (idade < 6) {
    return '8 – 10 Fr';
  } else if (idade < 12) {
    return '10 – 12 Fr';
  } else {
    return (peso < 50) ? '12 Fr' : '12 – 14 Fr';
  }
}

// Função para estimar a profundidade de inserção/fixação da SNG
// Baseado em fórmulas validadas: NEX modificado e correlação com altura
String calcularFixacaoSNG(double peso, double altura) {
  if (peso <= 0 || altura <= 0) return '-';

  double fixacao;
  
  if (altura < 50) {
    // RN prematuro
    fixacao = 15 + (altura * 0.1);
  } else if (altura < 75) {
    // Lactente pequeno (50-75 cm)
    fixacao = (altura * 0.38) + 5; // ~25-33 cm
  } else if (altura < 100) {
    // Lactente/criança pequena (75-100 cm)
    fixacao = (altura * 0.40) + 3; // ~33-43 cm
  } else if (altura < 150) {
    // Criança (100-150 cm)
    fixacao = (altura * 0.35) + 8; // ~43-60 cm
  } else {
    // Adolescente/Adulto (>150 cm) – alvo corpo gástrico ~58-65 cm
    fixacao = 50 + (altura - 150) * 0.15 + 8;
  }
  
  // Limites de segurança
  if (altura <= 45) {
    if (fixacao < 10) fixacao = 10;
  } else {
    if (fixacao < 18) fixacao = 18;
  }
  if (fixacao > 65) fixacao = 65;

  return '${fixacao.toStringAsFixed(0)} cm';
}

// Função para estimar a profundidade de inserção da sonda nasoentérica
// SNE vai além do piloro (duodeno/jejuno), portanto mais profunda que SNG
String calcularFixacaoSondaNasoenterica(double altura) {
  if (altura <= 0) return '-';
  
  double estimativa;
  
  if (altura < 75) {
    // Lactente pequeno
    estimativa = (altura * 0.55) + 10; // ~50-51 cm
  } else if (altura < 100) {
    // Lactente/criança pequena
    estimativa = (altura * 0.55) + 8; // ~49-63 cm
  } else if (altura < 150) {
    // Criança
    estimativa = (altura * 0.50) + 15; // ~65-90 cm
  } else {
    // Adolescente/Adulto
    // SNE posicionada no duodeno/jejuno: ~90-110 cm
    estimativa = (altura * 0.52) + 15; // ~93-108 cm para 150-180 cm altura
  }
  
  // Limites de segurança
  if (estimativa < 40) estimativa = 40;
  if (estimativa > 125) estimativa = 125;
  
  return '${estimativa.toStringAsFixed(0)} cm';
}

// Widget adicional para exibir dispositivos extras
Widget _buildResultadoDispositivoExtra(String subtitulo, String resultado) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          subtitulo,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          resultado,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ),
  );
}

Widget _buildListaDispositivosExtras(List<Widget> resultados) {
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cálculos Extras',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...resultados,
        ],
      ),
    ),
  );
}

String calcularAcessoCentral(double idade, double peso) {
  if (idade < 1 / 12) {
    return 'Veia umbilical ou jugular (3.5–4 Fr)';
  } else if (idade < 1) {
    return 'Veia subclávia ou jugular interna (4–5 Fr)';
  } else if (idade < 12) {
    return 'Veia subclávia ou jugular (5–6 Fr)';
  } else if (idade >= 12 && peso < 40) {
    return 'Cateter 6 Fr (jugular ou subclávia)';
  } else {
    return 'Cateter 7–9 Fr (jugular, subclávia ou femoral)';
  }
}

// Cálculo do volume diário de reposição gástrica (nutrição enteral)
// Em adultos, limita o volume máximo para evitar sobrecarga em obesos
String calcularVolumeReposicaoGastrica(double peso, double idade) {
  if (peso <= 0) return '-';

  double minMlKgDia = 100;
  double maxMlKgDia = 150;

  if (idade < 1) {
    // Lactentes: maior necessidade hídrica
    minMlKgDia = 120;
    maxMlKgDia = 150;
  } else if (idade < 10) {
    // Crianças
    minMlKgDia = 80;
    maxMlKgDia = 100;
  } else if (idade >= 10 && idade < 18) {
    // Adolescentes
    minMlKgDia = 50;
    maxMlKgDia = 80;
  } else {
    // Adultos: 25-35 mL/kg/dia para manutenção
    minMlKgDia = 25;
    maxMlKgDia = 35;
  }

  double volumeMin = peso * minMlKgDia;
  double volumeMax = peso * maxMlKgDia;

  // Em adultos, limitar volume máximo para evitar sobrecarga hídrica em obesos
  if (idade >= 18) {
    if (volumeMin > 2000) volumeMin = 2000;
    if (volumeMax > 2500) volumeMax = 2500;
  }

  return '${volumeMin.toStringAsFixed(0)} – ${volumeMax.toStringAsFixed(0)} mL/dia';
}

// Dreno de Kehr: calibre baseado apenas na idade
// O tamanho da via biliar é relacionado à idade/altura, não ao peso
String calcularDrenoKehr(double idade) {
  if (idade < 1 / 12) {
    return '5 – 8 Fr';
  } else if (idade < 1) {
    return '8 – 10 Fr';
  } else if (idade < 5) {
    return '10 – 12 Fr';
  } else if (idade < 12) {
    return '12 – 14 Fr';
  } else if (idade < 18) {
    return '14 – 16 Fr';
  } else {
    return '16 – 20 Fr';
  }
}

// Funções para tipo de acesso central
String calcularAcessoJugularInterno(double idade, double peso) {
  if (idade < 1 / 12) {
    return '3.5 – 4 Fr';
  } else if (idade < 1) {
    return '4 – 5 Fr';
  } else if (idade < 12) {
    return '5 – 6 Fr';
  } else if (peso < 40) {
    return '6 Fr';
  } else {
    return '7 – 9 Fr';
  }
}

String calcularAcessoSubclavio(double idade, double peso) {
  if (idade < 1) {
    return '4 – 5 Fr';
  } else if (idade < 12) {
    return '5 – 6 Fr';
  } else if (peso < 40) {
    return '6 Fr';
  } else {
    return '7 – 9 Fr';
  }
}


// Cálculo de creatinina sérica esperada por idade e sexo
String calcularCreatininaEsperada(double idade, String sexo) {
  double min = 0.0;
  double max = 0.0;

  if (idade < 1 / 12) { // RN (primeiro mês)
    // Creatinina reflete valores maternos nos primeiros dias
    min = 0.3;
    max = 0.8;
  } else if (idade < 1) { // Lactentes (1-12 meses)
    min = 0.2;
    max = 0.4; // Corrigido: lactentes têm creatinina baixa
  } else if (idade < 6) { // Crianças pequenas (1-6 anos)
    min = 0.2;
    max = 0.5;
  } else if (idade < 12) { // Crianças maiores (6-12 anos)
    min = 0.3;
    max = 0.7;
  } else if (idade < 18) { // Adolescentes
    min = 0.5;
    max = (sexo == 'Masculino') ? 1.0 : 0.9;
  } else { // Adultos
    min = (sexo == 'Masculino') ? 0.7 : 0.6;
    max = (sexo == 'Masculino') ? 1.3 : 1.1;
  }

  return '${min.toStringAsFixed(1)} – ${max.toStringAsFixed(1)} mg/dL';
}





class ResultadoExpandido extends StatefulWidget {
  final String subtitulo;
  final Map<String, String> valores;

  const ResultadoExpandido({
    Key? key,
    required this.subtitulo,
    required this.valores,
  }) : super(key: key);

  @override
  State<ResultadoExpandido> createState() => _ResultadoExpandidoState();
} // Resultado Expandido

class _ResultadoExpandidoState extends State<ResultadoExpandido> {
  bool expandido = false;

  @override
  Widget build(BuildContext context) {
    String p5 = widget.valores['P5'] ?? '-';
    String p50 = widget.valores['P50'] ?? '-';
    String p95 = widget.valores['P95'] ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandido = !expandido;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.subtitulo,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  '$p5  -  $p95',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (expandido) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('P5', style: TextStyle(fontSize: 14)),
                Text(p5, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('P50', style: TextStyle(fontSize: 14)),
                Text(p50, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('P95', style: TextStyle(fontSize: 14)),
                Text(p95, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ],
      ),
    );
  }
} // Resultado Expandido

//__________ Paramentros Heodinâmicos
class ResultadoExpandidoPressao extends StatefulWidget {
  final String subtitulo;
  final Map<String, Map<String, String>> valores;

  const ResultadoExpandidoPressao({
    Key? key,
    required this.subtitulo,
    required this.valores,
  }) : super(key: key);

  @override
  State<ResultadoExpandidoPressao> createState() => _ResultadoExpandidoPressaoState();
} // Resultado Expandido

class _ResultadoExpandidoPressaoState extends State<ResultadoExpandidoPressao> {
  bool expandido = false;

  @override
  Widget build(BuildContext context) {
    String sistolicaP50 = widget.valores['P50']?['Sistólica']?.replaceAll(' mmHg', '') ?? '-';
    String diastolicaP50 = widget.valores['P50']?['Diastólica']?.replaceAll(' mmHg', '') ?? '-';
    String mediaP50 = widget.valores['P50']?['Média']?.replaceAll(' mmHg', '') ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandido = !expandido;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.subtitulo,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  '$sistolicaP50 - $diastolicaP50 ($mediaP50) mmHg',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (expandido) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Expanded(flex: 2, child: SizedBox()), // espaço vazio
                Expanded(
                  flex: 2,
                  child: Center(child: Text('Sistólica', style: TextStyle(fontSize: 14))),
                ),
                Expanded(
                  flex: 2,
                  child: Center(child: Text('Diastólica', style: TextStyle(fontSize: 14))),
                ),
                Expanded(
                  flex: 2,
                  child: Center(child: Text('Média', style: TextStyle(fontSize: 14))),
                ),
              ],
            ),
            const SizedBox(height: 2),
            ...widget.valores.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key, textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(entry.value['Sistólica'] ?? '-', style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(entry.value['Diastólica'] ?? '-', style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(entry.value['Média'] ?? '-', style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
} // Resultado Expandido

//____

Map<String, String> calcularCateterShilley({
  required double altura,
  required double peso,
  required double idade, // em anos (ex: 0.5 = 6 meses)
  required String local, // 'jugular', 'subclavia', 'femoral'
}) {
  String calibre = '';
  String comprimento = '';

  if (peso < 10) {
    calibre = '3 – 5 Fr';
  } else if (peso < 20) {
    calibre = '5 – 7 Fr';
  } else if (peso < 40) {
    calibre = '7 – 9 Fr';
  } else {
    calibre = '7 – 9 Fr';
  }

  if (local == 'jugular' || local == 'subclavia') {
    if (altura <= 100) {
      double prof = (altura / 10) - 1;
      int min = prof.floor().clamp(5, 8);
      int max = (prof + 3).ceil().clamp(6, 10);
      comprimento = '$min – $max cm';
    } else if (altura <= 140) {
      double prof = (altura / 10) - 2;
      int min = prof.floor().clamp(8, 13);
      int max = (prof + 3).ceil().clamp(10, 15);
      comprimento = '$min – $max cm';
    } else if (altura <= 170) {
      comprimento = '13 – 18 cm';
    } else {
      comprimento = '15 – 20 cm';
    }
  } else if (local == 'femoral') {
    if (idade < 1) {
      comprimento = '12 – 16 cm';
    } else if (idade < 8) {
      comprimento = '16 – 24 cm';
    } else if (idade < 14) {
      comprimento = '24 – 28 cm';
    } else {
      comprimento = '28 – 30 cm';
    }
  } else {
    comprimento = '-';
  }

  return {
    'Calibre': calibre,
    'Comprimento': comprimento,
  };
}





class ResultadoExpandidoCateterShilley extends StatefulWidget {
  final String subtitulo;
  final Map<String, String> jugular;
  final Map<String, String> subclavia;
  final Map<String, String> femoral;

  const ResultadoExpandidoCateterShilley({
    Key? key,
    required this.subtitulo,
    required this.jugular,
    required this.subclavia,
    required this.femoral,
  }) : super(key: key);

  @override
  State<ResultadoExpandidoCateterShilley> createState() => _ResultadoExpandidoCateterShilleyState();
}

class _ResultadoExpandidoCateterShilleyState extends State<ResultadoExpandidoCateterShilley> {
  bool expandido = false;

  String _extrairComprimento(String comprimento) {
    return comprimento.replaceAll('cm', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    String comprimentoJugular = _extrairComprimento(widget.jugular['Comprimento'] ?? '-');
    String comprimentoSubclavia = _extrairComprimento(widget.subclavia['Comprimento'] ?? '-');
    String comprimentoFemoral = _extrairComprimento(widget.femoral['Comprimento'] ?? '-');

    // Encontrar os menores e maiores valores para o resumo
    List<String> todosComprimentos = [
      ...comprimentoJugular.split('–'),
      ...comprimentoSubclavia.split('–'),
      ...comprimentoFemoral.split('–'),
    ].map((e) => e.trim()).toList();

    List<int> numeros = todosComprimentos
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .where((e) => e > 0)
        .toList();

    int menor = (numeros.isNotEmpty) ? numeros.reduce((a, b) => a < b ? a : b) : 0;
    int maior = (numeros.isNotEmpty) ? numeros.reduce((a, b) => a > b ? a : b) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => expandido = !expandido),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(widget.subtitulo, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Icon(
                      expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  '$menor – $maior cm',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (expandido) ...[
            const SizedBox(height: 4),
            _linhaLocal('Jugular Interna', comprimentoJugular),
            const SizedBox(height: 2),
            _linhaLocal('Subclávia', comprimentoSubclavia),
            const SizedBox(height: 2),
            _linhaLocal('Femoral', comprimentoFemoral),
          ],
        ],
      ),
    );
  }

  Widget _linhaLocal(String titulo, String comprimento) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14)),
        Text('$comprimento cm', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}








//______________________________________ Calculos

// DADOS ANTROPOMETRICOS
// Peso Ideal




