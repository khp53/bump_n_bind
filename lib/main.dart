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
      home: const MyHomePage(title: 'BUMP N BIND'),
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
    _HomeAction('NFC Trade', true, (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TradeCodeScreen()),
      );
    }),
    _HomeAction('Other Action 1', false, null),
    _HomeAction('Other Action 2', false, null),
  ];

  void _onActionTap(int index, BuildContext context) {
    if (actions[index].enabled && actions[index].onTap != null) {
      actions[index].onTap!(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2196F3), // Blue
                Color(0xFF001F54), // Navy Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Main content with transparent Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(widget.title, style: const TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView.separated(
            itemCount: actions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 5),
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  leading: const Icon(Icons.nfc, color: Colors.white),
                  title: Text(
                    action.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  enabled: action.enabled,
                  onTap: action.enabled
                      ? () => _onActionTap(index, context)
                      : null,
                  // Removed trailing icon
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeAction {
  final String title;
  final bool enabled;
  final Function(BuildContext)? onTap;
  _HomeAction(this.title, this.enabled, this.onTap);
}
