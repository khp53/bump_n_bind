import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager.dart' as nfc;
import 'package:nfc_manager/nfc_manager.dart'
    show Ndef, NdefMessage, NdefRecord;
import 'contract_model.dart';

class TradeCodeScreen extends StatefulWidget {
  const TradeCodeScreen({Key? key}) : super(key: key);

  @override
  State<TradeCodeScreen> createState() => _TradeCodeScreenState();
}

class _TradeCodeScreenState extends State<TradeCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  String handshakeKey = '';
  ContractModel? receivedContract;

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

  /// Phone A: Write NDEF message containing handshakeKey
  Future<void> writeNdefCode() async {
    if (!await NfcManager.instance.isAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC not available on this device.')),
      );
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tag is not writable.')));
          NfcManager.instance.stopSession(errorMessage: 'Tag not writable');
          return;
        }
        final message = NdefMessage([NdefRecord.createText(handshakeKey)]);
        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code "$handshakeKey" written to NFC tag.')),
          );
          NfcManager.instance.stopSession();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to write: $e')));
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  /// Phone B: Read NDEF message and compare to local handshakeKey
  Future<void> readAndCompareNdefCode() async {
    if (!await NfcManager.instance.isAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC not available on this device.')),
      );
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No NDEF data found.')));
          NfcManager.instance.stopSession(errorMessage: 'No NDEF');
          return;
        }
        final message = ndef.cachedMessage;
        if (message == null || message.records.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No NDEF records found.')),
          );
          NfcManager.instance.stopSession(errorMessage: 'No records');
          return;
        }
        final record = message.records.first;
        String? receivedCode;
        if (record.typeNameFormat == NdefRecordTypeNameFormat.nfcWellKnown &&
            record.type == 'T') {
          receivedCode = NdefRecord.decodeText(record);
        }
        if (receivedCode == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not decode code.')),
          );
          NfcManager.instance.stopSession(errorMessage: 'Decode failed');
          return;
        }
        if (receivedCode == handshakeKey) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Codes match! Proceeding to Phase 4.')),
          );
          // TODO: Proceed to Phase 4
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Codes do not match. Received: $receivedCode'),
            ),
          );
          // Send error response to the other device
          if (ndef.isWritable) {
            final errorMessage = NdefMessage([
              NdefRecord.createText('ERROR: Code mismatch'),
            ]);
            try {
              await ndef.write(errorMessage);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error response sent to device.')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to send error response: $e')),
              );
            }
          }
        }
        NfcManager.instance.stopSession();
      },
    );
  }

  Future<void> swapContractNfc({required ContractModel contract}) async {
    if (!await NfcManager.instance.isAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC not available on this device.')),
      );
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tag is not writable.')));
          NfcManager.instance.stopSession(errorMessage: 'Tag not writable');
          return;
        }
        final message = NdefMessage([
          NdefRecord.createText(contract.toJsonString()),
        ]);
        try {
          await ndef.write(message);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Contract sent via NFC.')));
          NfcManager.instance.stopSession();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send contract: $e')),
          );
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  Future<void> receiveContractNfc() async {
    if (!await NfcManager.instance.isAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC not available on this device.')),
      );
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No NDEF data found.')));
          NfcManager.instance.stopSession(errorMessage: 'No NDEF');
          return;
        }
        final message = ndef.cachedMessage;
        if (message == null || message.records.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No NDEF records found.')),
          );
          NfcManager.instance.stopSession(errorMessage: 'No records');
          return;
        }
        final record = message.records.first;
        String? contractJson;
        if (record.typeNameFormat == NdefRecordTypeNameFormat.nfcWellKnown &&
            record.type == 'T') {
          contractJson = NdefRecord.decodeText(record);
        }
        if (contractJson == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not decode contract.')),
          );
          NfcManager.instance.stopSession(errorMessage: 'Decode failed');
          return;
        }
        try {
          receivedContract = ContractModel.fromJsonString(contractJson);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Contract received!')));
          // TODO: Navigate to SuccessScreen and show contract
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse contract: $e')),
          );
        }
        NfcManager.instance.stopSession();
      },
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
            ElevatedButton(
              onPressed: handshakeKey.isNotEmpty ? writeNdefCode : null,
              child: const Text('Provide (Write NFC)'),
            ),
            ElevatedButton(
              onPressed: handshakeKey.isNotEmpty
                  ? readAndCompareNdefCode
                  : null,
              child: const Text('Request (Read NFC)'),
            ),
            ElevatedButton(
              onPressed: handshakeKey.isNotEmpty
                  ? () {
                      final contract = ContractModel(
                        name: 'User Name',
                        timestamp: DateTime.now(),
                        signatureData: 'signature_base64_or_path',
                      );
                      swapContractNfc(contract: contract);
                    }
                  : null,
              child: const Text('Send Contract'),
            ),
            ElevatedButton(
              onPressed: handshakeKey.isNotEmpty ? receiveContractNfc : null,
              child: const Text('Receive Contract'),
            ),
          ],
        ),
      ),
    );
  }
}
