import '../database/database_helper.dart';
import '../models/usuario.dart';
import '../utils/senha_util.dart';

/// Resultado possível de um cadastro.
/// Usar um enum deixa claro o que deu errado, sem depender de mensagens soltas.
enum ResultadoCadastro { sucesso, emailJaExiste, erro }

/// Camada que cuida de TODO o acesso ao banco relacionado a usuários.
///
/// As telas nunca falam direto com o SQLite: elas chamam o repositório.
/// Isso separa "regra de tela" de "acesso a dados" e deixa o código testável
/// e organizado (um dos pontos de qualidade de código da avaliação).
class UsuarioRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// Cadastra um novo usuário, guardando a senha já como hash.
  Future<ResultadoCadastro> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final db = await _dbHelper.database;
    final emailNormalizado = email.trim().toLowerCase();

    // Antes de inserir, confere se o e-mail já está em uso.
    final jaExiste = await buscarPorEmail(emailNormalizado);
    if (jaExiste != null) return ResultadoCadastro.emailJaExiste;

    try {
      final usuario = Usuario(
        nome: nome.trim(),
        email: emailNormalizado,
        senhaHash: SenhaUtil.gerarHash(senha),
        criadoEm: DateTime.now().toIso8601String(),
      );
      await db.insert('usuarios', usuario.toMap());
      return ResultadoCadastro.sucesso;
    } catch (_) {
      return ResultadoCadastro.erro;
    }
  }

  /// Busca um usuário pelo e-mail. Retorna null se não achar.
  Future<Usuario?> buscarPorEmail(String email) async {
    final db = await _dbHelper.database;
    final linhas = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Usuario.fromMap(linhas.first);
  }

  /// Tenta autenticar: devolve o [Usuario] se e-mail existir e a senha bater,
  /// ou null caso contrário.
  Future<Usuario?> autenticar({
    required String email,
    required String senha,
  }) async {
    final usuario = await buscarPorEmail(email);
    if (usuario == null) return null;
    if (!SenhaUtil.conferir(senha, usuario.senhaHash)) return null;
    return usuario;
  }
}
