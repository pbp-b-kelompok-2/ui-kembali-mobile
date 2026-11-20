import 'package:material_ui/material_ui.dart';

import 'screens/home_shell.dart';
import 'theme.dart';

void main() => runApp(const UIKembaliApp());

class UIKembaliApp extends StatelessWidget {
  const UIKembaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UIKembali',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeShell(),
    );
  }
}
