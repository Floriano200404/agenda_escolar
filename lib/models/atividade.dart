/// Tipos possíveis de uma atividade escolar.
///
/// Guardamos o [valor] como texto no banco (mais simples que um enum puro).
/// O [rotulo] é o que aparece bonito pro usuário na tela.
enum TipoAtividade {
  prova('prova', 'Prova'),
  trabalho('trabalho', 'Trabalho'),
  tarefa('tarefa', 'Tarefa');

  final String valor;
  final String rotulo;
  const TipoAtividade(this.valor, this.rotulo);

  /// Converte o texto vindo do banco de volta pro enum.
  /// Se vier algo inesperado, cai em [tarefa] como padrão seguro.
  static TipoAtividade fromValor(String valor) {
    return TipoAtividade.values.firstWhere(
      (t) => t.valor == valor,
      orElse: () => TipoAtividade.tarefa,
    );
  }
}

/// Representa uma atividade escolar (prova, trabalho ou tarefa).
///
/// Cada atividade pertence a um usuário, ligada pela coluna [usuarioId]
/// (chave estrangeira). Assim cada pessoa só enxerga as próprias atividades.
class Atividade {
  final int? id;
  final int usuarioId;
  final String titulo;
  final String descricao;
  final String disciplina;
  final TipoAtividade tipo;
  final DateTime dataEntrega;
  final bool concluida;
  final String criadoEm;

  const Atividade({
    this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descricao,
    required this.disciplina,
    required this.tipo,
    required this.dataEntrega,
    required this.concluida,
    required this.criadoEm,
  });

  /// Indica se o prazo já passou e a atividade ainda não foi concluída.
  bool get estaAtrasada =>
      !concluida && dataEntrega.isBefore(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'descricao': descricao,
      'disciplina': disciplina,
      'tipo': tipo.valor,
      // Datas viram texto ISO; SQLite não tem tipo de data nativo.
      'data_entrega': dataEntrega.toIso8601String(),
      // bool vira 0/1, que é como o SQLite guarda booleanos.
      'concluida': concluida ? 1 : 0,
      'criado_em': criadoEm,
    };
  }

  factory Atividade.fromMap(Map<String, dynamic> map) {
    return Atividade(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String? ?? '',
      disciplina: map['disciplina'] as String,
      tipo: TipoAtividade.fromValor(map['tipo'] as String),
      dataEntrega: DateTime.parse(map['data_entrega'] as String),
      concluida: (map['concluida'] as int) == 1,
      criadoEm: map['criado_em'] as String,
    );
  }

  /// Cria uma cópia da atividade trocando só os campos informados.
  /// Útil na edição e ao marcar como concluída sem reescrever tudo.
  Atividade copyWith({
    int? id,
    int? usuarioId,
    String? titulo,
    String? descricao,
    String? disciplina,
    TipoAtividade? tipo,
    DateTime? dataEntrega,
    bool? concluida,
    String? criadoEm,
  }) {
    return Atividade(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      disciplina: disciplina ?? this.disciplina,
      tipo: tipo ?? this.tipo,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      concluida: concluida ?? this.concluida,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
