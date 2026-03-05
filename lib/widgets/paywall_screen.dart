import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tela exibida quando a cobrança está ativa e o usuário não possui assinatura.
/// Placeholder — será substituída pela integração real com Stripe futuramente.
class PaywallScreen extends StatelessWidget {
  final VoidCallback? onRestorePurchase;
  final VoidCallback? onLogout;

  const PaywallScreen({
    super.key,
    this.onRestorePurchase,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assinatura Necessária',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para continuar usando o GuideDose, é necessário ativar uma assinatura. '
                  'Escolha um plano para ter acesso completo ao app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Placeholder: futuramente abrirá o checkout Stripe
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Checkout em implementação. Entre em contato com o suporte.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver Planos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (onRestorePurchase != null)
                  TextButton(
                    onPressed: onRestorePurchase,
                    child: const Text(
                      'Restaurar compra',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                if (onLogout != null)
                  TextButton(
                    onPressed: onLogout,
                    child: const Text(
                      'Sair da conta',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
