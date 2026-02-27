import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Signature')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.clear(),
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_controller.isNotEmpty) {
                      final signature = await _controller.toPngBytes();
                      if (signature != null) {
                        final directory =
                            await getApplicationDocumentsDirectory();
                        final file = File(
                          '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
                        );
                        await file.writeAsBytes(signature);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Signature saved at ${file.path}'),
                          ),
                        );
                        // Navigate to Home screen
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
