import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:agenda_escolar/database/database_helper.dart';
import 'package:agenda_escolar/models/atividade.dart';
import 'package:agenda_escolar/repositories/atividade_repository.dart';
import 'package:agenda_escolar/repositories/usuario_repository.dart';

/// Testes de INTEGRAÇÃO: rodam o SQLite de verdade (em memória) sem precisar
/// de celular nem emulador. Provam que as tabelas, o login e o CRUD funcionam.
void main() {
  // Liga o motor ffi, que permite o SQLite rodar no ambiente de teste.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Antes de cada teste, recomeça com um banco em memória limpo.
  setUp(() async {
    await DatabaseHelper.instance.fechar();
    DatabaseHelper.caminhoParaTestes = inMemoryDatabasePath;
  });

  test('cadastra usuário, faz login e bloqueia e-mail duplicado', () async {
    final repo = UsuarioRepository();

    final r1 = await repo.cadastrar(
      nome: 'Maria',
      email: 'maria@escola.com',
      senha: '1234',
    );
    expect(r1, ResultadoCadastro.sucesso);

    // Login correto devolve o usuário; senha errada devolve null.
    expect(await repo.autenticar(email: 'maria@escola.com', senha: '1234'),
        isNotNull);
    expect(await repo.autenticar(email: 'maria@escola.com', senha: 'errada'),
        isNull);

    // Mesmo e-mail não pode cadastrar de novo.
    final r2 = await repo.cadastrar(
      nome: 'Outra',
      email: 'maria@escola.com',
      senha: '9999',
    );
    expect(r2, ResultadoCadastro.emailJaExiste);
  });

  test('CRUD completo de atividades funciona', () async {
    final usuarios = UsuarioRepository();
    final atividades = AtividadeRepository();

    await usuarios.cadastrar(
        nome: 'João', email: 'joao@escola.com', senha: '1234');
    final usuario = await usuarios.buscarPorEmail('joao@escola.com');
    final uid = usuario!.id!;

    // CREATE
    final id = await atividades.criar(Atividade(
      usuarioId: uid,
      titulo: 'Prova de História',
      descricao: 'Capítulos 1 a 3',
      disciplina: 'História',
      tipo: TipoAtividade.prova,
      dataEntrega: DateTime(2026, 6, 19),
      concluida: false,
      criadoEm: DateTime.now().toIso8601String(),
    ));
    expect(id, greaterThan(0));

    // READ
    var lista = await atividades.listarPorUsuario(uid);
    expect(lista.length, 1);
    expect(lista.first.titulo, 'Prova de História');

    // UPDATE
    await atividades.atualizar(lista.first.copyWith(titulo: 'Prova adiada'));
    lista = await atividades.listarPorUsuario(uid);
    expect(lista.first.titulo, 'Prova adiada');

    // Filtro por disciplina
    final deHistoria =
        await atividades.listarPorUsuario(uid, disciplina: 'História');
    expect(deHistoria.length, 1);
    final deMatematica =
        await atividades.listarPorUsuario(uid, disciplina: 'Matemática');
    expect(deMatematica, isEmpty);

    // DELETE
    await atividades.excluir(id);
    expect(await atividades.listarPorUsuario(uid), isEmpty);
  });
}
