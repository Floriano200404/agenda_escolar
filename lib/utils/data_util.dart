import 'package:intl/intl.dart';

/// Funções de formatação de datas no padrão brasileiro (dd/MM/yyyy).
///
/// O banco guarda a data como texto ISO (2026-06-19T...). Aqui convertemos
/// para um formato amigável de exibir na tela.
class DataUtil {
  static final DateFormat _formatoBr = DateFormat('dd/MM/yyyy', 'pt_BR');

  /// Ex.: 19/06/2026
  static String formatar(DateTime data) => _formatoBr.format(data);

  /// Texto relativo ao prazo, pra deixar a lista mais informativa.
  /// Ex.: "Atrasada há 2 dia(s)", "Vence hoje", "Faltam 3 dia(s)".
  static String descreverPrazo(DateTime dataEntrega, {required bool concluida}) {
    if (concluida) return 'Concluída';

    final hoje = DateTime.now();
    // Compara só a data (sem hora) pra "hoje" funcionar como esperado.
    final dia = DateTime(dataEntrega.year, dataEntrega.month, dataEntrega.day);
    final diaHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final diferenca = dia.difference(diaHoje).inDays;

    if (diferenca < 0) return 'Atrasada há ${-diferenca} dia(s)';
    if (diferenca == 0) return 'Vence hoje';
    if (diferenca == 1) return 'Vence amanhã';
    return 'Faltam $diferenca dia(s)';
  }
}
