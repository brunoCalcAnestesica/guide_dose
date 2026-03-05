import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_colors.dart';

class ProfileData {
  const ProfileData({
    this.fullName,
    this.crm,
    this.crmNaoFormado = false,
    this.address,
    this.phone,
    this.specialty,
    this.rqe,
  });

  final String? fullName;
  final String? crm;
  final bool crmNaoFormado;
  final String? address;
  final String? phone;
  final String? specialty;
  final String? rqe;

  ProfileData copyWith({
    String? fullName,
    String? crm,
    bool? crmNaoFormado,
    String? address,
    String? phone,
    String? specialty,
    String? rqe,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      crm: crm ?? this.crm,
      crmNaoFormado: crmNaoFormado ?? this.crmNaoFormado,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      rqe: rqe ?? this.rqe,
    );
  }
}

enum ProfileEditResult {
  saved,
  skipped,
  cancelled,
}

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({
    super.key,
    required this.initialData,
    this.allowSkip = false,
    this.title,
  });

  final ProfileData initialData;
  final bool allowSkip;
  final String? title;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _crmController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _rqeController = TextEditingController();

  bool _crmNaoFormado = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.initialData.fullName ?? '';
    _crmController.text = widget.initialData.crm ?? '';
    _enderecoController.text = widget.initialData.address ?? '';
    _telefoneController.text = widget.initialData.phone ?? '';
    _especialidadeController.text = widget.initialData.specialty ?? '';
    _rqeController.text = widget.initialData.rqe ?? '';
    _crmNaoFormado = widget.initialData.crmNaoFormado;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _crmController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _especialidadeController.dispose();
    _rqeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      _mostrarMensagem('Usuario nao autenticado.');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      return;
    }

    final nome = _nomeController.text.trim();
    final crm = _crmController.text.trim();
    final endereco = _enderecoController.text.trim();
    final telefone = _telefoneController.text.trim();
    final especialidade = _especialidadeController.text.trim();
    final rqe = _rqeController.text.trim();

    final metadata = <String, dynamic>{
      'crm_nao_formado': _crmNaoFormado,
    };
    if (nome.isNotEmpty) metadata['full_name'] = nome;
    if (!_crmNaoFormado && crm.isNotEmpty) metadata['crm'] = crm;
    if (endereco.isNotEmpty) metadata['address'] = endereco;
    if (telefone.isNotEmpty) metadata['phone'] = telefone;
    if (especialidade.isNotEmpty) metadata['specialty'] = especialidade;
    if (rqe.isNotEmpty) metadata['rqe'] = rqe;

    final profileData = <String, dynamic>{
      'id': user.id,
      'email': user.email,
      'full_name': nome.isEmpty ? null : nome,
      'crm': _crmNaoFormado ? null : (crm.isEmpty ? null : crm),
      'crm_nao_formado': _crmNaoFormado,
      'address': endereco.isEmpty ? null : endereco,
      'phone': telefone.isEmpty ? null : telefone,
      'specialty': especialidade.isEmpty ? null : especialidade,
      'rqe': rqe.isEmpty ? null : rqe,
    };

    try {
      await client.auth.updateUser(UserAttributes(data: metadata));
      await client.from('profiles').upsert(profileData);
      await client.auth.refreshSession();
    } catch (_) {
      if (mounted) {
        _mostrarMensagem('Nao foi possivel salvar seus dados.');
      }
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(ProfileEditResult.saved);
  }

  void _mostrarMensagem(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled ? AppColors.primary : Colors.grey,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              icon,
              color: enabled ? AppColors.primary.withOpacity(0.7) : Colors.grey,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ??
        (widget.allowSkip ? 'Complete seu cadastro' : 'Editar cadastro');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              // Seção: Dados Pessoais
              _buildSectionTitle('DADOS PESSOAIS'),
              _buildTextField(
                controller: _nomeController,
                label: 'Nome completo',
                icon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _telefoneController,
                label: 'Telefone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _enderecoController,
                label: 'Endereço',
                icon: Icons.location_on_outlined,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 28),

              // Seção: Dados Profissionais
              _buildSectionTitle('DADOS PROFISSIONAIS'),
              _buildTextField(
                controller: _crmController,
                label: 'CRM',
                icon: Icons.badge_outlined,
                enabled: !_crmNaoFormado,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  dense: true,
                  value: _crmNaoFormado,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    'Ainda não sou formado',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _crmNaoFormado = value ?? false;
                      if (_crmNaoFormado) {
                        _crmController.text = '';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _especialidadeController,
                label: 'Especialidade',
                icon: Icons.medical_services_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _rqeController,
                label: 'RQE',
                icon: Icons.verified_outlined,
              ),

              const SizedBox(height: 40),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _salvar,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Salvar alterações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              if (widget.allowSkip) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop(ProfileEditResult.skipped);
                        },
                  child: Text(
                    'Preencher depois',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Footer LGPD e Copyright
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Todas as informações coletadas são tratadas em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018). Seus dados são protegidos e utilizados exclusivamente para melhorar sua experiência.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.grey.shade300,
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© 2026 Guide Dose. Todos os direitos reservados.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
