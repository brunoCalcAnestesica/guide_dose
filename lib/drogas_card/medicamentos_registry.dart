import 'package:flutter/material.dart';

// ANTICOAGULANTES ANTIFIBRINOLITICOS
import 'anticoagulantes_antifibrinoliticos/enoxaparina.dart'
    show MedicamentoEnoxaparina;
import 'anticoagulantes_antifibrinoliticos/vitamina_k.dart'
    show MedicamentoVitaminaK;
import 'anticoagulantes_antifibrinoliticos/fondaparinux.dart'
    show MedicamentoFondaparinux;
import 'anticoagulantes_antifibrinoliticos/warfarina.dart'
    show MedicamentoWarfarina;
import 'anticoagulantes_antifibrinoliticos/aas.dart' show MedicamentoAAS;
import 'anticoagulantes_antifibrinoliticos/clopidogrel.dart'
    show MedicamentoClopidogrel;
import 'anticoagulantes_antifibrinoliticos/ticagrelor.dart'
    show MedicamentoTicagrelor;
import 'anticoagulantes_antifibrinoliticos/prasugrel.dart'
    show MedicamentoPrasugrel;
import 'anticoagulantes_antifibrinoliticos/tirofiban.dart'
    show MedicamentoTirofiban;
import 'anticoagulantes_antifibrinoliticos/abciximab.dart'
    show MedicamentoAbciximab;
import 'anticoagulantes_antifibrinoliticos/eptifibatide.dart'
    show MedicamentoEptifibatide;
import 'anticoagulantes_antifibrinoliticos/rivaroxabana.dart'
    show MedicamentoRivaroxabana;
import 'anticoagulantes_antifibrinoliticos/apixabana.dart'
    show MedicamentoApixabana;
import 'anticoagulantes_antifibrinoliticos/dabigatrana.dart'
    show MedicamentoDabigatrana;
import 'anticoagulantes_antifibrinoliticos/edoxabana.dart'
    show MedicamentoEdoxabana;

// ANTIARRITMICOS
import 'antiarritmicos/adenosina.dart' show MedicamentoAdenosina;
import 'antiarritmicos/amiodarona.dart' show MedicamentoAmiodarona;
// VASOPRESSORES HIPOTENSORES
import 'vasopressores_hipotensores/adrenalina.dart' show MedicamentoAdrenalina;
import 'vasopressores_hipotensores/dobutamina.dart' show MedicamentoDobutamina;
import 'vasopressores_hipotensores/dopamina.dart' show MedicamentoDopamina;
import 'vasopressores_hipotensores/efedrina.dart' show MedicamentoEfedrina;
import 'vasopressores_hipotensores/fenilefrina.dart'
    show MedicamentoFenilefrina;
import 'vasopressores_hipotensores/metaraminol.dart'
    show MedicamentoMetaraminol;
import 'vasopressores_hipotensores/milrinona.dart' show MedicamentoMilrinona;
import 'vasopressores_hipotensores/nitroprussiato.dart'
    show MedicamentoNitroprussiato;
import 'vasopressores_hipotensores/noradrenalina.dart'
    show MedicamentoNoradrenalina;
import 'vasopressores_hipotensores/vasopressina.dart'
    show MedicamentoVasopressina;
import 'vasopressores_hipotensores/levosimendan.dart'
    show MedicamentoLevosimendan;
import 'vasopressores_hipotensores/angiotensina_ii.dart'
    show MedicamentoAngiotensinaII;
import 'vasopressores_hipotensores/hidroxocobalamina.dart'
    show MedicamentoHidroxocobalamina;

// ANTI-HIPERTENSIVOS
// SOLUCOES EXPANSAO
import 'solucoes_expansao/coloides.dart' show MedicamentoColoides;
import 'solucoes_expansao/emulsao_lipidica.dart'
    show MedicamentoEmulsaoLipidica;
import 'solucoes_expansao/solucao_salina_20.dart'
    show MedicamentoSolucaoSalina20;
import 'solucoes_expansao/solucao_salina_hipertonica.dart'
    show MedicamentoSolucaoSalinaHipertonica;

// OPIOIDES ANALGESICOS
import 'opioides_analgesicos/hidromorfona.dart' show MedicamentoHidromorfona;
import 'opioides_analgesicos/meperidina.dart' show MedicamentoMeperidina;
import 'opioides_analgesicos/metadona.dart' show MedicamentoMetadona;
import 'opioides_analgesicos/morfina.dart' show MedicamentoMorfina;
import 'opioides_analgesicos/nalbuphina.dart' show MedicamentoNalbuphina;
import 'opioides_analgesicos/petidina.dart' show MedicamentoPetidina;
import 'opioides_analgesicos/remifentanil.dart' show MedicamentoRemifentanil;
import 'opioides_analgesicos/sufentanil.dart' show MedicamentoSufentanil;
import 'opioides_analgesicos/tramadol.dart' show MedicamentoTramadol;
// BLOQUADORES NEUROMUSCULARES
import 'bloquadores_neuromusculares/atracurio.dart' show MedicamentoAtracurio;
import 'bloquadores_neuromusculares/cisatracurio.dart'
    show MedicamentoCisatracurio;
import 'bloquadores_neuromusculares/mivacurio.dart' show MedicamentoMivacurio;
import 'bloquadores_neuromusculares/pancuronio.dart' show MedicamentoPancuronio;
import 'bloquadores_neuromusculares/succinilcolina.dart'
    show MedicamentoSuccinilcolina;
import 'bloquadores_neuromusculares/vecuronio.dart' show MedicamentoVecuronio;

// ANTICOLINERGICOS BRONCODILATADORES
import 'anticolinergicos_broncodilatadores/atropina.dart'
    show MedicamentoAtropina;

// ANTIEMETICOS
import 'antiemeticos/bromoprida.dart' show MedicamentoBromoprida;
import 'antiemeticos/dimenidrinato.dart' show MedicamentoDimenidrinato;
import 'antiemeticos/droperidol.dart' show MedicamentoDroperidol;
import 'antiemeticos/difenidramina.dart' show MedicamentoDifenidramina;
import 'antiemeticos/granisetrona.dart' show MedicamentoGranisetrona;
import 'antiemeticos/ondansetrona.dart' show MedicamentoOndansetrona;
import 'antiemeticos/aprepitanto.dart' show MedicamentoAprepitanto;
import 'antiemeticos/palonosetrona.dart' show MedicamentoPalonosetrona;
// Antivirais e antifúngicos
import 'antibioticos/oseltamivir.dart' show MedicamentoOseltamivir;
import 'antibioticos/fluconazol.dart' show MedicamentoFluconazol;
import 'antibioticos/anfotericina_b.dart' show MedicamentoAnfotericinab;
import 'antibioticos/voriconazol.dart' show MedicamentoVoriconazol;
import 'antibioticos/micafungina.dart' show MedicamentoMicafungina;
import 'antibioticos/caspofungina.dart' show MedicamentoCaspofungina;
import 'antibioticos/anidulafungina.dart' show MedicamentoAnidulafungina;
import 'antibioticos/ganciclovir.dart' show MedicamentoGanciclovir;

