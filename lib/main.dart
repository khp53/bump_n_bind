import 'package:flutter/material.dart';
import 'trade_code_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'BUMP N BIND'),
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
