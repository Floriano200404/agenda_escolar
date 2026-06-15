import '../database/database_helper.dart';
import '../models/atividade.dart';

/// Camada de acesso ao banco para as atividades escolares.
///
/// Aqui ficam as 4 operações do CRUD: criar, listar, editar e excluir.
/// Todas filtram por `usuario_id`, garantindo que cada pessoa só mexe nas
/// próprias atividades.
class AtividadeRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// CREATE — insere uma nova atividade e devolve o id gerado.
  Future<int> criar(Atividade atividade) async {
    final db = await _dbHelper.database;
    return db.insert('atividades', atividade.toMap());
  }

  /// READ — lista as atividades de um usuário.
  /// Ordena por data de entrega (as mais próximas primeiro).
  /// Se [disciplina] for informada, filtra só aquela matéria.
  Future<List<Atividade>> listarPorUsuario(
    int usuarioId, {
    String? disciplina,
  }) async {
    final db = await _dbHelper.database;

    // Monta o WHERE dinamicamente conforme o filtro escolhido.
    final where = StringBuffer('usuario_id = ?');
    final args = <Object>[usuarioId];
    if (disciplina != null && disciplina.isNotEmpty) {
      where.write(' AND disciplina = ?');
      args.add(disciplina);
    }

    final linhas = await db.query(
      'atividades',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'data_entrega ASC',
    );
    return linhas.map(Atividade.fromMap).toList();
  }

  /// Lista os nomes únicos de disciplinas do usuário (para o filtro).
  Future<List<String>> listarDisciplinas(int usuarioId) async {
    final db = await _dbHelper.database;
    final linhas = await db.query(
      'atividades',
      distinct: true,
      columns: ['disciplina'],
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'disciplina ASC',
    );
    return linhas.map((l) => l['disciplina'] as String).toList();
  }

  /// UPDATE — atualiza uma atividade existente (precisa ter id).
  Future<int> atualizar(Atividade atividade) async {
    final db = await _dbHelper.database;
    return db.update(
      'atividades',
      atividade.toMap(),
      where: 'id = ?',
      whereArgs: [atividade.id],
    );
  }

  /// Atalho para marcar/desmarcar como concluída sem abrir o formulário.
  Future<int> definirConcluida(int id, bool concluida) async {
    final db = await _dbHelper.database;
    return db.update(
      'atividades',
      {'concluida': concluida ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE — exclui uma atividade pelo id.
  Future<int> excluir(int id) async {
    final db = await _dbHelper.database;
    return db.delete('atividades', where: 'id = ?', whereArgs: [id]);
  }
}
