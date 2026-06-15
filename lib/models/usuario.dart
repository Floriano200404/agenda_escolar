/// Representa um usuário do aplicativo.
///
/// A senha NUNCA é guardada em texto puro: o que persiste no banco é o
/// [senhaHash] (um SHA-256 da senha). Por isso o model não conhece a senha
/// original — quem gera o hash é o repositório, na hora de cadastrar/logar.
class Usuario {
  final int? id; // null antes de salvar; o SQLite gera o id (autoincrement)
  final String nome;
  final String email;
  final String senhaHash;
  final String criadoEm; // data em formato ISO 8601 (texto), simples de guardar

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
    required this.criadoEm,
  });

  /// Converte o objeto num Map para o sqflite gravar na tabela.
  /// As chaves precisam ter o MESMO nome das colunas do banco.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'criado_em': criadoEm,
    };
  }

  /// Reconstrói um Usuario a partir de um registro lido do banco.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senhaHash: map['senha_hash'] as String,
      criadoEm: map['criado_em'] as String,
    );
  }
}
