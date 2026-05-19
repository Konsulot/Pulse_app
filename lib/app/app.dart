import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class PulseDiagnosticApp extends StatelessWidget {
  const PulseDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pulse Diagnostic',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