// CORTICOSTEROIDES
import 'corticosteroides/hidrocortisona.dart' show MedicamentoHidrocortisona;
import 'corticosteroides/metilprednisolona.dart'
    show MedicamentoMetilprednisolona;
import 'corticosteroides/prednisona.dart' show MedicamentoPrednisona;

// DIURETICOS
import 'diureticos/bumetadina.dart' show MedicamentoBumetadina;
import 'diureticos/furosemida.dart' show MedicamentoFurosemida;
import 'diureticos/manitol.dart' show MedicamentoManitol;
import 'diureticos/torasemida.dart' show MedicamentoTorasemida;

// ANALGESICOS ANTIPIRETICOS
import 'analgesicos_antipireticos/dipirona.dart' show MedicamentoDipirona;
import 'analgesicos_antipireticos/paracetamol.dart' show MedicamentoParacetamol;
import 'analgesicos_antipireticos/cetorolaco.dart' show MedicamentoCetorolaco;
import 'analgesicos_antipireticos/cetoprofeno.dart' show MedicamentoCetoprofeno;
import 'analgesicos_antipireticos/diclofenaco.dart' show MedicamentoDiclofenaco;
import 'analgesicos_antipireticos/desketoprofeno.dart'
    show MedicamentoDesketoprofeno;
import 'analgesicos_antipireticos/tenoxicam.dart' show MedicamentoTenoxicam;
import 'analgesicos_antipireticos/parecoxibe.dart' show MedicamentoParecoxibe;
import 'analgesicos_antipireticos/ibuprofeno.dart' show MedicamentoIbuprofeno;
import 'analgesicos_antipireticos/naproxeno.dart' show MedicamentoNaproxeno;
import 'analgesicos_antipireticos/meloxicam.dart' show MedicamentoMeloxicam;
import 'analgesicos_antipireticos/nimesulida.dart' show MedicamentoNimesulida;
import 'analgesicos_antipireticos/celecoxibe.dart' show MedicamentoCelecoxibe;
import 'analgesicos_antipireticos/etoricoxibe.dart' show MedicamentoEtoricoxibe;

// OUTROS
import 'outros/acetazolamida.dart' show MedicamentoAcetazolamida;
// INDUTORES ANESTESICOS
import 'indutores_anestesicos/cetamina.dart' show MedicamentoCetamina;
// ANTICONVULSIVANTES EMERGENCIA
// ALFA2 AGONISTAS
import 'alfa2_agonistas/clonidina.dart' show MedicamentoClonidina;
import 'alfa2_agonistas/dexmedetomidina.dart' show MedicamentoDexmedetomidina;

// BENZODIAZEPINICOS
import 'benzodiazepinicos/diazepam.dart' show MedicamentoDiazepam;
import 'benzodiazepinicos/flumazenil.dart' show MedicamentoFlumazenil;
import 'benzodiazepinicos/midazolam.dart' show MedicamentoMidazolam;

// ANESTESICOS LOCAIS
import 'anestesicos_locais/lidocaina_antiarritmica.dart'
    show MedicamentoLidocainaAntiarritmica;
// REVERSORES ANTIDOTOS
import 'reversores_antidotos/dantroleno.dart' show MedicamentoDantroleno;
import 'reversores_antidotos/naloxona.dart' show MedicamentoNaloxona;
import 'reversores_antidotos/neostigmina.dart' show MedicamentoNeostigmina;
import 'reversores_antidotos/protamina.dart' show MedicamentoProtamina;
import 'reversores_antidotos/sugamadex.dart' show MedicamentoSugamadex;
import 'reversores_antidotos/intralipid.dart' show MedicamentoIntralipid;
// CONTROLE GLICEMIA
import 'controle_glicemia/glicose_50.dart' show MedicamentoGlicose50;
import 'controle_glicemia/dextrose_25.dart' show MedicamentoDextrose25;

// ANESTESICOS INALATORIOS
import 'anestesicos_inalatorios/desflurano.dart' show MedicamentoDesflurano;
import 'anestesicos_inalatorios/enflurano.dart' show MedicamentoEnflurano;
import 'anestesicos_inalatorios/isoflurano.dart' show MedicamentoIsoflurano;
import 'anestesicos_inalatorios/oxido_nitrico.dart'
    show MedicamentoOxidoNitrico;
import 'anestesicos_inalatorios/oxido_nitroso.dart'
    show MedicamentoOxidoNitroso;
import 'anestesicos_inalatorios/sevoflurano.dart' show MedicamentoSevoflurano;
import 'anestesicos_inalatorios/halotano.dart' show MedicamentoHalotano;

// UTEROTONICOS
// ELETROLITICOS CRITICOS
import 'eletroliticos_criticos/bicarbonato_sodio.dart'
    show MedicamentoBicarbonatoSodio;
import 'eletroliticos_criticos/cloreto_calcio.dart'
    show MedicamentoCloretoCalcio;
import 'eletroliticos_criticos/gluconato_calcio.dart'
    show MedicamentoGluconatoCalcio;

// SEDATIVOS ANTIPSICOTICOS
import 'sedativos_antipsicoticos/haloperidol.dart' show MedicamentoHaloperidol;
import 'sedativos_antipsicoticos/prometazina.dart' show MedicamentoPrometazina;

/// Informações de um medicamento para navegação
class MedicamentoInfo {
  final String nome;
  final String idBulario;
  final Widget Function(BuildContext, Set<String>, void Function(String))
      builder;

  /// Builder opcional que retorna apenas o conteúdo interno (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  final Widget Function(BuildContext, Set<String>, void Function(String))?
      contentBuilder;

  const MedicamentoInfo({
    required this.nome,
    required this.idBulario,
    required this.builder,
    this.contentBuilder,
  });
}

