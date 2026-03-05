import 'package:flutter/foundation.dart';

String mensagemErroAmigavel(dynamic e) {
  final msg = e.toString();
  debugPrint('Erro original: $msg');

  if (msg.contains('Connection reset by peer') ||
      msg.contains('SocketException') ||
      msg.contains('ClientException') ||
      msg.contains('Connection closed') ||
      msg.contains('HandshakeException') ||
      msg.contains('TimeoutException') ||
      msg.contains('timeout') ||
      msg.contains('Failed host lookup') ||
      msg.contains('Network is unreachable') ||
      msg.contains('Connection refused')) {
    return 'Erro de conexão. Verifique sua internet e tente novamente.';
  }

  if (msg.contains('Invalid login credentials') ||
      msg.contains('invalid_credentials')) {
    return 'Credenciais inválidas. Verifique email e senha.';
  }

  if (msg.contains('Email not confirmed') ||
      msg.contains('email_not_confirmed')) {
    return 'Email não confirmado. Verifique sua caixa de entrada.';
  }

  if (msg.contains('User already registered') ||
      msg.contains('already been registered')) {
    return 'Este email já está cadastrado.';
  }

  if (msg.contains('duplicate key') || msg.contains('unique_violation')) {
    return 'Registro duplicado. Verifique os dados e tente novamente.';
  }

  if (msg.contains('permission denied') ||
      msg.contains('RLS') ||
      msg.contains('row-level security')) {
    return 'Sem permissão para esta ação.';
  }

  if (msg.contains('PostgrestException') ||
      msg.contains('FunctionException')) {
    return 'Erro ao processar dados. Tente novamente.';
  }

  return 'Ocorreu um erro inesperado. Tente novamente.';
}
