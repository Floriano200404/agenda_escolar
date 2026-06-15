import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
// O analyzer acha este import redundante, mas ele NÃO é: importar `sqflite`
// registra o motor de banco padrão no Android/iOS. Sem ele, o app quebra no
// celular. No desktop trocamos esse motor pelo ffi em configurarPlataforma().
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Centraliza a conexão com o banco SQLite e a criação das tabelas.
///
/// Usamos o padrão SINGLETON: existe uma única instância de [DatabaseHelper]
/// no app inteiro (DatabaseHelper.instance). Assim não abrimos várias conexões
/// com o banco — todo mundo usa a mesma.
class DatabaseHelper {
  // Construtor privado: ninguém de fora consegue dar `DatabaseHelper()`.
  DatabaseHelper._interno();

  // A instância única, criada uma vez só.
  static final DatabaseHelper instance = DatabaseHelper._interno();

  static const _nomeBanco = 'agenda_escolar.db';
  static const _versaoBanco = 1;

  // Guarda a conexão aberta pra reaproveitar nas próximas chamadas.
  Database? _db;

  /// Caminho alternativo do banco. Em produção é sempre null (usa o arquivo
  /// padrão no aparelho). Nos testes apontamos para um banco em memória, pra
  /// cada teste rodar isolado e sem sujar o disco.
  static String? caminhoParaTestes;

  /// Configura o sqflite conforme a plataforma.
  ///
  /// No celular (Android/iOS) o sqflite já funciona sozinho. No desktop
  /// (macOS/Windows/Linux) ele precisa do motor "ffi". Como nosso app precisa
  /// rodar nos dois cenários, fazemos essa checagem uma vez, lá no main().
  static void configurarPlataforma() {
    final ehDesktop = !kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (ehDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Devolve a conexão, abrindo (e criando as tabelas) na primeira vez.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _abrirBanco();
    return _db!;
  }

  /// Fecha a conexão atual. Útil entre testes pra começar do zero.
  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _abrirBanco() async {
    final String caminho;
    if (caminhoParaTestes != null) {
      caminho = caminhoParaTestes!;
    } else {
      final pasta = await getDatabasesPath();
      caminho = join(pasta, _nomeBanco);
    }
    return openDatabase(
      caminho,
      version: _versaoBanco,
      onConfigure: (db) async {
        // Liga o suporte a chaves estrangeiras (vem desligado por padrão).
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _criarTabelas,
    );
  }

  /// Roda só na PRIMEIRA vez que o banco é criado.
  /// Aqui ficam as DUAS tabelas exigidas: usuarios e atividades.
  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL,
        criado_em TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE atividades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        disciplina TEXT NOT NULL,
        tipo TEXT NOT NULL,
        data_entrega TEXT NOT NULL,
        concluida INTEGER NOT NULL DEFAULT 0,
        criado_em TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');
  }
}
