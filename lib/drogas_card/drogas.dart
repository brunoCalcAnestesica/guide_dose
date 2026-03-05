import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../shared_data.dart';
import '../bulario_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'vasopressores_hipotensores/levosimendan.dart'
    show MedicamentoLevosimendan;
import 'vasopressores_hipotensores/angiotensina_ii.dart'
    show MedicamentoAngiotensinaII;
import 'vasopressores_hipotensores/hidroxocobalamina.dart'
    show MedicamentoHidroxocobalamina;

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
import 'bloquadores_neuromusculares/vecuronio.dart' show MedicamentoVecuronio;

// ANTICOLINERGICOS BRONCODILATADORES
// ANTIEMETICOS
import 'antiemeticos/granisetrona.dart' show MedicamentoGranisetrona;
import 'antiemeticos/ondansetrona.dart' show MedicamentoOndansetrona;
import 'antiemeticos/palonosetrona.dart' show MedicamentoPalonosetrona;
// Antiviral (antifúngicos/outros antivirais removidos – já na aba Cálculos)
import 'antibioticos/oseltamivir.dart' show MedicamentoOseltamivir;

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

// OUTROS
import 'outros/acetazolamida.dart' show MedicamentoAcetazolamida;
// INDUTORES ANESTESICOS
// ANTICONVULSIVANTES EMERGENCIA
// BENZODIAZEPINICOS
// ANESTESICOS LOCAIS
// REVERSORES ANTIDOTOS
import 'reversores_antidotos/neostigmina.dart' show MedicamentoNeostigmina;
import 'reversores_antidotos/protamina.dart' show MedicamentoProtamina;
// CONTROLE GLICEMIA
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

// UTEROTONICOS
// ELETROLITICOS CRITICOS
// SEDATIVOS ANTIPSICOTICOS
import 'sedativos_antipsicoticos/prometazina.dart' show MedicamentoPrometazina;

