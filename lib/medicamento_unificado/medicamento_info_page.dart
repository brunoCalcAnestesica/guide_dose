import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../bulario_page.dart';
import 'medicamento_data.dart';

/// Página de informações detalhadas do medicamento
/// Apresentação, preparo, ajustes especiais e observações
class MedicamentoInfoPage extends StatelessWidget {
  final MedicamentoData medicamento;

  const MedicamentoInfoPage({
    super.key,
    required this.medicamento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicamento.nome),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabeçalho
          _buildHeader(context),
          const SizedBox(height: 16),

          // Classe terapêutica
          if (medicamento.classe.isNotEmpty)
            _buildSection(
              icon: Icons.category,
              title: 'Classe',
              content: medicamento.classe,
            ),

          // Apresentações
          if (medicamento.apresentacoes.isNotEmpty)
            _buildApresentacoesSection(),

          // Preparos
          if (medicamento.preparos.isNotEmpty) _buildPreparosSection(),

          // Ajustes especiais
          _buildAjustesSection(),

          // Observações
          if (medicamento.observacoes.isNotEmpty) _buildObservacoesSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicamento.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (medicamento.classe.isNotEmpty)
                  Text(
                    medicamento.classe,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          // Botão Bula
          InkWell(
            onTap: () => _abrirBula(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Bula',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirBula(BuildContext context) {
    // Usa o ID do medicamento (nome do arquivo) para buscar a bula,
    // garantindo que funcione independente do idioma selecionado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BularioPage(principioAtivo: medicamento.id),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color ?? AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color ?? AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildApresentacoesSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, size: 18, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Apresentações',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...medicamento.apresentacoes.map((ap) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ap.forma,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (ap.obs.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ap.obs,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPreparosSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Preparos / Diluições',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...medicamento.preparos.map((preparo) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        preparo.diluicao,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        preparo.concentracao,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAjustesSection() {
    final ajustes = medicamento.ajustesEspeciais;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 18, color: Colors.purple.shade700),
              const SizedBox(width: 8),
              Text(
                'Ajustes Especiais',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Idoso
          _buildAjusteItem(
            icon: Icons.elderly,
            label: 'Idoso',
            value: ajustes.idoso,
            color: Colors.orange,
          ),

          // Renal
          _buildAjusteItem(
            icon: Icons.water_drop,
            label: 'Ajuste Renal',
            value: ajustes.renal,
            color: Colors.red,
          ),

          // Hepático
          _buildAjusteItem(
            icon: Icons.medical_services,
            label: 'Ajuste Hepático',
            value: ajustes.hepatico,
            color: Colors.amber.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildAjusteItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservacoesSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                'Observações Importantes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...medicamento.observacoes.asMap().entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
