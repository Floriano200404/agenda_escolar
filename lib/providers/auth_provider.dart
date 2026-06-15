import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

/// Guarda QUEM está logado no app, de um jeito acessível por qualquer tela.
///
/// É um ChangeNotifier (do pacote provider). Quando o usuário entra ou sai,
/// chamamos notifyListeners() e as telas que "escutam" se atualizam sozinhas.
/// Assim não precisamos passar o usuário manualmente de tela em tela.
class AuthProvider extends ChangeNotifier {
  final UsuarioRepository _repo = UsuarioRepository();

  Usuario? _usuarioLogado;
  Usuario? get usuarioLogado => _usuarioLogado;

  bool get estaLogado => _usuarioLogado != null;

  /// Tenta logar. Retorna true se deu certo (e guarda o usuário).
  Future<bool> login(String email, String senha) async {
    final usuario = await _repo.autenticar(email: email, senha: senha);
    if (usuario == null) return false;
    _usuarioLogado = usuario;
    notifyListeners();
    return true;
  }

  /// Encerra a sessão e volta o app para a tela de login.
  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