// Lista estática de medicamentos para evitar reconstrução
final List<Map<String, dynamic>> _medicamentos = <Map<String, dynamic>>[
  // ANTICOAGULANTES ANTIFIBRINOLITICOS
  {
    'nome': MedicamentoEnoxaparina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoEnoxaparina.buildCard(context, favoritos, onToggleFavorito)
  }, // Enoxaparina

  // VASOPRESSORES HIPOTENSORES
  {
    'nome': MedicamentoAdrenalina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoAdrenalina.buildCard(context, favoritos, onToggleFavorito),
  }, // Adrenalina
  {
    'nome': MedicamentoDobutamina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDobutamina.buildCard(context, favoritos, onToggleFavorito),
  }, // Dobutamina
  {
    'nome': MedicamentoDopamina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDopamina.buildCard(context, favoritos, onToggleFavorito),
  }, // Dopamina
  {
    'nome': MedicamentoEfedrina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoEfedrina.buildCard(context, favoritos, onToggleFavorito),
  }, // Efedrina
  {
    'nome': MedicamentoFenilefrina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoFenilefrina.buildCard(context, favoritos, onToggleFavorito),
  }, // Fenilefrina
  {
    'nome': MedicamentoMetaraminol.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMetaraminol.buildCard(context, favoritos, onToggleFavorito),
  }, // Metaraminol
  {
    'nome': MedicamentoMilrinona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMilrinona.buildCard(context, favoritos, onToggleFavorito),
  }, // Milrinona
  {
    'nome': MedicamentoNitroprussiato.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoNitroprussiato.buildCard(
            context, favoritos, onToggleFavorito),
  }, // Nitroprussiato de Sódio
  {
    'nome': MedicamentoNoradrenalina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoNoradrenalina.buildCard(
            context, favoritos, onToggleFavorito),
  }, // Noradrenalina
  {
    'nome': MedicamentoLevosimendan.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoLevosimendan.buildCard(context, favoritos, onToggleFavorito)
  }, // Levosimendan
  {
    'nome': MedicamentoAngiotensinaII.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoAngiotensinaII.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Angiotensina II
  {
    'nome': MedicamentoHidroxocobalamina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoHidroxocobalamina.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Hidroxocobalamina

  // SOLUCOES EXPANSAO
  {
    'nome': MedicamentoColoides.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoColoides.buildCard(context, favoritos, onToggleFavorito)
  }, // Coloides
  {
    'nome': MedicamentoEmulsaoLipidica.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoEmulsaoLipidica.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Emulsao Lipidica
  {
    'nome': MedicamentoSolucaoSalina20.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoSolucaoSalina20.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Solucao Salina 20
  {
    'nome': MedicamentoSolucaoSalinaHipertonica.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoSolucaoSalinaHipertonica.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Solucao Salina Hipertonica

  // OPIOIDES ANALGESICOS
  {
    'nome': MedicamentoHidromorfona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoHidromorfona.buildCard(context, favoritos, onToggleFavorito)
  }, // Hidromorfona
  {
    'nome': MedicamentoMeperidina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMeperidina.buildCard(context, favoritos, onToggleFavorito)
  }, // Meperidina
  {
    'nome': MedicamentoMetadona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMetadona.buildCard(context, favoritos, onToggleFavorito)
  }, // Metadona
  {
    'nome': MedicamentoMorfina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMorfina.buildCard(context, favoritos, onToggleFavorito)
  }, // Morfina
  {
    'nome': MedicamentoNalbuphina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoNalbuphina.buildCard(context, favoritos, onToggleFavorito),
  }, // Nalbufina
  {
    'nome': MedicamentoPetidina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoPetidina.buildCard(context, favoritos, onToggleFavorito)
  }, // Petidina
  {
    'nome': MedicamentoRemifentanil.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoRemifentanil.buildCard(context, favoritos, onToggleFavorito)
  }, // Remifentanil
  {
    'nome': MedicamentoSufentanil.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoSufentanil.buildCard(context, favoritos, onToggleFavorito)
  }, // Sufentanil
  {
    'nome': MedicamentoTramadol.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoTramadol.buildCard(context, favoritos, onToggleFavorito)
  }, // Tramadol

  // BLOQUADORES NEUROMUSCULARES
  {
    'nome': MedicamentoAtracurio.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoAtracurio.buildCard(context, favoritos, onToggleFavorito)
  }, // Atracurio
  {
    'nome': MedicamentoCisatracurio.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoCisatracurio.buildCard(context, favoritos, onToggleFavorito)
  }, // Cisatracurio
  {
    'nome': MedicamentoMivacurio.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMivacurio.buildCard(context, favoritos, onToggleFavorito)
  }, // Mivacurio
  {
    'nome': MedicamentoPancuronio.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoPancuronio.buildCard(context, favoritos, onToggleFavorito)
  }, // Pancuronio
  {
    'nome': MedicamentoVecuronio.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoVecuronio.buildCard(context, favoritos, onToggleFavorito)
  }, // Vecuronio

  // ANTICOLINERGICOS BRONCODILATADORES
  // ANTIEMETICOS
  // CORTICOSTEROIDES
  {
    'nome': MedicamentoHidrocortisona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoHidrocortisona.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Hidrocortisona
  {
    'nome': MedicamentoMetilprednisolona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMetilprednisolona.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Metilprednisolona
  {
    'nome': MedicamentoPrednisona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoPrednisona.buildCard(context, favoritos, onToggleFavorito)
  }, // Prednisona

  // DIURETICOS
  {
    'nome': MedicamentoBumetadina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoBumetadina.buildCard(context, favoritos, onToggleFavorito)
  }, // Bumetadina
  {
    'nome': MedicamentoFurosemida.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoFurosemida.buildCard(context, favoritos, onToggleFavorito)
  }, // Furosemida
  {
    'nome': MedicamentoManitol.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoManitol.buildCard(context, favoritos, onToggleFavorito)
  }, // Manitol
  {
    'nome': MedicamentoTorasemida.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoTorasemida.buildCard(context, favoritos, onToggleFavorito)
  }, // Torasemida

  // ANALGESICOS ANTIPIRETICOS
  {
    'nome': MedicamentoDipirona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDipirona.buildCard(context, favoritos, onToggleFavorito)
  }, // Dipirona
  {
    'nome': MedicamentoParacetamol.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoParacetamol.buildCard(context, favoritos, onToggleFavorito)
  }, // Paracetamol
  {
    'nome': MedicamentoCetorolaco.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoCetorolaco.buildCard(context, favoritos, onToggleFavorito)
  }, // Cetorolaco
  {
    'nome': MedicamentoCetoprofeno.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoCetoprofeno.buildCard(context, favoritos, onToggleFavorito)
  }, // Cetoprofeno
  {
    'nome': MedicamentoDiclofenaco.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDiclofenaco.buildCard(context, favoritos, onToggleFavorito)
  }, // Diclofenaco
  {
    'nome': MedicamentoDesketoprofeno.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDesketoprofeno.buildCard(
            context, favoritos, onToggleFavorito)
  }, // Desketoprofeno
  {
    'nome': MedicamentoTenoxicam.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoTenoxicam.buildCard(context, favoritos, onToggleFavorito)
  }, // Tenoxicam
  {
    'nome': MedicamentoParecoxibe.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoParecoxibe.buildCard(context, favoritos, onToggleFavorito)
  }, // Parecoxibe
  {
    'nome': MedicamentoIbuprofeno.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoIbuprofeno.buildCard(context, favoritos, onToggleFavorito)
  }, // Ibuprofeno
  {
    'nome': MedicamentoNaproxeno.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoNaproxeno.buildCard(context, favoritos, onToggleFavorito)
  }, // Naproxeno
  {
    'nome': MedicamentoMeloxicam.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoMeloxicam.buildCard(context, favoritos, onToggleFavorito)
  }, // Meloxicam
  {
    'nome': MedicamentoNimesulida.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoNimesulida.buildCard(context, favoritos, onToggleFavorito)
  }, // Nimesulida

  // OUTROS
  // INDUTORES ANESTESICOS
  // BENZODIAZEPINICOS
  // ANESTESICOS LOCAIS
  // REVERSORES ANTIDOTOS
  {
    'nome': MedicamentoNeostigmina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoNeostigmina.buildCard(context, favoritos, onToggleFavorito)
  }, // Neostigmina
  {
    'nome': MedicamentoProtamina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoProtamina.buildCard(context, favoritos, onToggleFavorito)
  }, // Protamina

  // ANESTESICOS INALATORIOS
  {
    'nome': MedicamentoDesflurano.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDesflurano.buildCard(context, favoritos, onToggleFavorito)
  }, // Desflurano
  {
    'nome': MedicamentoEnflurano.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoEnflurano.buildCard(context, favoritos, onToggleFavorito)
  }, // Enflurano
  {
    'nome': MedicamentoIsoflurano.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoIsoflurano.buildCard(context, favoritos, onToggleFavorito)
  }, // Isoflurano
  {
    'nome': MedicamentoOxidoNitrico.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoOxidoNitrico.buildCard(context, favoritos, onToggleFavorito)
  }, // Oxido Nitrico
  {
    'nome': MedicamentoOxidoNitroso.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoOxidoNitroso.buildCard(context, favoritos, onToggleFavorito)
  }, // Oxido Nitroso
  {
    'nome': MedicamentoSevoflurano.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoSevoflurano.buildCard(context, favoritos, onToggleFavorito)
  }, // Sevoflurano

  // UTEROTONICOS
  {
    'nome': MedicamentoAcetazolamida.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoAcetazolamida.buildCard(
            context, favoritos, onToggleFavorito),
  }, // Acetazolamida
  {
    'nome': MedicamentoDextrose25.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDextrose25.buildCard(context, favoritos, onToggleFavorito),
  }, // Dextrose25
  {
    'nome': MedicamentoGranisetrona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoGranisetrona.buildCard(context, favoritos, onToggleFavorito),
  }, // Granisetrona
  {
    'nome': MedicamentoOndansetrona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoOndansetrona.buildCard(context, favoritos, onToggleFavorito),
  }, // Ondansetrona
  {
    'nome': MedicamentoPalonosetrona.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoPalonosetrona.buildCard(
            context, favoritos, onToggleFavorito),
  }, // Palonosetrona
  // SEDATIVOS ANTIPSICOTICOS
  {
    'nome': MedicamentoPrometazina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoPrometazina.buildCard(context, favoritos, onToggleFavorito),
  }, // Prometazina

  // ANTICOAGULANTES E ANTIPLAQUETÁRIOS (novos)
  {
    'nome': MedicamentoVitaminaK.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoVitaminaK.buildCard(context, favoritos, onToggleFavorito),
  }, // Vitamina K
  {
    'nome': MedicamentoFondaparinux.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoFondaparinux.buildCard(context, favoritos, onToggleFavorito),
  }, // Fondaparinux
  {
    'nome': MedicamentoWarfarina.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoWarfarina.buildCard(context, favoritos, onToggleFavorito),
  }, // Warfarina
  {
    'nome': MedicamentoAAS.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoAAS.buildCard(context, favoritos, onToggleFavorito),
  }, // AAS
  {
    'nome': MedicamentoClopidogrel.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoClopidogrel.buildCard(context, favoritos, onToggleFavorito),
  }, // Clopidogrel
  {
    'nome': MedicamentoTicagrelor.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoTicagrelor.buildCard(context, favoritos, onToggleFavorito),
  }, // Ticagrelor
  {
    'nome': MedicamentoPrasugrel.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoPrasugrel.buildCard(context, favoritos, onToggleFavorito),
  }, // Prasugrel
  {
    'nome': MedicamentoTirofiban.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoTirofiban.buildCard(context, favoritos, onToggleFavorito),
  }, // Tirofiban
  {
    'nome': MedicamentoAbciximab.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoAbciximab.buildCard(context, favoritos, onToggleFavorito),
  }, // Abciximab
  {
    'nome': MedicamentoEptifibatide.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoEptifibatide.buildCard(context, favoritos, onToggleFavorito),
  }, // Eptifibatide
  {
    'nome': MedicamentoRivaroxabana.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoRivaroxabana.buildCard(context, favoritos, onToggleFavorito),
  }, // Rivaroxabana
  {
    'nome': MedicamentoApixabana.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoApixabana.buildCard(context, favoritos, onToggleFavorito),
  }, // Apixabana
  {
    'nome': MedicamentoDabigatrana.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoDabigatrana.buildCard(context, favoritos, onToggleFavorito),
  }, // Dabigatrana
  {
    'nome': MedicamentoEdoxabana.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoEdoxabana.buildCard(context, favoritos, onToggleFavorito),
  }, // Edoxabana

  // Oseltamivir (antifúngicos/outros antivirais na aba Cálculos)
  {
    'nome': MedicamentoOseltamivir.nome,
    'builder': (BuildContext context, Set<String> favoritos,
            void Function(String) onToggleFavorito) =>
        MedicamentoOseltamivir.buildCard(context, favoritos, onToggleFavorito),
  }, // Oseltamivir
];

// Função para converter doses de mcg para mg quando apropriado
String _formatarDoseComConversao(double dose, String unidade) {
  if (unidade.toLowerCase().contains('mcg') && dose >= 100) {
    final doseEmMg = dose / 1000;
    return '${doseEmMg.toStringAsFixed(2)} mg';
  }
  return '${dose.toStringAsFixed(2)} $unidade';
}

//CONFIGURAÇÕES//

/// Página individual do medicamento
class MedicamentoPage extends StatefulWidget {
  final String nome;
  final String idBulario;
  final bool isFavorito;
  final VoidCallback onToggleFavorito;
  final Widget conteudo;

  const MedicamentoPage({
    super.key,
    required this.nome,
    required this.idBulario,
    required this.isFavorito,
    required this.onToggleFavorito,
    required this.conteudo,
  });

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  late bool _isFavorito;

  @override
  void initState() {
    super.initState();
    _isFavorito = widget.isFavorito;
  }

  void _toggleFavorito() {
    setState(() {
      _isFavorito = !_isFavorito;
    });
    widget.onToggleFavorito();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nome),
        actions: [
          // Botão de favorito
          IconButton(
            icon: Icon(
              _isFavorito ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorito ? Colors.amber[700] : null,
            ),
            tooltip: _isFavorito
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: _toggleFavorito,
          ),
          // Botão do bulário
          IconButton(
            icon: const Icon(Icons.description_rounded),
            tooltip: 'Abrir bulário',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BularioPage(principioAtivo: widget.idBulario),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: widget.conteudo,
      ),
    );
  }
}

/**/ Widget buildMedicamentoExpansivel({
  required BuildContext context,
  required String nome,
  required String idBulario,
  required bool isFavorito,
  required VoidCallback onToggleFavorito,
  required Widget conteudo,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        nome,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFavorito)
            Icon(
              Icons.star_rounded,
              color: Colors.amber[700],
              size: 22,
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicamentoPage(
              nome: nome,
              idBulario: idBulario,
              isFavorito: isFavorito,
              onToggleFavorito: onToggleFavorito,
              conteudo: conteudo,
            ),
          ),
        );
      },
    ),
  );
}

/**/ class FavoritosManager {
  static const _key = 'medicamentosFavoritos';
  static const _keyVersaoFavoritos = 'versaoFavoritosPadrao';

  // Incrementar esta versão para forçar reset dos favoritos padrão
  static const int _versaoAtual = 25;

  /// Lista de TODOS os medicamentos (favoritos padrão)
  static const Set<String> medicamentosComInfusao = {
    'Acetazolamida',
    'Adenosina',
    'Adrenalina',
    'Atracúrio',
    'Bumetadina',
    'Bupivacaína',
    'Cefazolina',
    'Ceftriaxona',
    'Cefuroxima',
    'Cisatracúrio',
    'Clindamicina',
    'Cloreto de Potássio',
    'Coloides',
    'Desflurano',
    'Dextrose 25%',
    'Dipirona',
    'Dobutamina',
    'Dopamina',
    'Efedrina',
    'Emulsão Lipídica',
    'Enflurano',
    'Esmolol',
    'Fenilefrina',
    'Furosemida',
    'Granisetrona',
    'Hidrocortisona',
    'Insulina Regular',
    'Isoflurano',
    'Manitol',
    'Meperidina',
    'Metadona',
    'Metaraminol',
    'Metilprednisolona',
    'Metronidazol',
    'Milrinona',
    'Mivacúrio',
    'Morfina',
    'Nalbufina',
    'Neostigmina',
    'Nitroprussiato de Sódio',
    'Noradrenalina',
    'Ondansetrona',
    'Pancurônio',
    'Paracetamol',
    'Petidina',
    'Picada de Cobra',
    'Prilocaína',
    'Remifentanil',
    'Ropivacaína',
    'Salina 3%',
    'Sevoflurano',
    'Solução Salina 20%',
    'Sufentanil',
    'Torasemida',
    'Tramadol',
    'Vancomicina',
    'Vecurônio',
    'Óxido Nítrico',
    'Óxido Nitroso',
    'Prometazina',
    'Meropenem',
    'Piperacilina-Tazobactam',
    'Amicacina',
    'Gentamicina',
    'Ciprofloxacino',
    'Ampicilina',
    'Oxacilina',
    'Cefepime',
    'Azitromicina',
    // Antibióticos IV (novos 25)
    'Ampicilina/Sulbactam',
    'Penicilina G',
    'Cefalotina',
    'Cefoxitina',
    'Cefotaxima',
    'Ceftazidima',
    'Imipenem/Cilastatina',
    'Ertapenem',
    'Aztreonam',
    'Levofloxacino',
    'Teicoplanina',
    'Daptomicina',
    'Polimixina B',
    'Colistina',
    'Oseltamivir',
    'Antiescorpiônico',
    'Antiaracnídico',
    'Cetorolaco',
    'Cetoprofeno',
    'Diclofenaco',
    'Desketoprofeno',
    'Tenoxicam',
    'Parecoxibe',
    'Ibuprofeno',
    'Naproxeno',
    'Meloxicam',
    'Nimesulida',
    'Levosimendan',
    'Angiotensina II',
    'Hidroxocobalamina',
    'Fibrinogênio Concentrado',
  };

  static Future<Set<String>> obterFavoritos() async {
    final prefs = await SharedPreferences.getInstance();

    // Verificar versão dos favoritos padrão
    final versaoSalva = prefs.getInt(_keyVersaoFavoritos) ?? 0;

    // Se a versão mudou, aplicar novos favoritos padrão
    if (versaoSalva < _versaoAtual) {
      await prefs.setStringList(_key, medicamentosComInfusao.toList());
      await prefs.setInt(_keyVersaoFavoritos, _versaoAtual);
      return medicamentosComInfusao;
    }

    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<void> salvarFavorito(
      String nomeMedicamento, bool favorito) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = prefs.getStringList(_key)?.toSet() ?? {};

    if (favorito) {
      favoritos.add(nomeMedicamento);
    } else {
      favoritos.remove(nomeMedicamento);
    }

    await prefs.setStringList(_key, favoritos.toList());
  }

  /// Reseta os favoritos para os padrões (medicamentos com infusão contínua)
  static Future<void> resetarParaPadrao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, medicamentosComInfusao.toList());
  }
}

