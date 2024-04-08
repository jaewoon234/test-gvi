import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
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
  Offset? _temporaryPoint; // Temporary point for dynamic line drawing

  void _toggleTouch() {
    setState(() {
      _isTouchEnabled = !_isTouchEnabled;
    });
  }

  Offset _convertToRelativePosition(Offset globalPosition) {
    final RenderBox imageBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Offset imagePosition = imageBox.localToGlobal(Offset.zero);
    final Size imageSize = imageBox.size;

    final Offset relativePosition = globalPosition - imagePosition;
    final double scaleX = relativePosition.dx / imageSize.width;
    final double scaleY = relativePosition.dy / imageSize.height;

    return Offset(scaleX, scaleY);
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!_isTouchEnabled) return;

    final Offset relativePosition = _convertToRelativePosition(details.globalPosition);
    setState(() {
      _points.add(relativePosition);
    });
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isTouchEnabled) return;

    final Offset relativePosition = _convertToRelativePosition(details.globalPosition);
    setState(() {
      _temporaryPoint = relativePosition;
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_isTouchEnabled || _temporaryPoint == null) return;

    setState(() {
      _points.add(_temporaryPoint!);
      if (_points.length == 2) {
        _lines.add(List.from(_points));
        _points.clear();
      }
      _temporaryPoint = null;
    });
  }

  void _undoLastAction() {
    setState(() {
      if (_points.isNotEmpty) {
        _points.removeLast();
      } else if (_lines.isNotEmpty) {
        _lines.removeLast();
      }
      _temporaryPoint = null;
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
        onLongPressStart: _handleLongPressStart,
        onLongPressMoveUpdate: _handleLongPressMoveUpdate,
        onLongPressEnd: _handleLongPressEnd,
        child: Stack(
          children: [
            Container(
              child: Image.file(
                File(widget.imagePath),
                key: _imageKey,
                fit: BoxFit.contain,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: LinePainter(lines: _lines, points: _points, imageKey: _imageKey, temporaryPoint: _temporaryPoint),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _toggleTouch,
            tooltip: 'Toggle Touch',
            child: Icon(_isTouchEnabled ? Icons.not_interested : Icons.touch_app),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _undoLastAction,
            tooltip: 'Undo Last Action',
            child: Icon(Icons.undo),
          ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> points;
  final GlobalKey imageKey;
  final Offset? temporaryPoint;

  LinePainter({required this.lines, required this.points, required this.imageKey, this.temporaryPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..strokeCap = ui.StrokeCap.round;

    final RenderBox imageBox = imageKey.currentContext!.findRenderObject() as RenderBox;
    final Size imageSize = imageBox.size;

    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        final Offset startPoint = Offset(line[i].dx * imageSize.width, line[i].dy * imageSize.height);
        final Offset endPoint = Offset(line[i + 1].dx * imageSize.width, line[i + 1].dy * imageSize.height);
        canvas.drawLine(startPoint, endPoint, paint);
        canvas.drawCircle(startPoint, 2.0, paint); // Draw start point
        canvas.drawCircle(endPoint, 2.0, paint); // Draw end point
      }
    }

    // Draw temporary line and point if applicable
    if (points.isNotEmpty && temporaryPoint != null) {
      final Offset startPoint = Offset(points.last.dx * imageSize.width, points.last.dy * imageSize.height);
      final Offset endPoint = Offset(temporaryPoint!.dx * imageSize.width, temporaryPoint!.dy * imageSize.height);
      canvas.drawLine(startPoint, endPoint, paint);
      canvas.drawCircle(startPoint, 2.0, paint); // Draw start point
      canvas.drawCircle(endPoint, 2.0, paint); // Temporary end point
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
