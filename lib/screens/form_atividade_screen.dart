import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../repositories/atividade_repository.dart';
import '../utils/data_util.dart';

/// Formulário usado tanto para CRIAR quanto para EDITAR uma atividade.
///
/// Se [atividadeExistente] vier null, estamos criando. Se vier preenchida,
/// estamos editando — os campos já aparecem com os valores atuais. Reaproveitar
/// a mesma tela evita código duplicado.
class FormAtividadeScreen extends StatefulWidget {
  final int usuarioId;
  final Atividade? atividadeExistente;

  const FormAtividadeScreen({
    super.key,
    required this.usuarioId,
    this.atividadeExistente,
  });

  bool get ehEdicao => atividadeExistente != null;

  @override
  State<FormAtividadeScreen> createState() => _FormAtividadeScreenState();
}

class _FormAtividadeScreenState extends State<FormAtividadeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AtividadeRepository();

  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _disciplinaController;
  late TipoAtividade _tipo;
  late DateTime _dataEntrega;
  late bool _concluida;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Pré-carrega os campos a partir da atividade existente (ou valores padrão).
    final a = widget.atividadeExistente;
    _tituloController = TextEditingController(text: a?.titulo ?? '');
    _descricaoController = TextEditingController(text: a?.descricao ?? '');
    _disciplinaController = TextEditingController(text: a?.disciplina ?? '');
    _tipo = a?.tipo ?? TipoAtividade.tarefa;
    _dataEntrega = a?.dataEntrega ?? DateTime.now();
    _concluida = a?.concluida ?? false;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _disciplinaController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataEntrega,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) {
      setState(() => _dataEntrega = escolhida);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    if (widget.ehEdicao) {
      // Edição: mantém id e criado_em, troca os campos editáveis.
      final atualizada = widget.atividadeExistente!.copyWith(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        disciplina: _disciplinaController.text.trim(),
        tipo: _tipo,
        dataEntrega: _dataEntrega,
        concluida: _concluida,
      );
      await _repo.atualizar(atualizada);
    } else {
      // Criação: monta uma atividade nova ligada ao usuário logado.
      final nova = Atividade(
        usuarioId: widget.usuarioId,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        disciplina: _disciplinaController.text.trim(),
        tipo: _tipo,
        dataEntrega: _dataEntrega,
        concluida: _concluida,
        criadoEm: DateTime.now().toIso8601String(),
      );
      await _repo.criar(nova);
    }

    if (!mounted) return;
    // Devolve `true` pra home saber que precisa recarregar a lista.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ehEdicao ? 'Editar atividade' : 'Nova atividade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _disciplinaController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a disciplina'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoAtividade>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: TipoAtividade.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.rotulo),
                        ))
                    .toList(),
                onChanged: (t) => setState(() => _tipo = t!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),
              // "Campo" de data: na verdade um botão que abre o seletor.
              InkWell(
                onTap: _escolherData,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de entrega',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DataUtil.formatar(_dataEntrega)),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já concluída'),
                value: _concluida,
                onChanged: (v) => setState(() => _concluida = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: const Icon(Icons.save),
                label: Text(_salvando ? 'Salvando...' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
