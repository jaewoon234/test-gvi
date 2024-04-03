import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'project_data.dart';
import 'project_detail_page.dart';


class ProjectCreationStep2_2 extends StatefulWidget {
  final Project project;
  final String? imagePath; // 이미지 경로를 전달받을 변수 추가
  final Function onComplete;

  const ProjectCreationStep2_2({
    Key? key,
    required this.project,
    this.imagePath,
    required this.onComplete,
  }) : super(key: key);

  @override
  _ProjectCreationStep2_2State createState() => _ProjectCreationStep2_2State();
}

class _ProjectCreationStep2_2State extends State<ProjectCreationStep2_2> {
  String? _imageUrl;
  double? meanR, meanG, meanB;
  double? greenPixelCount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // imagePath가 null이 아닐 때만 이미지 처리 요청을 시작합니다.
    if (widget.imagePath != null) {
      uploadImage(widget.imagePath!);
    }
  }

  Future<void> uploadImage(String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    Uri uri = Uri.parse('http://192.0.0.2:5050/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await http.Response.fromStream(response);
      var data = jsonDecode(responseBody.body);
      setState(() {
        _isLoading = false;
        // _imageUrl = data['processed_image_url']; // 이전에 사용
        widget.project.processedImageUrl = data['processed_image_url'];
        widget.project.meanR = double.tryParse(data['mean_R'].toString());
        widget.project.meanG = double.tryParse(data['mean_G'].toString());
        widget.project.meanB = double.tryParse(data['mean_B'].toString());
        widget.project.greenPixelCount =
            double.tryParse(data['green_pixel_count'].toString());
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Server error: ${response.statusCode}');
    }
  }

  void _navigateToDetailPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProjectDetailPage(project: widget.project),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: _isLoading
                ? null
                : _navigateToDetailPage, // 로딩 중이면 버튼 비활성화
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 URL이 null이 아닐 경우 이미지를 표시하고, 그렇지 않으면 '이미지 없음' 메시지를 표시
            widget.project.processedImageUrl != null
                ? Image.network(widget.project.processedImageUrl!, height: 500, fit: BoxFit.cover)
                : Text('Processed image is not available'),
            SizedBox(height: 10), // 수치들 사이에 간격 추가
            Text('Mean R: ${widget.project.meanR?.toStringAsFixed(2) ?? 'N/A'}'),
            Text('Mean G: ${widget.project.meanG?.toStringAsFixed(2) ?? 'N/A'}'),
            Text('Mean B: ${widget.project.meanB?.toStringAsFixed(2) ?? 'N/A'}'),
            Text('Green Pixel Count: ${widget.project.greenPixelCount?.toString() ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
