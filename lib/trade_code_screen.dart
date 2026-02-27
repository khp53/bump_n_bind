import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager.dart' as nfc;
import 'package:nfc_manager/nfc_manager.dart'
    show Ndef, NdefMessage, NdefRecord;

class TradeCodeScreen extends StatefulWidget {
  const TradeCodeScreen({Key? key}) : super(key: key);

  @override
  State<TradeCodeScreen> createState() => _TradeCodeScreenState();
}

class _TradeCodeScreenState extends State<TradeCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  String handshakeKey = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceedToScanning() {
    // TODO: Implement navigation to Scanning phase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding with handshake key: $handshakeKey')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Handshake Key')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Handshake Key',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  handshakeKey = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: handshakeKey.isNotEmpty ? _proceedToScanning : null,
              child: const Text('Proceed to Scanning'),
            ),
          ],
        ),
      ),
    );
  }
}
