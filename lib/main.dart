import 'package:flutter/material.dart';
import 'signature_capture.dart';
import 'trade_code_screen.dart';
import 'signature_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // Example: To start with SignatureCapture screen, use:
      // home: SignatureCapture(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<_HomeAction> actions = [
    _HomeAction('NFC Trade', true, () {
      // TODO: Implement NFC Trade navigation
    }),
    _HomeAction('Other Action 1', false, null),
    _HomeAction('Other Action 2', false, null),
  ];

  void _onActionTap(int index) {
    if (actions[index].enabled && actions[index].onTap != null) {
      actions[index].onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return ListTile(
            title: Text(action.title),
            enabled: action.enabled,
            onTap: action.enabled ? () => _onActionTap(index) : null,
            trailing: action.enabled ? const Icon(Icons.chevron_right) : null,
          );
        },
      ),
    );
  }
}

class _HomeAction {
  final String title;
  final bool enabled;
  final VoidCallback? onTap;
  _HomeAction(this.title, this.enabled, this.onTap);
}
