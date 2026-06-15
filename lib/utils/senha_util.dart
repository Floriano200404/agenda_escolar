import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Funções relacionadas à segurança da senha.
///
/// Guardar senha em texto puro no banco é um erro clássico de segurança: se
/// alguém abrir o arquivo do SQLite, veria todas as senhas. Por isso geramos
/// um HASH (SHA-256). O hash é "de mão única": dá pra transformar a senha em
/// hash, mas não dá pra voltar do hash pra senha.
///
/// No login, geramos o hash da senha digitada e comparamos com o hash salvo.
class SenhaUtil {
  /// Converte a senha em texto num hash SHA-256 (string hexadecimal).
  static String gerarHash(String senha) {
    final bytes = utf8.encode(senha); // texto -> bytes
    final digest = sha256.convert(bytes); // bytes -> hash
    return digest.toString();
  }

  /// Confere se a senha digitada bate com o hash guardado.
  static bool conferir(String senhaDigitada, String hashSalvo) {
    return gerarHash(senhaDigitada) == hashSalvo;
  }
}