/**/ class DrogasPage extends StatefulWidget {
  final bool isActive;

  const DrogasPage({super.key, required this.isActive});

  @override
  State<DrogasPage> createState() => _DrogasPageState();
}

/**/ class ConversaoInfusaoSlider extends StatefulWidget {
  final double peso;
  final Map<String, double> opcoesConcentracoes;
  final double doseMin;
  final double doseMax;
  final String unidade;

  /// Se true, indica que a concentração já está em mcg/mL (não converter de mg para mcg)
  final bool concentracaoEmMcg;

  const ConversaoInfusaoSlider({
    Key? key,
    required this.peso,
    required this.opcoesConcentracoes,
    required this.doseMin,
    required this.doseMax,
    required this.unidade,
    this.concentracaoEmMcg = false,
  }) : super(key: key ?? const ValueKey('ConversaoInfusaoSlider'));

  @override
  State<ConversaoInfusaoSlider> createState() => _ConversaoInfusaoSliderState();
}

/**/ class _ConversaoInfusaoSliderState extends State<ConversaoInfusaoSlider> {
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
      // Encontrar a chave com o maior valor de concentração
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
    if (concentracaoSelecionada.isEmpty ||
        !widget.opcoesConcentracoes.containsKey(concentracaoSelecionada)) {
      return 0;
    }

    final conc = widget.opcoesConcentracoes[concentracaoSelecionada];
    if (conc == null || conc == 0) return 0;
    final unidade = widget.unidade.toLowerCase();

    // Determinar se a dose está em mcg/kg/min, mcg/kg/h, mcg/h, mg/kg/h, mg/h, UI/kg/h, U/min, U/kg/min, mL/h ou mL/kg/h
    final isMcgPerKgPerMin = unidade.contains('mcg/kg/min');
    final isMcgPerKgPerH =
        unidade.contains('mcg/kg/h') && !unidade.contains('mcg/h');
    final isMcgPerH = unidade == 'mcg/h'; // dose fixa em mcg/h (não por kg)
    final isMgPerKgPerH = unidade.contains('mg/kg/h');
    final isMgPerH = unidade == 'mg/h'; // dose fixa em mg/h (não por kg)
    final isUIPerKgPerH =
        unidade.contains('ui/kg/h') || unidade.contains('iu/kg/h');
    final isUPerMin =
        unidade.contains('u/min') && !unidade.contains('u/kg/min');
    final isUPerKgPerMin = unidade.contains('u/kg/min');
    final isMlPerH = unidade.contains('ml/h') && !unidade.contains('ml/kg/h');
    final isMlPerKgPerH = unidade.contains('ml/kg/h');

    // Calcular mL/h
    double mlHora;

    if (isMlPerH) {
      // Unidade já é mL/h - retornar direto
      mlHora = dose;
    } else if (isMlPerKgPerH) {
      // mL/kg/h -> mL/h
      mlHora = dose * widget.peso;
    } else if (isMgPerH) {
      // mg/h -> mL/h (dose fixa, não por kg)
      // Concentração em mg/mL
      // Fórmula: mL/h = dose_mg_h / concentração_mg_mL
      mlHora = dose / conc;
    } else if (isMcgPerH) {
      // mcg/h -> mL/h (dose fixa, não por kg)
      // Se concentracaoEmMcg=true, a concentração já está em mcg/mL
      // Se concentracaoEmMcg=false, a concentração está em mg/mL e precisa converter para mcg/mL
      double concMcgMl = widget.concentracaoEmMcg ? conc : conc * 1000;
      // Fórmula: mL/h = dose_mcg_h / concentração_mcg_mL
      mlHora = dose / concMcgMl;
    } else if (isUPerMin) {
      // U/min -> U/h -> mL/h (para vasopressina em adultos)
      // Concentração em U/mL
      double unidadesPorHora = dose * 60; // converter min para hora
      mlHora = unidadesPorHora / conc;
    } else if (isUPerKgPerMin) {
      // U/kg/min -> U/h -> mL/h (para vasopressina pediátrica)
      // Concentração em U/mL
      double unidadesPorHora = dose * widget.peso * 60;
      mlHora = unidadesPorHora / conc;
    } else if (isMcgPerKgPerMin) {
      // mcg/kg/min -> mcg/h -> mL/h
      // Se concentracaoEmMcg=true, a concentração já está em mcg/mL
      // Se concentracaoEmMcg=false, a concentração está em mg/mL e precisa converter para mcg/mL
      double concMcgMl = widget.concentracaoEmMcg ? conc : conc * 1000;
      // Fórmula: mL/h = (dose_mcg_kg_min × peso_kg × 60) / concentração_mcg_mL
      double mcgPorHora = dose * widget.peso * 60;
      mlHora = mcgPorHora / concMcgMl;
    } else if (isMcgPerKgPerH) {
      // mcg/kg/h -> mcg/h -> mL/h
      // Se concentracaoEmMcg=true, a concentração já está em mcg/mL
      // Se concentracaoEmMcg=false, a concentração está em mg/mL e precisa converter para mcg/mL
      double concMcgMl = widget.concentracaoEmMcg ? conc : conc * 1000;
      // Fórmula: mL/h = (dose_mcg_kg_h × peso_kg) / concentração_mcg_mL
      double mcgPorHora = dose * widget.peso;
      mlHora = mcgPorHora / concMcgMl;
    } else if (isMgPerKgPerH) {
      // mg/kg/h -> mg/h -> mL/h
      // Concentração em mg/mL
      double mgPorHora = dose * widget.peso;
      mlHora = mgPorHora / conc;
    } else if (isUIPerKgPerH) {
      // UI/kg/h -> UI/h -> mL/h (para insulina)
      // Concentração em UI/mL
      double uiPorHora = dose * widget.peso;
      mlHora = uiPorHora / conc;
    } else {
      // Fallback para mcg/kg/min
      // Se concentracaoEmMcg=true, a concentração já está em mcg/mL
      double concMcgMl = widget.concentracaoEmMcg ? conc : conc * 1000;
      double mcgPorHora = dose * widget.peso * 60;
      mlHora = mcgPorHora / concMcgMl;
    }

    return mlHora;
  }

  @override
  Widget build(BuildContext context) {
    // Garantir que sempre há uma concentração válida (seleciona a mais alta)
    if (concentracaoSelecionada.isEmpty &&
        widget.opcoesConcentracoes.isNotEmpty) {
      String chaveComMaiorConcentracao = widget.opcoesConcentracoes.keys.first;
      double maiorConcentracao = widget.opcoesConcentracoes.values.first;

      for (final entry in widget.opcoesConcentracoes.entries) {
        if (entry.value > maiorConcentracao) {
          maiorConcentracao = entry.value;
          chaveComMaiorConcentracao = entry.key;
        }
      }

      concentracaoSelecionada = chaveComMaiorConcentracao;
    }

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
            Text(_formatarDoseComConversao(dose, widget.unidade),
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
          divisions: ((widget.doseMax - widget.doseMin) * 500).round().clamp(1, 10000),
          label: dose >= 100 && widget.unidade.toLowerCase().contains('mcg')
              ? '${(dose / 1000).toStringAsFixed(2)} mg'
              : '${dose.toStringAsFixed(3)}',
          onChanged: (valor) {
            setState(() {
              dose = valor;
              mlHora = _calcularMlHora();
            });
          },
        ),
      ],
    );
  }
}

