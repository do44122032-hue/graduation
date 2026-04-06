import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/dashboard_service.dart';

class DoctorPatientDetailsPage extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String condition;
  final String patientId;

  const DoctorPatientDetailsPage({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.condition,
    required this.patientId,
  });

  @override
  State<DoctorPatientDetailsPage> createState() => _DoctorPatientDetailsPageState();
}

class _DoctorPatientDetailsPageState extends State<DoctorPatientDetailsPage> {
  XFile? _selectedFile;
  Uint8List? _webImage;
  bool _isUploading = false;
  bool _isPdf = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedFile = image;
            _webImage = bytes;
            _isPdf = false;
          });
        } else {
          setState(() {
            _selectedFile = image;
            _isPdf = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        
        setState(() {
          _selectedFile = XFile(path, name: name);
          _isPdf = true;
          _webImage = result.files.single.bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  Future<void> _uploadLabResult() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    try {
      // For now, we simulate the upload since the backend needs to be updated by the user
      // But we call a method in DashboardService that we will create
      final result = await DashboardService.uploadLabResult(
        uid: widget.patientId,
        imageFile: kIsWeb ? null : File(_selectedFile!.path),
        webBytes: _webImage,
        fileName: _selectedFile!.name,
      );

      final success = result['success'] as bool;
      final message = result['message'] as String;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) setState(() => _selectedFile = null);
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.patientName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.doctorPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            _buildInfoCard(languageCode),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Upload Section
            Text(
              'Upload Lab Result',
              style: AppTextStyles.h3(languageCode: languageCode).copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildUploadBox(languageCode),
            
            if (_selectedFile != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadLabResult,
                  icon: _isUploading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Processing OCR...' : 'Send to Smart Lab'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.doctorPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String languageCode) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.doctorPrimary.withOpacity(0.1),
            child: Text(
              widget.patientName[0],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.doctorPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.patientName,
                style: AppTextStyles.h3(
                  languageCode: languageCode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.patientAge} Years • ${widget.condition}',
                style: AppTextStyles.caption(
                  languageCode: languageCode,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(String languageCode) {
    return GestureDetector(
      onTap: () => _showPickOptions(),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.doctorPrimary.withOpacity(0.3)),
        ),
        child: _selectedFile != null
            ? (_isPdf 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _selectedFile!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _selectedFile = null),
                        child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.memory(_webImage!, fit: BoxFit.cover)
                        : Image.file(File(_selectedFile!.path), fit: BoxFit.cover),
                  ))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 50, color: AppColors.doctorPrimary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tap to take a photo or pick PDF',
                    style: AppTextStyles.body(
                      languageCode: languageCode,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF Document'),
              onTap: () {
                Navigator.pop(context);
                _pickPdf();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Simple DashStyle helper or replace with a proper package if desired
class DashStyle {
  final List<double> dash;
  const DashStyle({this.dash = const [5, 5]});
}



