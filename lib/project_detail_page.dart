import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'project_data.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pdfLib.Document();

    final font = await rootBundle.load("assets/fonts/Roboto-Black.ttf");
    final ttf = pdfLib.Font.ttf(font);

    pdf.addPage(
      pdfLib.Page(
        build: (pdfLib.Context context) {
          return pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
            children: <pdfLib.Widget>[
              pdfLib.Text(
                'Project ID: ${project.id}',
                style: pdfLib.TextStyle(fontSize: 18, font: ttf),
              ),
              pdfLib.SizedBox(height: 10),
              pdfLib.Text(
                'Mean R: ${project.meanR}',
                style: pdfLib.TextStyle(fontSize: 18, font: ttf),
              ),
              pdfLib.Text(
                'Mean G: ${project.meanG}',
                style: pdfLib.TextStyle(fontSize: 18, font: ttf),
              ),
              pdfLib.Text(
                'Mean B: ${project.meanB}',
                style: pdfLib.TextStyle(fontSize: 18, font: ttf),
              ),
              pdfLib.Text(
                'Green Pixel Count: ${project.greenPixelCount}',
                style: pdfLib.TextStyle(fontSize: 18, font: ttf),
              ),
              // Add original image
              if (project.imagePath != null)
                pdfLib.Image(pdfLib.MemoryImage(
                  File(project.imagePath!).readAsBytesSync(),
                )),
              pdfLib.SizedBox(height: 10),
              if (project.processedImageUrl != null)
                pdfLib.Image(pdfLib.MemoryImage(
                  File(project.processedImageUrl!).readAsBytesSync(),
                )),
              // Add other widgets here like additional images, processed data, etc.
            ],
          );
        },
      ),
    );

    final Directory directory = await getTemporaryDirectory();
    final String path = '${directory.path}/${project.name}_report.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text('PDF saved at: $path'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => _openPDF(context, path),
        ),
      ),
    );
  }


  Future<void> _openPDF(BuildContext context, String filePath) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(filePath: filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          actions: [
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () => _generatePDF(context),
            ),
          ],
        ),
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _projectName(),
              SizedBox(height: 3),
              _buildOriginalImageSection(),
              SizedBox(height: 3),
              _buildProcessedImageSection(),
              SizedBox(height: 3),
              _buildProcessedDataSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _projectName() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            child: Text(
              '${project.name}',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
            child: Text(
              'Creation Date: ${DateFormat.yMMMd().format(project.creationDate)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalImageSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(5.0, 3.0, 0.0, 0.0),
            child: const Text(
              "Original Image",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0),
            child: project.imagePath != null
                ? Image.file(File(project.imagePath!), height: 200, fit: BoxFit.cover)
                : Text('No image'),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedImageSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(5.0, 3.0, 0.0, 0.0),
            child: const Text(
              "Processed Image",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0),
            child: project.processedImageUrl != null
                ? Image.network(project.processedImageUrl!, height: 200, fit: BoxFit.cover)
                : Text('No image'),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedDataSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Mean R Values: ${project.meanR?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 3),
            Text(
              'Mean G Values: ${project.meanG?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 3),
            Text(
              'Mean B Values: ${project.meanB?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 3),
            Text(
              'Green Pixel Count: ${project.greenPixelCount?.toString() ?? 'N/A'}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String filePath;

  PDFViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
