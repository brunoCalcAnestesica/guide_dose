import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin/notification_preferences_page.dart';
import 'services/fcm_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'profile_edit_page.dart';
import 'utils/error_messages.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  User? _user;
  ProfileData? _profileData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() { _loading = false; });
      return;
    }
    final dados = await _carregarDadosCadastro(user.id);
    if (mounted) {
      setState(() {
        _user = user;
        _profileData = dados;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _PerfilTabContent(
              user: _user,
              profileData: _profileData,
              isBrazilLocale: _isBrazilLocale(context),
              onEditarCadastro: () async {
                await _abrirEdicaoCadastro(context);
                _carregarDados();
              },
              onSuporte: () => _abrirSuporteWhatsapp(context),
              onSair: () => _confirmarLogout(context),
              onExcluirConta: () => _confirmarExclusaoConta(context),
            ),
    );
  }

  static bool _isBrazilLocale(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    if (locale?.countryCode?.toUpperCase() == 'BR') return true;
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final loc in locales) {
      if (loc.countryCode?.toUpperCase() == 'BR') return true;
    }
    return false;
  }

  static String? _extrairString(dynamic value) {
    if (value is String) return value;
    return null;
  }

  static bool _extrairBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  static Future<ProfileData?> _carregarDadosCadastro(String userId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata ?? {};
    final base = ProfileData(
      fullName: _extrairString(metadata['full_name']) ??
          _extrairString(metadata['name']),
      crm: _extrairString(metadata['crm']),
      crmNaoFormado: _extrairBool(metadata['crm_nao_formado']),
      address: _extrairString(metadata['address']),
      phone: _extrairString(metadata['phone']),
      specialty: _extrairString(metadata['specialty']),
      rqe: _extrairString(metadata['rqe']),
    );

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select(
              'full_name, crm, crm_nao_formado, address, phone, specialty, rqe')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return base;

      final profileNome = _extrairString(profile['full_name']);
      final profileCrm = _extrairString(profile['crm']);
      final profileNaoFormado = _extrairBool(profile['crm_nao_formado']);
      final profileEndereco = _extrairString(profile['address']);
      final profileTelefone = _extrairString(profile['phone']);
      final profileEspecialidade = _extrairString(profile['specialty']);
      final profileRqe = _extrairString(profile['rqe']);

      return base.copyWith(
        fullName: (base.fullName == null || base.fullName!.trim().isEmpty)
            ? profileNome
            : base.fullName,
        crm: (base.crm == null || base.crm!.trim().isEmpty)
            ? profileCrm
            : base.crm,
        crmNaoFormado: base.crmNaoFormado || profileNaoFormado,
        address: (base.address == null || base.address!.trim().isEmpty)
            ? profileEndereco
            : base.address,
        phone: (base.phone == null || base.phone!.trim().isEmpty)
            ? profileTelefone
            : base.phone,
        specialty: (base.specialty == null || base.specialty!.trim().isEmpty)
            ? profileEspecialidade
            : base.specialty,
        rqe: (base.rqe == null || base.rqe!.trim().isEmpty)
            ? profileRqe
            : base.rqe,
      );
    } catch (_) {
      return base;
    }
  }

  static Future<void> _abrirEdicaoCadastro(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final dados = await _carregarDadosCadastro(user.id);
    if (!context.mounted || dados == null) return;

    await Navigator.of(context).push<ProfileEditResult>(
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(
          initialData: dados,
          allowSkip: false,
          title: 'Editar cadastro',
        ),
      ),
    );
  }

  static Future<void> _abrirSuporteWhatsapp(BuildContext context) async {
    const whatsappUrl = 'https://wa.me/5511960176851';
    final uri = Uri.parse(whatsappUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o WhatsApp.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> _confirmarLogout(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do app'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmou != true || !context.mounted) return;
    await _logout(context);
  }

  static Future<void> _logout(BuildContext context) async {
    try {
      await FcmService.instance.unregisterToken();
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível sair. Tente novamente.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> _confirmarExclusaoConta(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta?\n\n'
          'Esta ação é irreversível e todos os seus dados serão permanentemente removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true || !context.mounted) return;

    final confirmaFinal = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação final'),
        content: const Text(
          'Você realmente deseja excluir permanentemente sua conta e todos os dados associados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não, manter conta'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, excluir tudo'),
          ),
        ],
      ),
    );

    if (confirmaFinal != true || !context.mounted) return;
    await _excluirConta(context);
  }

  static Future<void> _excluirConta(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Faça login novamente.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await Supabase.instance.client.functions.invoke(
        'delete-user-account',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (response.status != 200 && response.status != 204) {
        final msg = response.data is Map && response.data['error'] != null
            ? response.data['error'] as String
            : response.status.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: $msg'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta excluída com sucesso.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir conta: ${mensagemErroAmigavel(e)}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _PerfilTabContent extends StatelessWidget {
  const _PerfilTabContent({
    required this.user,
    required this.profileData,
    required this.isBrazilLocale,
    required this.onEditarCadastro,
    required this.onSuporte,
    required this.onSair,
    required this.onExcluirConta,
  });

  final User? user;
  final ProfileData? profileData;
  final bool isBrazilLocale;
  final VoidCallback onEditarCadastro;
  final VoidCallback onSuporte;
  final VoidCallback onSair;
  final VoidCallback onExcluirConta;

  static String _v(dynamic v) =>
      (v is String && v.trim().isNotEmpty) ? v.trim() : '—';

  @override
  Widget build(BuildContext context) {
    final nome = _v(profileData?.fullName ?? user?.userMetadata?['name'] ?? user?.userMetadata?['full_name']);
    final email = _v(user?.email ?? '');
    final telefone = _v(profileData?.phone);
    final profissao = '—'; // reservado para futuro
    final conselho = _v(profileData?.crm);
    final areaAtuacao = _v(profileData?.specialty);
    final certificacao = _v(profileData?.rqe);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Dados cadastrais'),
          _buildInfoRow('Nome', nome),
          _buildInfoRow('E-mail', email),
          _buildInfoRow('Telefone', telefone),
          const SizedBox(height: 20),
          _buildSectionTitle('Ocupações'),
          _buildInfoRow('Profissão', profissao),
          _buildInfoRow('Conselho', conselho),
          _buildInfoRow('Área de atuação', areaAtuacao),
          _buildInfoRow('Certificação', certificacao),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FilledButton.icon(
              onPressed: onEditarCadastro,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar informações'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'O e-mail da conta não pode ser alterado.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.notifications_active,
                color: AppColors.primary),
            title: const Text('Notificações'),
            subtitle: const Text('Gerenciar notificações do app'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        const NotificationPreferencesPage()),
              );
            },
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.support_agent, color: AppColors.primary),
            title: const Text('Suporte'),
            subtitle: const Text('Falar no WhatsApp'),
            onTap: onSuporte,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sair'),
            onTap: onSair,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Excluir conta'),
            subtitle: const Text('Remove todos os seus dados'),
            onTap: onExcluirConta,
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary.withValues(alpha: 0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