/**/ Widget buildEstrelaFavorito({
  required bool isFavorito,
  required VoidCallback onToggle,
}) {
  return IconButton(
    icon: Icon(
      isFavorito ? Icons.star_rounded : Icons.star_border_rounded,
      color: isFavorito ? Colors.amber[700] : Colors.grey[400],
      size: 26,
    ),
    tooltip: isFavorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
    onPressed: onToggle,
    padding: const EdgeInsets.all(0),
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints(),
  );
}
//CONFIGURAÇÕES//

// Widget para card de categoria expansível
class CategoriaCard extends StatelessWidget {
  final String titulo;
  final List<Widget> medicamentos;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CategoriaCard({
    Key? key,
    required this.titulo,
    required this.medicamentos,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          '${medicamentos.length} medicamento${medicamentos.length != 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        onExpansionChanged: (expanded) => onToggle(),
        children: medicamentos,
      ),
    );
  }
}

/* LISTA DE MEDICAMENTOS */ /**/
class _DrogasPageState extends State<DrogasPage> {
  Set<String> favoritos = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Timer para debounce na busca (otimização de performance)
  Timer? _searchDebounce;

  // Lista pré-ordenada alfabeticamente (calculada uma vez no initState)
  late final List<Map<String, dynamic>> _medicamentosOrdenados;

