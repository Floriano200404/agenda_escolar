import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../utils/app_theme.dart';

/// FUNCIONALIDADE APLICADA AO TEMA.
///
/// Este painel é o "algo útil com os dados" exigido pelo trabalho. A partir da
/// lista de atividades, ele calcula e mostra três números que ajudam o aluno
/// a se organizar:
///   - Pendentes: ainda não concluídas
///   - Atrasadas: o prazo já passou e não foram concluídas
///   - A vencer: prazo dentro dos próximos 7 dias (e ainda não concluídas)
class PainelResumo extends StatelessWidget {
  final List<Atividade> atividades;

  const PainelResumo({super.key, required this.atividades});

  int get _pendentes => atividades.where((a) => !a.concluida).length;

  int get _atrasadas => atividades.where((a) => a.estaAtrasada).length;

  int get _aVencer {
    final agora = DateTime.now();
    final limite = agora.add(const Duration(days: 7));
    return atividades
        .where((a) =>
            !a.concluida &&
            a.dataEntrega.isAfter(agora) &&
            a.dataEntrega.isBefore(limite))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _Contador(
            rotulo: 'Pendentes',
            valor: _pendentes,
            cor: AppTheme.corPrincipal,
            icone: Icons.pending_actions,
          ),
          const SizedBox(width: 8),
          _Contador(
            rotulo: 'Atrasadas',
            valor: _atrasadas,
            cor: AppTheme.corAtrasada,
            icone: Icons.warning_amber,
          ),
          const SizedBox(width: 8),
          _Contador(
            rotulo: 'A vencer (7d)',
            valor: _aVencer,
            cor: AppTheme.corAVencer,
            icone: Icons.upcoming,
          ),
        ],
      ),
    );
  }
}

/// Cartãozinho de um contador do painel. Privado: só este arquivo usa.
class _Contador extends StatelessWidget {
  final String rotulo;
  final int valor;
  final Color cor;
  final IconData icone;

  const _Contador({
    required this.rotulo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    // Expanded faz os três contadores dividirem a largura igualmente.
    return Expanded(
      child: Card(
        color: cor.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icone, color: cor),
              const SizedBox(height: 4),
              Text(
                '$valor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
              Text(
                rotulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
