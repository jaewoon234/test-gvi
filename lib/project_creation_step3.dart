import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'project_creation_step4.dart';
import 'project_data.dart';

class ProjectCreationStep3 extends StatefulWidget {
  final Project project;
  final String imagePath;
  final Function(Project project) onNext;

  const ProjectCreationStep3({
    Key? key,
    required this.project,
    required this.imagePath,
    required this.onNext,
  }) : super(key: key);

  @override
  _ProjectCreationStep3State createState() => _ProjectCreationStep3State();
}

class _ProjectCreationStep3State extends State<ProjectCreationStep3> {
  List<Offset> _points = [];
  List<List<Offset>> _lines = [];
  bool _isTouchEnabled = false;
  GlobalKey _imageKey = GlobalKey();

  void _toggleTouch() {
    setState(() {
      _isTouchEnabled = !_isTouchEnabled;
    });
  }

  void _addPoint(Offset point) {
    if (!_isTouchEnabled) return;

    final RenderBox imageBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Offset imagePosition = imageBox.localToGlobal(Offset.zero); // 이미지의 글로벌 위치를 가져옵니다.
    final Size imageSize = imageBox.size; // 이미지 위젯의 크기를 가져옵니다.

    // 이미지 내에서의 상대적 위치를 계산합니다.
    final Offset relativePosition = point - imagePosition;
    final double scaleX = relativePosition.dx / imageSize.width;
    final double scaleY = relativePosition.dy / imageSize.height;

    setState(() {
      _points.add(Offset(scaleX, scaleY));
      if (_points.length == 2) {
        _lines.add(List.from(_points));
        _points.clear();
      }
    });
  }

  void _navigateToStep4() {
    widget.onNext(widget.project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step 3: Measure Points'),
        actions: [
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: _navigateToStep4,
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: (TapDownDetails details) {
          _addPoint(details.globalPosition);
        },
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(widget.imagePath),
                key: _imageKey, // 이미지 위젯에 GlobalKey 할당
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 119.4),
              child: CustomPaint(
                painter: LinePainter(lines: _lines, imageKey: _imageKey),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTouch,
        tooltip: 'Toggle Touch',
        child: Icon(_isTouchEnabled ? Icons.not_interested : Icons.touch_app),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final GlobalKey imageKey;

  LinePainter({required this.lines, required this.imageKey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..strokeCap = ui.StrokeCap.round;

    final RenderBox imageBox = imageKey.currentContext!.findRenderObject() as RenderBox;
    final Size imageSize = imageBox.size; // 이미지 위젯의 실제 크기를 가져옵니다.

    for (var line in lines) {
      for (int i = 0; i < line.length; i++) {
        // 실제 이미지 크기에 맞게 포인트 위치를 조정합니다.
        final Offset scaledPoint = Offset(line[i].dx * imageSize.width, line[i].dy * imageSize.height);
        canvas.drawCircle(scaledPoint, 3.0, paint);
        if (i < line.length - 1) {
          final Offset nextPoint = Offset(line[i + 1].dx * imageSize.width, line[i + 1].dy * imageSize.height);
          canvas.drawLine(scaledPoint, nextPoint, paint);
        }

        //  * imageSize.width, line[i].dy * imageSize.height
        //  * imageSize.width, line[i + 1].dy * imageSize.height
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
