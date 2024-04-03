import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'project_data.dart';
import 'project_creation_step2_2.dart'; // Make sure to import ProjectCreationStep2_2

class ProjectCreationStep2 extends StatefulWidget {
  final Project project;
  final Function(Project project) onNext;

  const ProjectCreationStep2({
    super.key,
    required this.project,
    required this.onNext,
  });

  @override
  _ProjectCreationStep2State createState() => _ProjectCreationStep2State();
}

class _ProjectCreationStep2State extends State<ProjectCreationStep2> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        widget.project.imagePath = pickedFile.path; // 프로젝트 객체에 이미지 경로 저장
      });
    }
  }

  void _navigateToImageProcessingStep() {
    if (_selectedImage != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProjectCreationStep2_2(
          project: widget.project,
          imagePath: _selectedImage!.path, // 수정: imagePath 전달
          onComplete: () {
            // 이미지 처리 완료 후의 로직
            widget.onNext(widget.project);
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select an Image')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedImage != null)
            Image.file(File(_selectedImage!.path)),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick an Image from Gallery'),
          ),
          ElevatedButton(
            onPressed: _navigateToImageProcessingStep,
            child: Text('Process Image'),
          ),
        ],
      ),
    );
  }
}
