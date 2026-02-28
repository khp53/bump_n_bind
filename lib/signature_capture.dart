import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:bump_n_bind/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SignatureCapture extends StatefulWidget {
  const SignatureCapture({Key? key}) : super(key: key);

  @override
  State<SignatureCapture> createState() => _SignatureCaptureState();
}

class _SignatureCaptureState extends State<SignatureCapture> {
  List<Offset?> _points = [];
  final GlobalKey _canvasKey = GlobalKey();

  void _saveSignature() async {
    RenderRepaintBoundary boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Signature saved to ${file.path}')));
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                Text(
                  "SIGNATURE CAPTURE",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Container(
                      color: Colors.grey[200],
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          setState(() {
                            _points.add(
                              renderBox.globalToLocal(details.globalPosition),
                            );
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _points.add(null);
                          });
                        },
                        child: CustomPaint(
                          painter: _SignaturePainter(_points),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveSignature,
                      child: const Text('Save'),
                    ),
                    ElevatedButton(onPressed: _skip, child: const Text('Skip')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) =>
      oldDelegate.points != points;
}
