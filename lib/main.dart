import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'database/database_helper.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Garante que os plugins estejam prontos antes de usar banco/locale.
  WidgetsFlutterBinding.ensureInitialized();

  // Configura o SQLite conforme a plataforma (celular x desktop).
  DatabaseHelper.configurarPlataforma();

  // Carrega os dados de formatação de data em português do Brasil.
  await initializeDateFormatting('pt_BR', null);

  runApp(const AgendaEscolarApp());
}

class AgendaEscolarApp extends StatelessWidget {
  const AgendaEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // O ChangeNotifierProvider deixa o AuthProvider acessível em todo o app.
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Agenda Escolar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.tema,
        home: const LoginScreen(),
      ),
    );
  }
}