/// Registro central de medicamentos com suas informações
/// Chaves normalizadas para facilitar busca (lowercase, sem acentos)
final Map<String, MedicamentoInfo> medicamentosRegistry = {
  // ANTICOAGULANTES ANTIFIBRINOLITICOS
  'enoxaparina': MedicamentoInfo(
    nome: MedicamentoEnoxaparina.nome,
    idBulario: MedicamentoEnoxaparina.idBulario,
    builder: MedicamentoEnoxaparina.buildCard,
    contentBuilder: MedicamentoEnoxaparina.buildConteudo,
  ),
  'vitamina k': MedicamentoInfo(
    nome: MedicamentoVitaminaK.nome,
    idBulario: MedicamentoVitaminaK.idBulario,
    builder: MedicamentoVitaminaK.buildCard,
    contentBuilder: MedicamentoVitaminaK.buildConteudo,
  ),
  'fondaparinux': MedicamentoInfo(
    nome: MedicamentoFondaparinux.nome,
    idBulario: MedicamentoFondaparinux.idBulario,
    builder: MedicamentoFondaparinux.buildCard,
    contentBuilder: MedicamentoFondaparinux.buildConteudo,
  ),
  'warfarina': MedicamentoInfo(
    nome: MedicamentoWarfarina.nome,
    idBulario: MedicamentoWarfarina.idBulario,
    builder: MedicamentoWarfarina.buildCard,
    contentBuilder: MedicamentoWarfarina.buildConteudo,
  ),
  'aas': MedicamentoInfo(
    nome: MedicamentoAAS.nome,
    idBulario: MedicamentoAAS.idBulario,
    builder: MedicamentoAAS.buildCard,
    contentBuilder: MedicamentoAAS.buildConteudo,
  ),
  'clopidogrel': MedicamentoInfo(
    nome: MedicamentoClopidogrel.nome,
    idBulario: MedicamentoClopidogrel.idBulario,
    builder: MedicamentoClopidogrel.buildCard,
    contentBuilder: MedicamentoClopidogrel.buildConteudo,
  ),
  'ticagrelor': MedicamentoInfo(
    nome: MedicamentoTicagrelor.nome,
    idBulario: MedicamentoTicagrelor.idBulario,
    builder: MedicamentoTicagrelor.buildCard,
    contentBuilder: MedicamentoTicagrelor.buildConteudo,
  ),
  'prasugrel': MedicamentoInfo(
    nome: MedicamentoPrasugrel.nome,
    idBulario: MedicamentoPrasugrel.idBulario,
    builder: MedicamentoPrasugrel.buildCard,
    contentBuilder: MedicamentoPrasugrel.buildConteudo,
  ),
  'tirofiban': MedicamentoInfo(
    nome: MedicamentoTirofiban.nome,
    idBulario: MedicamentoTirofiban.idBulario,
    builder: MedicamentoTirofiban.buildCard,
    contentBuilder: MedicamentoTirofiban.buildConteudo,
  ),
  'abciximab': MedicamentoInfo(
    nome: MedicamentoAbciximab.nome,
    idBulario: MedicamentoAbciximab.idBulario,
    builder: MedicamentoAbciximab.buildCard,
    contentBuilder: MedicamentoAbciximab.buildConteudo,
  ),
  'eptifibatide': MedicamentoInfo(
    nome: MedicamentoEptifibatide.nome,
    idBulario: MedicamentoEptifibatide.idBulario,
    builder: MedicamentoEptifibatide.buildCard,
    contentBuilder: MedicamentoEptifibatide.buildConteudo,
  ),
  'rivaroxabana': MedicamentoInfo(
    nome: MedicamentoRivaroxabana.nome,
    idBulario: MedicamentoRivaroxabana.idBulario,
    builder: MedicamentoRivaroxabana.buildCard,
    contentBuilder: MedicamentoRivaroxabana.buildConteudo,
  ),
  'apixabana': MedicamentoInfo(
    nome: MedicamentoApixabana.nome,
    idBulario: MedicamentoApixabana.idBulario,
    builder: MedicamentoApixabana.buildCard,
    contentBuilder: MedicamentoApixabana.buildConteudo,
  ),
  'dabigatrana': MedicamentoInfo(
    nome: MedicamentoDabigatrana.nome,
    idBulario: MedicamentoDabigatrana.idBulario,
    builder: MedicamentoDabigatrana.buildCard,
    contentBuilder: MedicamentoDabigatrana.buildConteudo,
  ),
  'edoxabana': MedicamentoInfo(
    nome: MedicamentoEdoxabana.nome,
    idBulario: MedicamentoEdoxabana.idBulario,
    builder: MedicamentoEdoxabana.buildCard,
    contentBuilder: MedicamentoEdoxabana.buildConteudo,
  ),
  // ANTIARRITMICOS
  'adenosina': MedicamentoInfo(
    nome: MedicamentoAdenosina.nome,
    idBulario: MedicamentoAdenosina.idBulario,
    builder: MedicamentoAdenosina.buildCard,
    contentBuilder: MedicamentoAdenosina.buildConteudo,
  ),
  'amiodarona': MedicamentoInfo(
    nome: MedicamentoAmiodarona.nome,
    idBulario: MedicamentoAmiodarona.idBulario,
    builder: MedicamentoAmiodarona.buildCard,
    contentBuilder: MedicamentoAmiodarona.buildConteudo,
  ),
  // VASOPRESSORES HIPOTENSORES
  'adrenalina': MedicamentoInfo(
    nome: MedicamentoAdrenalina.nome,
    idBulario: MedicamentoAdrenalina.idBulario,
    builder: MedicamentoAdrenalina.buildCard,
    contentBuilder: MedicamentoAdrenalina.buildConteudo,
  ),
  'epinefrina': MedicamentoInfo(
    nome: MedicamentoAdrenalina.nome,
    idBulario: MedicamentoAdrenalina.idBulario,
    builder: MedicamentoAdrenalina.buildCard,
    contentBuilder: MedicamentoAdrenalina.buildConteudo,
  ),
  'dobutamina': MedicamentoInfo(
    nome: MedicamentoDobutamina.nome,
    idBulario: MedicamentoDobutamina.idBulario,
    builder: MedicamentoDobutamina.buildCard,
    contentBuilder: MedicamentoDobutamina.buildConteudo,
  ),
  'dopamina': MedicamentoInfo(
    nome: MedicamentoDopamina.nome,
    idBulario: MedicamentoDopamina.idBulario,
    builder: MedicamentoDopamina.buildCard,
    contentBuilder: MedicamentoDopamina.buildConteudo,
  ),
  'efedrina': MedicamentoInfo(
    nome: MedicamentoEfedrina.nome,
    idBulario: MedicamentoEfedrina.idBulario,
    builder: MedicamentoEfedrina.buildCard,
    contentBuilder: MedicamentoEfedrina.buildConteudo,
  ),
  'fenilefrina': MedicamentoInfo(
    nome: MedicamentoFenilefrina.nome,
    idBulario: MedicamentoFenilefrina.idBulario,
    builder: MedicamentoFenilefrina.buildCard,
    contentBuilder: MedicamentoFenilefrina.buildConteudo,
  ),
  'metaraminol': MedicamentoInfo(
    nome: MedicamentoMetaraminol.nome,
    idBulario: MedicamentoMetaraminol.idBulario,
    builder: MedicamentoMetaraminol.buildCard,
    contentBuilder: MedicamentoMetaraminol.buildConteudo,
  ),
  'milrinona': MedicamentoInfo(
    nome: MedicamentoMilrinona.nome,
    idBulario: MedicamentoMilrinona.idBulario,
    builder: MedicamentoMilrinona.buildCard,
    contentBuilder: MedicamentoMilrinona.buildConteudo,
  ),
  'nitroprussiato': MedicamentoInfo(
    nome: MedicamentoNitroprussiato.nome,
    idBulario: MedicamentoNitroprussiato.idBulario,
    builder: MedicamentoNitroprussiato.buildCard,
    contentBuilder: MedicamentoNitroprussiato.buildConteudo,
  ),
  'noradrenalina': MedicamentoInfo(
    nome: MedicamentoNoradrenalina.nome,
    idBulario: MedicamentoNoradrenalina.idBulario,
    builder: MedicamentoNoradrenalina.buildCard,
    contentBuilder: MedicamentoNoradrenalina.buildConteudo,
  ),
  'norepinefrina': MedicamentoInfo(
    nome: MedicamentoNoradrenalina.nome,
    idBulario: MedicamentoNoradrenalina.idBulario,
    builder: MedicamentoNoradrenalina.buildCard,
    contentBuilder: MedicamentoNoradrenalina.buildConteudo,
  ),
  'vasopressina': MedicamentoInfo(
    nome: MedicamentoVasopressina.nome,
    idBulario: MedicamentoVasopressina.idBulario,
    builder: MedicamentoVasopressina.buildCard,
    contentBuilder: MedicamentoVasopressina.buildConteudo,
  ),
  'levosimendan': MedicamentoInfo(
    nome: MedicamentoLevosimendan.nome,
    idBulario: MedicamentoLevosimendan.idBulario,
    builder: MedicamentoLevosimendan.buildCard,
    contentBuilder: MedicamentoLevosimendan.buildConteudo,
  ),
  'angiotensina ii': MedicamentoInfo(
    nome: MedicamentoAngiotensinaII.nome,
    idBulario: MedicamentoAngiotensinaII.idBulario,
    builder: MedicamentoAngiotensinaII.buildCard,
    contentBuilder: MedicamentoAngiotensinaII.buildConteudo,
  ),
  'hidroxocobalamina': MedicamentoInfo(
    nome: MedicamentoHidroxocobalamina.nome,
    idBulario: MedicamentoHidroxocobalamina.idBulario,
    builder: MedicamentoHidroxocobalamina.buildCard,
    contentBuilder: MedicamentoHidroxocobalamina.buildConteudo,
  ),

  // OPIOIDES ANALGESICOS
  'hidromorfona': MedicamentoInfo(
    nome: MedicamentoHidromorfona.nome,
    idBulario: MedicamentoHidromorfona.idBulario,
    builder: MedicamentoHidromorfona.buildCard,
    contentBuilder: MedicamentoHidromorfona.buildConteudo,
  ),
  'meperidina': MedicamentoInfo(
    nome: MedicamentoMeperidina.nome,
    idBulario: MedicamentoMeperidina.idBulario,
    builder: MedicamentoMeperidina.buildCard,
    contentBuilder: MedicamentoMeperidina.buildConteudo,
  ),
  'metadona': MedicamentoInfo(
    nome: MedicamentoMetadona.nome,
    idBulario: MedicamentoMetadona.idBulario,
    builder: MedicamentoMetadona.buildCard,
    contentBuilder: MedicamentoMetadona.buildConteudo,
  ),
  'morfina': MedicamentoInfo(
    nome: MedicamentoMorfina.nome,
    idBulario: MedicamentoMorfina.idBulario,
    builder: MedicamentoMorfina.buildCard,
    contentBuilder: MedicamentoMorfina.buildConteudo,
  ),
  'nalbuphina': MedicamentoInfo(
    nome: MedicamentoNalbuphina.nome,
    idBulario: MedicamentoNalbuphina.idBulario,
    builder: MedicamentoNalbuphina.buildCard,
    contentBuilder: MedicamentoNalbuphina.buildConteudo,
  ),
  'petidina': MedicamentoInfo(
    nome: MedicamentoPetidina.nome,
    idBulario: MedicamentoPetidina.idBulario,
    builder: MedicamentoPetidina.buildCard,
    contentBuilder: MedicamentoPetidina.buildConteudo,
  ),
  'remifentanil': MedicamentoInfo(
    nome: MedicamentoRemifentanil.nome,
    idBulario: MedicamentoRemifentanil.idBulario,
    builder: MedicamentoRemifentanil.buildCard,
    contentBuilder: MedicamentoRemifentanil.buildConteudo,
  ),
  'sufentanil': MedicamentoInfo(
    nome: MedicamentoSufentanil.nome,
    idBulario: MedicamentoSufentanil.idBulario,
    builder: MedicamentoSufentanil.buildCard,
    contentBuilder: MedicamentoSufentanil.buildConteudo,
  ),
  'tramadol': MedicamentoInfo(
    nome: MedicamentoTramadol.nome,
    idBulario: MedicamentoTramadol.idBulario,
    builder: MedicamentoTramadol.buildCard,
    contentBuilder: MedicamentoTramadol.buildConteudo,
  ),

  // BLOQUADORES NEUROMUSCULARES
  'atracurio': MedicamentoInfo(
    nome: MedicamentoAtracurio.nome,
    idBulario: MedicamentoAtracurio.idBulario,
    builder: MedicamentoAtracurio.buildCard,
    contentBuilder: MedicamentoAtracurio.buildConteudo,
  ),
  'cisatracurio': MedicamentoInfo(
    nome: MedicamentoCisatracurio.nome,
    idBulario: MedicamentoCisatracurio.idBulario,
    builder: MedicamentoCisatracurio.buildCard,
    contentBuilder: MedicamentoCisatracurio.buildConteudo,
  ),
  'mivacurio': MedicamentoInfo(
    nome: MedicamentoMivacurio.nome,
    idBulario: MedicamentoMivacurio.idBulario,
    builder: MedicamentoMivacurio.buildCard,
    contentBuilder: MedicamentoMivacurio.buildConteudo,
  ),
  'pancuronio': MedicamentoInfo(
    nome: MedicamentoPancuronio.nome,
    idBulario: MedicamentoPancuronio.idBulario,
    builder: MedicamentoPancuronio.buildCard,
    contentBuilder: MedicamentoPancuronio.buildConteudo,
  ),
  'succinilcolina': MedicamentoInfo(
    nome: MedicamentoSuccinilcolina.nome,
    idBulario: MedicamentoSuccinilcolina.idBulario,
    builder: MedicamentoSuccinilcolina.buildCard,
    contentBuilder: MedicamentoSuccinilcolina.buildConteudo,
  ),
  'vecuronio': MedicamentoInfo(
    nome: MedicamentoVecuronio.nome,
    idBulario: MedicamentoVecuronio.idBulario,
    builder: MedicamentoVecuronio.buildCard,
    contentBuilder: MedicamentoVecuronio.buildConteudo,
  ),

  // ANTICOLINERGICOS BRONCODILATADORES
  'atropina': MedicamentoInfo(
    nome: MedicamentoAtropina.nome,
    idBulario: MedicamentoAtropina.idBulario,
    builder: MedicamentoAtropina.buildCard,
    contentBuilder: MedicamentoAtropina.buildConteudo,
  ),

  // ANTIEMETICOS
  'bromoprida': MedicamentoInfo(
    nome: MedicamentoBromoprida.nome,
    idBulario: MedicamentoBromoprida.idBulario,
    builder: MedicamentoBromoprida.buildCard,
    contentBuilder: MedicamentoBromoprida.buildConteudo,
  ),
  'dimenidrinato': MedicamentoInfo(
    nome: MedicamentoDimenidrinato.nome,
    idBulario: MedicamentoDimenidrinato.idBulario,
    builder: MedicamentoDimenidrinato.buildCard,
    contentBuilder: MedicamentoDimenidrinato.buildConteudo,
  ),
  'droperidol': MedicamentoInfo(
    nome: MedicamentoDroperidol.nome,
    idBulario: MedicamentoDroperidol.idBulario,
    builder: MedicamentoDroperidol.buildCard,
    contentBuilder: MedicamentoDroperidol.buildConteudo,
  ),
  'difenidramina': MedicamentoInfo(
    nome: MedicamentoDifenidramina.nome,
    idBulario: MedicamentoDifenidramina.idBulario,
    builder: MedicamentoDifenidramina.buildCard,
    contentBuilder: MedicamentoDifenidramina.buildConteudo,
  ),
  'granisetrona': MedicamentoInfo(
    nome: MedicamentoGranisetrona.nome,
    idBulario: MedicamentoGranisetrona.idBulario,
    builder: MedicamentoGranisetrona.buildCard,
    contentBuilder: MedicamentoGranisetrona.buildConteudo,
  ),
  'ondansetrona': MedicamentoInfo(
    nome: MedicamentoOndansetrona.nome,
    idBulario: MedicamentoOndansetrona.idBulario,
    builder: MedicamentoOndansetrona.buildCard,
    contentBuilder: MedicamentoOndansetrona.buildConteudo,
  ),
  'aprepitanto': MedicamentoInfo(
    nome: MedicamentoAprepitanto.nome,
    idBulario: MedicamentoAprepitanto.idBulario,
    builder: MedicamentoAprepitanto.buildCard,
    contentBuilder: MedicamentoAprepitanto.buildConteudo,
  ),
  'palonosetrona': MedicamentoInfo(
    nome: MedicamentoPalonosetrona.nome,
    idBulario: MedicamentoPalonosetrona.idBulario,
    builder: MedicamentoPalonosetrona.buildCard,
    contentBuilder: MedicamentoPalonosetrona.buildConteudo,
  ),

  // Antifúngicos/antivirais (antióticos removidos – ver aba Cálculos)
  'fluconazol': MedicamentoInfo(
    nome: MedicamentoFluconazol.nome,
    idBulario: MedicamentoFluconazol.idBulario,
    builder: MedicamentoFluconazol.buildCard,
    contentBuilder: MedicamentoFluconazol.buildConteudo,
  ),
  'anfotericina b': MedicamentoInfo(
    nome: MedicamentoAnfotericinab.nome,
    idBulario: MedicamentoAnfotericinab.idBulario,
    builder: MedicamentoAnfotericinab.buildCard,
    contentBuilder: MedicamentoAnfotericinab.buildConteudo,
  ),
  'voriconazol': MedicamentoInfo(
    nome: MedicamentoVoriconazol.nome,
    idBulario: MedicamentoVoriconazol.idBulario,
    builder: MedicamentoVoriconazol.buildCard,
    contentBuilder: MedicamentoVoriconazol.buildConteudo,
  ),
  'micafungina': MedicamentoInfo(
    nome: MedicamentoMicafungina.nome,
    idBulario: MedicamentoMicafungina.idBulario,
    builder: MedicamentoMicafungina.buildCard,
    contentBuilder: MedicamentoMicafungina.buildConteudo,
  ),
  'caspofungina': MedicamentoInfo(
    nome: MedicamentoCaspofungina.nome,
    idBulario: MedicamentoCaspofungina.idBulario,
    builder: MedicamentoCaspofungina.buildCard,
    contentBuilder: MedicamentoCaspofungina.buildConteudo,
  ),
  'anidulafungina': MedicamentoInfo(
    nome: MedicamentoAnidulafungina.nome,
    idBulario: MedicamentoAnidulafungina.idBulario,
    builder: MedicamentoAnidulafungina.buildCard,
    contentBuilder: MedicamentoAnidulafungina.buildConteudo,
  ),
  'ganciclovir': MedicamentoInfo(
    nome: MedicamentoGanciclovir.nome,
    idBulario: MedicamentoGanciclovir.idBulario,
    builder: MedicamentoGanciclovir.buildCard,
    contentBuilder: MedicamentoGanciclovir.buildConteudo,
  ),
  'oseltamivir': MedicamentoInfo(
    nome: MedicamentoOseltamivir.nome,
    idBulario: MedicamentoOseltamivir.idBulario,
    builder: MedicamentoOseltamivir.buildCard,
    contentBuilder: MedicamentoOseltamivir.buildConteudo,
  ),

  // CORTICOSTEROIDES
  'hidrocortisona': MedicamentoInfo(
    nome: MedicamentoHidrocortisona.nome,
    idBulario: MedicamentoHidrocortisona.idBulario,
    builder: MedicamentoHidrocortisona.buildCard,
    contentBuilder: MedicamentoHidrocortisona.buildConteudo,
  ),
  'metilprednisolona': MedicamentoInfo(
    nome: MedicamentoMetilprednisolona.nome,
    idBulario: MedicamentoMetilprednisolona.idBulario,
    builder: MedicamentoMetilprednisolona.buildCard,
    contentBuilder: MedicamentoMetilprednisolona.buildConteudo,
  ),
  'prednisona': MedicamentoInfo(
    nome: MedicamentoPrednisona.nome,
    idBulario: MedicamentoPrednisona.idBulario,
    builder: MedicamentoPrednisona.buildCard,
    contentBuilder: MedicamentoPrednisona.buildConteudo,
  ),

  // DIURETICOS
  'bumetadina': MedicamentoInfo(
    nome: MedicamentoBumetadina.nome,
    idBulario: MedicamentoBumetadina.idBulario,
    builder: MedicamentoBumetadina.buildCard,
    contentBuilder: MedicamentoBumetadina.buildConteudo,
  ),
  'furosemida': MedicamentoInfo(
    nome: MedicamentoFurosemida.nome,
    idBulario: MedicamentoFurosemida.idBulario,
    builder: MedicamentoFurosemida.buildCard,
    contentBuilder: MedicamentoFurosemida.buildConteudo,
  ),
  'manitol': MedicamentoInfo(
    nome: MedicamentoManitol.nome,
    idBulario: MedicamentoManitol.idBulario,
    builder: MedicamentoManitol.buildCard,
    contentBuilder: MedicamentoManitol.buildConteudo,
  ),
  'torasemida': MedicamentoInfo(
    nome: MedicamentoTorasemida.nome,
    idBulario: MedicamentoTorasemida.idBulario,
    builder: MedicamentoTorasemida.buildCard,
    contentBuilder: MedicamentoTorasemida.buildConteudo,
  ),

  // ANALGESICOS ANTIPIRETICOS
  'dipirona': MedicamentoInfo(
    nome: MedicamentoDipirona.nome,
    idBulario: MedicamentoDipirona.idBulario,
    builder: MedicamentoDipirona.buildCard,
    contentBuilder: MedicamentoDipirona.buildConteudo,
  ),
  'paracetamol': MedicamentoInfo(
    nome: MedicamentoParacetamol.nome,
    idBulario: MedicamentoParacetamol.idBulario,
    builder: MedicamentoParacetamol.buildCard,
    contentBuilder: MedicamentoParacetamol.buildConteudo,
  ),
  'cetorolaco': MedicamentoInfo(
    nome: MedicamentoCetorolaco.nome,
    idBulario: MedicamentoCetorolaco.idBulario,
    builder: MedicamentoCetorolaco.buildCard,
    contentBuilder: MedicamentoCetorolaco.buildConteudo,
  ),
  'cetoprofeno': MedicamentoInfo(
    nome: MedicamentoCetoprofeno.nome,
    idBulario: MedicamentoCetoprofeno.idBulario,
    builder: MedicamentoCetoprofeno.buildCard,
    contentBuilder: MedicamentoCetoprofeno.buildConteudo,
  ),
  'diclofenaco': MedicamentoInfo(
    nome: MedicamentoDiclofenaco.nome,
    idBulario: MedicamentoDiclofenaco.idBulario,
    builder: MedicamentoDiclofenaco.buildCard,
    contentBuilder: MedicamentoDiclofenaco.buildConteudo,
  ),
  'desketoprofeno': MedicamentoInfo(
    nome: MedicamentoDesketoprofeno.nome,
    idBulario: MedicamentoDesketoprofeno.idBulario,
    builder: MedicamentoDesketoprofeno.buildCard,
    contentBuilder: MedicamentoDesketoprofeno.buildConteudo,
  ),
  'tenoxicam': MedicamentoInfo(
    nome: MedicamentoTenoxicam.nome,
    idBulario: MedicamentoTenoxicam.idBulario,
    builder: MedicamentoTenoxicam.buildCard,
    contentBuilder: MedicamentoTenoxicam.buildConteudo,
  ),
  'parecoxibe': MedicamentoInfo(
    nome: MedicamentoParecoxibe.nome,
    idBulario: MedicamentoParecoxibe.idBulario,
    builder: MedicamentoParecoxibe.buildCard,
    contentBuilder: MedicamentoParecoxibe.buildConteudo,
  ),
  'ibuprofeno': MedicamentoInfo(
    nome: MedicamentoIbuprofeno.nome,
    idBulario: MedicamentoIbuprofeno.idBulario,
    builder: MedicamentoIbuprofeno.buildCard,
    contentBuilder: MedicamentoIbuprofeno.buildConteudo,
  ),
  'naproxeno': MedicamentoInfo(
    nome: MedicamentoNaproxeno.nome,
    idBulario: MedicamentoNaproxeno.idBulario,
    builder: MedicamentoNaproxeno.buildCard,
    contentBuilder: MedicamentoNaproxeno.buildConteudo,
  ),
  'meloxicam': MedicamentoInfo(
    nome: MedicamentoMeloxicam.nome,
    idBulario: MedicamentoMeloxicam.idBulario,
    builder: MedicamentoMeloxicam.buildCard,
    contentBuilder: MedicamentoMeloxicam.buildConteudo,
  ),
  'nimesulida': MedicamentoInfo(
    nome: MedicamentoNimesulida.nome,
    idBulario: MedicamentoNimesulida.idBulario,
    builder: MedicamentoNimesulida.buildCard,
    contentBuilder: MedicamentoNimesulida.buildConteudo,
  ),
  'celecoxibe': MedicamentoInfo(
    nome: MedicamentoCelecoxibe.nome,
    idBulario: MedicamentoCelecoxibe.idBulario,
    builder: MedicamentoCelecoxibe.buildCard,
    contentBuilder: MedicamentoCelecoxibe.buildConteudo,
  ),
  'etoricoxibe': MedicamentoInfo(
    nome: MedicamentoEtoricoxibe.nome,
    idBulario: MedicamentoEtoricoxibe.idBulario,
    builder: MedicamentoEtoricoxibe.buildCard,
    contentBuilder: MedicamentoEtoricoxibe.buildConteudo,
  ),

  // OUTROS
  'acetazolamida': MedicamentoInfo(
    nome: MedicamentoAcetazolamida.nome,
    idBulario: MedicamentoAcetazolamida.idBulario,
    builder: MedicamentoAcetazolamida.buildCard,
    contentBuilder: MedicamentoAcetazolamida.buildConteudo,
  ),

  // INDUTORES ANESTESICOS
  'cetamina': MedicamentoInfo(
    nome: MedicamentoCetamina.nome,
    idBulario: MedicamentoCetamina.idBulario,
    builder: MedicamentoCetamina.buildCard,
    contentBuilder: MedicamentoCetamina.buildConteudo,
  ),
  // ANTICONVULSIVANTES EMERGENCIA
  // ALFA2 AGONISTAS
  'clonidina': MedicamentoInfo(
    nome: MedicamentoClonidina.nome,
    idBulario: MedicamentoClonidina.idBulario,
    builder: MedicamentoClonidina.buildCard,
    contentBuilder: MedicamentoClonidina.buildConteudo,
  ),
  'dexmedetomidina': MedicamentoInfo(
    nome: MedicamentoDexmedetomidina.nome,
    idBulario: MedicamentoDexmedetomidina.idBulario,
    builder: MedicamentoDexmedetomidina.buildCard,
    contentBuilder: MedicamentoDexmedetomidina.buildConteudo,
  ),

  // BENZODIAZEPINICOS
  'diazepam': MedicamentoInfo(
    nome: MedicamentoDiazepam.nome,
    idBulario: MedicamentoDiazepam.idBulario,
    builder: MedicamentoDiazepam.buildCard,
    contentBuilder: MedicamentoDiazepam.buildConteudo,
  ),
  'flumazenil': MedicamentoInfo(
    nome: MedicamentoFlumazenil.nome,
    idBulario: MedicamentoFlumazenil.idBulario,
    builder: MedicamentoFlumazenil.buildCard,
    contentBuilder: MedicamentoFlumazenil.buildConteudo,
  ),
  'midazolam': MedicamentoInfo(
    nome: MedicamentoMidazolam.nome,
    idBulario: MedicamentoMidazolam.idBulario,
    builder: MedicamentoMidazolam.buildCard,
    contentBuilder: MedicamentoMidazolam.buildConteudo,
  ),
  // ANESTESICOS LOCAIS
  'lidocaina antiarritmica': MedicamentoInfo(
    nome: MedicamentoLidocainaAntiarritmica.nome,
    idBulario: MedicamentoLidocainaAntiarritmica.idBulario,
    builder: MedicamentoLidocainaAntiarritmica.buildCard,
    contentBuilder: MedicamentoLidocainaAntiarritmica.buildConteudo,
  ),
  // REVERSORES ANTIDOTOS
  'dantroleno': MedicamentoInfo(
    nome: MedicamentoDantroleno.nome,
    idBulario: MedicamentoDantroleno.idBulario,
    builder: MedicamentoDantroleno.buildCard,
    contentBuilder: MedicamentoDantroleno.buildConteudo,
  ),
  'naloxona': MedicamentoInfo(
    nome: MedicamentoNaloxona.nome,
    idBulario: MedicamentoNaloxona.idBulario,
    builder: MedicamentoNaloxona.buildCard,
    contentBuilder: MedicamentoNaloxona.buildConteudo,
  ),
  'neostigmina': MedicamentoInfo(
    nome: MedicamentoNeostigmina.nome,
    idBulario: MedicamentoNeostigmina.idBulario,
    builder: MedicamentoNeostigmina.buildCard,
    contentBuilder: MedicamentoNeostigmina.buildConteudo,
  ),
  'protamina': MedicamentoInfo(
    nome: MedicamentoProtamina.nome,
    idBulario: MedicamentoProtamina.idBulario,
    builder: MedicamentoProtamina.buildCard,
    contentBuilder: MedicamentoProtamina.buildConteudo,
  ),
  'sugamadex': MedicamentoInfo(
    nome: MedicamentoSugamadex.nome,
    idBulario: MedicamentoSugamadex.idBulario,
    builder: MedicamentoSugamadex.buildCard,
    contentBuilder: MedicamentoSugamadex.buildConteudo,
  ),
  'intralipid': MedicamentoInfo(
    nome: MedicamentoIntralipid.nome,
    idBulario: MedicamentoIntralipid.idBulario,
    builder: MedicamentoIntralipid.buildCard,
    contentBuilder: MedicamentoIntralipid.buildConteudo,
  ),
  'emulsao lipidica': MedicamentoInfo(
    nome: MedicamentoEmulsaoLipidica.nome,
    idBulario: MedicamentoEmulsaoLipidica.idBulario,
    builder: MedicamentoEmulsaoLipidica.buildCard,
    contentBuilder: MedicamentoEmulsaoLipidica.buildConteudo,
  ),
  // CONTROLE GLICEMIA
  'glicose 50%': MedicamentoInfo(
    nome: MedicamentoGlicose50.nome,
    idBulario: MedicamentoGlicose50.idBulario,
    builder: MedicamentoGlicose50.buildCard,
    contentBuilder: MedicamentoGlicose50.buildConteudo,
  ),
  'dextrose 25%': MedicamentoInfo(
    nome: MedicamentoDextrose25.nome,
    idBulario: MedicamentoDextrose25.idBulario,
    builder: MedicamentoDextrose25.buildCard,
    contentBuilder: MedicamentoDextrose25.buildConteudo,
  ),

  // ANESTESICOS INALATORIOS
  'desflurano': MedicamentoInfo(
    nome: MedicamentoDesflurano.nome,
    idBulario: MedicamentoDesflurano.idBulario,
    builder: MedicamentoDesflurano.buildCard,
    contentBuilder: MedicamentoDesflurano.buildConteudo,
  ),
  'enflurano': MedicamentoInfo(
    nome: MedicamentoEnflurano.nome,
    idBulario: MedicamentoEnflurano.idBulario,
    builder: MedicamentoEnflurano.buildCard,
    contentBuilder: MedicamentoEnflurano.buildConteudo,
  ),
  'isoflurano': MedicamentoInfo(
    nome: MedicamentoIsoflurano.nome,
    idBulario: MedicamentoIsoflurano.idBulario,
    builder: MedicamentoIsoflurano.buildCard,
    contentBuilder: MedicamentoIsoflurano.buildConteudo,
  ),
  'oxido nitrico': MedicamentoInfo(
    nome: MedicamentoOxidoNitrico.nome,
    idBulario: MedicamentoOxidoNitrico.idBulario,
    builder: MedicamentoOxidoNitrico.buildCard,
    contentBuilder: MedicamentoOxidoNitrico.buildConteudo,
  ),
  'oxido nitroso': MedicamentoInfo(
    nome: MedicamentoOxidoNitroso.nome,
    idBulario: MedicamentoOxidoNitroso.idBulario,
    builder: MedicamentoOxidoNitroso.buildCard,
    contentBuilder: MedicamentoOxidoNitroso.buildConteudo,
  ),
  'sevoflurano': MedicamentoInfo(
    nome: MedicamentoSevoflurano.nome,
    idBulario: MedicamentoSevoflurano.idBulario,
    builder: MedicamentoSevoflurano.buildCard,
    contentBuilder: MedicamentoSevoflurano.buildConteudo,
  ),
  'halotano': MedicamentoInfo(
    nome: MedicamentoHalotano.nome,
    idBulario: MedicamentoHalotano.idBulario,
    builder: MedicamentoHalotano.buildCard,
    contentBuilder: MedicamentoHalotano.buildConteudo,
  ),

  // UTEROTONICOS
  // ELETROLITICOS CRITICOS
  'bicarbonato de sodio': MedicamentoInfo(
    nome: MedicamentoBicarbonatoSodio.nome,
    idBulario: MedicamentoBicarbonatoSodio.idBulario,
    builder: MedicamentoBicarbonatoSodio.buildCard,
    contentBuilder: MedicamentoBicarbonatoSodio.buildConteudo,
  ),
  'cloreto de calcio': MedicamentoInfo(
    nome: MedicamentoCloretoCalcio.nome,
    idBulario: MedicamentoCloretoCalcio.idBulario,
    builder: MedicamentoCloretoCalcio.buildCard,
    contentBuilder: MedicamentoCloretoCalcio.buildConteudo,
  ),
  'gluconato de calcio': MedicamentoInfo(
    nome: MedicamentoGluconatoCalcio.nome,
    idBulario: MedicamentoGluconatoCalcio.idBulario,
    builder: MedicamentoGluconatoCalcio.buildCard,
    contentBuilder: MedicamentoGluconatoCalcio.buildConteudo,
  ),

  // SEDATIVOS ANTIPSICOTICOS
  'haloperidol': MedicamentoInfo(
    nome: MedicamentoHaloperidol.nome,
    idBulario: MedicamentoHaloperidol.idBulario,
    builder: MedicamentoHaloperidol.buildCard,
    contentBuilder: MedicamentoHaloperidol.buildConteudo,
  ),
  'prometazina': MedicamentoInfo(
    nome: MedicamentoPrometazina.nome,
    idBulario: MedicamentoPrometazina.idBulario,
    builder: MedicamentoPrometazina.buildCard,
    contentBuilder: MedicamentoPrometazina.buildConteudo,
  ),
  // SOLUCOES EXPANSAO
  'coloides': MedicamentoInfo(
    nome: MedicamentoColoides.nome,
    idBulario: MedicamentoColoides.idBulario,
    builder: MedicamentoColoides.buildCard,
    contentBuilder: MedicamentoColoides.buildConteudo,
  ),
  'solucao salina 20%': MedicamentoInfo(
    nome: MedicamentoSolucaoSalina20.nome,
    idBulario: MedicamentoSolucaoSalina20.idBulario,
    builder: MedicamentoSolucaoSalina20.buildCard,
    contentBuilder: MedicamentoSolucaoSalina20.buildConteudo,
  ),
  'solucao salina hipertonica': MedicamentoInfo(
    nome: MedicamentoSolucaoSalinaHipertonica.nome,
    idBulario: MedicamentoSolucaoSalinaHipertonica.idBulario,
    builder: MedicamentoSolucaoSalinaHipertonica.buildCard,
    contentBuilder: MedicamentoSolucaoSalinaHipertonica.buildConteudo,
  ),
  // OUTROS

  // ANTIDOTOS ESPECIAIS
  // ALIASES - Nomes alternativos comuns
  'bumetanida': MedicamentoInfo(
    nome: MedicamentoBumetadina.nome,
    idBulario: MedicamentoBumetadina.idBulario,
    builder: MedicamentoBumetadina.buildCard,
    contentBuilder: MedicamentoBumetadina.buildConteudo,
  ),
  'nalbufina': MedicamentoInfo(
    nome: MedicamentoNalbuphina.nome,
    idBulario: MedicamentoNalbuphina.idBulario,
    builder: MedicamentoNalbuphina.buildCard,
    contentBuilder: MedicamentoNalbuphina.buildConteudo,
  ),
  'acido acetilsalicilico': MedicamentoInfo(
    nome: MedicamentoAAS.nome,
    idBulario: MedicamentoAAS.idBulario,
    builder: MedicamentoAAS.buildCard,
    contentBuilder: MedicamentoAAS.buildConteudo,
  ),
  'bicarbonato': MedicamentoInfo(
    nome: MedicamentoBicarbonatoSodio.nome,
    idBulario: MedicamentoBicarbonatoSodio.idBulario,
    builder: MedicamentoBicarbonatoSodio.buildCard,
    contentBuilder: MedicamentoBicarbonatoSodio.buildConteudo,
  ),
  'anfotericina b deoxicolato': MedicamentoInfo(
    nome: MedicamentoAnfotericinab.nome,
    idBulario: MedicamentoAnfotericinab.idBulario,
    builder: MedicamentoAnfotericinab.buildCard,
    contentBuilder: MedicamentoAnfotericinab.buildConteudo,
  ),
  'anfotericina b lipossomal': MedicamentoInfo(
    nome: MedicamentoAnfotericinab.nome,
    idBulario: MedicamentoAnfotericinab.idBulario,
    builder: MedicamentoAnfotericinab.buildCard,
    contentBuilder: MedicamentoAnfotericinab.buildConteudo,
  ),
  'prednisolona': MedicamentoInfo(
    nome: MedicamentoPrednisona.nome,
    idBulario: MedicamentoPrednisona.idBulario,
    builder: MedicamentoPrednisona.buildCard,
    contentBuilder: MedicamentoPrednisona.buildConteudo,
  ),
  'glicose': MedicamentoInfo(
    nome: MedicamentoGlicose50.nome,
    idBulario: MedicamentoGlicose50.idBulario,
    builder: MedicamentoGlicose50.buildCard,
    contentBuilder: MedicamentoGlicose50.buildConteudo,
  ),
  // ALIASES - Soluções e concentrações
  'nacl': MedicamentoInfo(
    nome: MedicamentoSolucaoSalina20.nome,
    idBulario: MedicamentoSolucaoSalina20.idBulario,
    builder: MedicamentoSolucaoSalina20.buildCard,
    contentBuilder: MedicamentoSolucaoSalina20.buildConteudo,
  ),
  'prednisona/prednisolona': MedicamentoInfo(
    nome: MedicamentoPrednisona.nome,
    idBulario: MedicamentoPrednisona.idBulario,
    builder: MedicamentoPrednisona.buildCard,
    contentBuilder: MedicamentoPrednisona.buildConteudo,
  ),
};

