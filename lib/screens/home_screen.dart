import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/atividade.dart';
import '../providers/auth_provider.dart';
import '../repositories/atividade_repository.dart';
import '../widgets/atividade_card.dart';
import '../widgets/painel_resumo.dart';
import 'form_atividade_screen.dart';
import 'login_screen.dart';

/// Tela principal após o login.
///
/// Reúne: o painel-resumo (funcionalidade aplicada), o filtro por disciplina,
/// a lista de atividades e os botões de criar/editar/excluir.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = AtividadeRepository();

  List<Atividade> _atividades = [];
  List<String> _disciplinas = [];
  String? _disciplinaSelecionada; // null = "Todas"
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  int get _usuarioId => context.read<AuthProvider>().usuarioLogado!.id!;

  /// Busca no banco a lista (já filtrada pela disciplina escolhida) e a
  /// relação de disciplinas para o filtro. O painel reflete o que está filtrado.
  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final atividades = await _repo.listarPorUsuario(
      _usuarioId,
      disciplina: _disciplinaSelecionada,
    );
    final disciplinas = await _repo.listarDisciplinas(_usuarioId);

    if (!mounted) return;
    setState(() {
      _atividades = atividades;
      _disciplinas = disciplinas;
      _carregando = false;
    });
  }

  Future<void> _abrirFormulario({Atividade? atividade}) async {
    // Espera a tela de formulário retornar. Se voltou `true`, algo mudou.
    final alterou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAtividadeScreen(
          usuarioId: _usuarioId,
          atividadeExistente: atividade,
        ),
      ),
    );
    if (alterou == true) _carregarDados();
  }

  Future<void> _alternarConcluida(Atividade a, bool concluida) async {
    await _repo.definirConcluida(a.id!, concluida);
    _carregarDados();
  }

  /// Exclusão SEMPRE com confirmação, como pede o enunciado.
  Future<void> _confirmarExclusao(Atividade a) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir atividade'),
        content: Text('Tem certeza que deseja excluir "${a.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _repo.excluir(a.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade excluída.')),
      );
      _carregarDados();
    }
  }

  void _sair() {
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuarioLogado;

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${usuario?.nome ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PainelResumo(atividades: _atividades),
                _filtroDisciplina(),
                Expanded(child: _listaAtividades()),
              ],
            ),
    );
  }

  /// Filtro por disciplina (a funcionalidade aplicada complementar).
  Widget _filtroDisciplina() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: _disciplinaSelecionada,
              hint: const Text('Todas as disciplinas'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todas as disciplinas'),
                ),
                ..._disciplinas.map(
                  (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
                ),
              ],
              onChanged: (valor) {
                setState(() => _disciplinaSelecionada = valor);
                _carregarDados();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _listaAtividades() {
    if (_atividades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nenhuma atividade por aqui.\nToque em "Nova" para cadastrar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.builder(
      // Espaço extra no fim pra lista não ficar embaixo do botão flutuante.
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _atividades.length,
      itemBuilder: (_, i) {
        final atividade = _atividades[i];
        return AtividadeCard(
          atividade: atividade,
          onTap: () => _abrirFormulario(atividade: atividade),
          onConcluidaAlterada: (v) => _alternarConcluida(atividade, v),
          onExcluir: () => _confirmarExclusao(atividade),
        );
      },
    );
  }
}