  // Cache de nomes sem acentos para ordenação rápida
  final Map<String, String> _cacheNomesSemAcento = {};

  // Função para remover acentos para ordenação alfabética (com cache)
  String _removerAcentos(String texto) {
    // Verifica se já está no cache
    if (_cacheNomesSemAcento.containsKey(texto)) {
      return _cacheNomesSemAcento[texto]!;
    }

    const acentos = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
      'Á': 'A',
      'À': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Õ': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
      'Ñ': 'N',
    };

    String resultado = texto;
    acentos.forEach((acento, semAcento) {
      resultado = resultado.replaceAll(acento, semAcento);
    });

    // Armazena no cache
    _cacheNomesSemAcento[texto] = resultado;
    return resultado;
  }

  @override
  void initState() {
    super.initState();

    // Pré-ordenar a lista de medicamentos alfabeticamente (apenas uma vez)
    _medicamentosOrdenados = List.from(_medicamentos);
    _medicamentosOrdenados.sort((a, b) {
      final nomeA = _removerAcentos(a['nome'].toLowerCase());
      final nomeB = _removerAcentos(b['nome'].toLowerCase());
      return nomeA.compareTo(nomeB);
    });

    _carregarFavoritos();

    // Debounce na busca: aguarda 300ms após parar de digitar
    _searchController.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _query = _searchController.text.toLowerCase();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarFavoritos() async {
    final favs = await FavoritosManager.obterFavoritos();
    if (!mounted) return;
    setState(() {
      favoritos = favs;
    });
  }

  void _alternarFavorito(String nomeMedicamento) async {
    final novoEstado = !favoritos.contains(nomeMedicamento);

    // Atualizar UI imediatamente
    setState(() {
      if (novoEstado) {
        favoritos.add(nomeMedicamento);
      } else {
        favoritos.remove(nomeMedicamento);
      }
    });

    // Salvar em background
    await FavoritosManager.salvarFavorito(nomeMedicamento, novoEstado);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }
    final double? idade = SharedData.idade;
    if (idade == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Usar lista pré-ordenada (já ordenada alfabeticamente no initState)
    // Filtrar medicamentos se houver busca
    List<Map<String, dynamic>> medicamentosFiltrados;
    if (_query.isEmpty) {
      medicamentosFiltrados = _medicamentosOrdenados;
    } else {
      medicamentosFiltrados = _medicamentosOrdenados
          .where((med) => med['nome'].toLowerCase().contains(_query))
          .toList();
    }

    // Separar favoritos e não-favoritos (já estão ordenados alfabeticamente)
    // Usar partition para melhor performance
    final favoritosList = <Map<String, dynamic>>[];
    final naoFavoritosList = <Map<String, dynamic>>[];

    for (final med in medicamentosFiltrados) {
      if (favoritos.contains(med['nome'])) {
        favoritosList.add(med);
      } else {
        naoFavoritosList.add(med);
      }
    }

    // Concatenar: favoritos primeiro, depois os demais
    medicamentosFiltrados = [...favoritosList, ...naoFavoritosList];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Medicamentos')),
      body: SafeArea(
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: medicamentosFiltrados.isEmpty
              ? 2
              : medicamentosFiltrados.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Semantics(
                          label: 'Campo de busca de medicamentos ou condições',
                          child: TextField(
                            controller: _searchController,
                            autocorrect: false,
                            style: TextStyle(fontSize: 15, color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Pesquisa',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey.withValues(alpha: 0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.2,
                                ),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              );
            }

            if (medicamentosFiltrados.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nenhum medicamento encontrado.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ajude-nos a melhorar:',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          // Funcionalidade de email será implementada futuramente
                        },
                        child: const Text(
                          'bhdaroz@gmail.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final itemIndex = index - 1;
            final med = medicamentosFiltrados[itemIndex];

            try {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: med['builder'](context, favoritos, _alternarFavorito),
              );
            } catch (e) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Erro ao carregar ${med['nome']}: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
