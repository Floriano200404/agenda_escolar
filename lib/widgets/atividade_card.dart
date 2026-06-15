import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../utils/app_theme.dart';
import '../utils/data_util.dart';

/// Card que mostra UMA atividade na lista.
///
/// Recebe os "callbacks" (funções) do que fazer ao tocar, ao marcar como
/// concluída e ao excluir. Quem decide a lógica é a tela; o card só desenha
/// e avisa. Isso mantém o widget reutilizável e burro de propósito.
class AtividadeCard extends StatelessWidget {
  final Atividade atividade;
  final VoidCallback onTap;
  final ValueChanged<bool> onConcluidaAlterada;
  final VoidCallback onExcluir;

  const AtividadeCard({
    super.key,
    required this.atividade,
    required this.onTap,
    required this.onConcluidaAlterada,
    required this.onExcluir,
  });

  /// Cor da etiqueta de prazo conforme a situação da atividade.
  Color get _corPrazo {
    if (atividade.concluida) return AppTheme.corConcluida;
    if (atividade.estaAtrasada) return AppTheme.corAtrasada;
    return AppTheme.corAVencer;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: atividade.concluida,
          onChanged: (v) => onConcluidaAlterada(v ?? false),
        ),
        title: Text(
          atividade.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            // Risca o texto quando concluída, dando feedback visual.
            decoration:
                atividade.concluida ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${atividade.disciplina} • ${atividade.tipo.rotulo}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: _corPrazo),
                const SizedBox(width: 4),
                Text(
                  '${DataUtil.formatar(atividade.dataEntrega)} — '
                  '${DataUtil.descreverPrazo(atividade.dataEntrega, concluida: atividade.concluida)}',
                  style: TextStyle(color: _corPrazo, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.corAtrasada),
          onPressed: onExcluir,
          tooltip: 'Excluir',
        ),
      ),
    );
  }
}
