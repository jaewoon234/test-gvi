import 'package:flutter/foundation.dart';

class Project {
  final String id;
  String name;
  String? imagePath; // 업로드할 이미지의 경로
  DateTime creationDate;
  double? meanR; // RGB 평균값
  double? meanG;
  double? meanB;
  double? greenPixelCount; // 녹색 픽셀 수
  String? processedImageUrl; // 처리된 이미지의 URL

  Project({
    required this.id,
    required this.name,
    required this.creationDate,
    this.imagePath,
    this.meanR,
    this.meanG,
    this.meanB,
    this.greenPixelCount,
    this.processedImageUrl,
  });
}

class ProjectData with ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void editProjectName(int index, String newName) {
    if (index >= 0 && index < _projects.length) {
      _projects[index].name = newName;
      notifyListeners();
    }
  }

  void deleteProject(int index) {
    if (index >= 0 && index < _projects.length) {
      _projects.removeAt(index);
      notifyListeners();
    }
  }

  void updateProjectWithProcessingResults(String projectId, {double? meanR, double? meanG, double? meanB, double? greenPixelCount, String? processedImageUrl}) {
    var project = _projects.firstWhere((project) => project.id == projectId);
    project.meanR = meanR;
    project.meanG = meanG;
    project.meanB = meanB;
    project.greenPixelCount = greenPixelCount;
    project.processedImageUrl = processedImageUrl;
    notifyListeners();
  }

}