/// Normaliza o nome do medicamento para busca (remove acentos e converte para lowercase)
String _removerAcentos(String texto) {
  const acentos = 'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ';
  const semAcentos = 'aaaaaaaceeeeiiiidnoooooouuuuyy';
  var resultado = texto.toLowerCase();
  for (var i = 0; i < acentos.length; i++) {
    resultado = resultado.replaceAll(acentos[i], semAcentos[i]);
  }
  return resultado;
}

/// Busca um medicamento pelo nome (aceita variações com/sem acentos)
MedicamentoInfo? buscarMedicamento(String nome) {
  // Limpa o nome removendo marcações entre parênteses e percentuais
  final nomeLimpo = nome
      .replaceAll(RegExp(r'\s*\([^)]+\)', caseSensitive: false),
          '') // Remove qualquer coisa entre parênteses
      .replaceAll(RegExp(r'\s*\d+[,.]?\d*%'),
          '') // Remove percentuais como "10%", "7,5%", "8.4%"
      .replaceAll(RegExp(r'(insulina\s+\w+)/\w+', caseSensitive: false),
          r'$1') // Remove alternativas apenas de insulina
      .trim();

  final chave = _removerAcentos(nomeLimpo);

  // Busca exata
  if (medicamentosRegistry.containsKey(chave)) {
    return medicamentosRegistry[chave];
  }

  // Busca parcial (primeira palavra)
  final palavras = chave.split(' ');
  final primeiraPalavra = palavras.first;
  if (medicamentosRegistry.containsKey(primeiraPalavra)) {
    return medicamentosRegistry[primeiraPalavra];
  }

  // Busca por nome composto (ex: "cloreto de calcio", "sulfato de magnesio")
  if (palavras.length >= 3 && palavras[1] == 'de') {
    final tresPalavras = '${palavras[0]} de ${palavras[2]}';
    if (medicamentosRegistry.containsKey(tresPalavras)) {
      return medicamentosRegistry[tresPalavras];
    }
  }

  // Busca por duas primeiras palavras
  if (palavras.length >= 2) {
    final duasPalavras = '${palavras[0]} ${palavras[1]}';
    if (medicamentosRegistry.containsKey(duasPalavras)) {
      return medicamentosRegistry[duasPalavras];
    }
  }

  return null;
}
