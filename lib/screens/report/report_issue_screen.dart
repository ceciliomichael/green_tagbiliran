import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../services/auth_service.dart';
import '../../services/reports_service.dart';
import '../../widgets/feature/report_form_field.dart';
import '../../widgets/feature/report_barangay_selector.dart';
import '../../widgets/feature/report_image_attachment.dart';
import '../../widgets/ui/sample_image_dialog.dart';
import '../../widgets/ui/barangay_selector_sheet.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _issueController = TextEditingController();
  final _authService = AuthService();
  final _reportsService = ReportsService();

  String _selectedBarangay = '';
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  static const int maxImages = 3;

  final List<String> _barangays = [
    'Bool',
    'Booy',
    'Cabawan',
    'Cogon',
    'Dampas',
    'Dao',
    'Manga',
    'Mansasa',
    'Poblacion I',
    'Poblacion II',
    'Poblacion III',
    'San Isidro',
    'Taloto',
    'Tiptip',
    'Ubujan',
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _fullNameController.text = currentUser.fullName;
      _phoneController.text = currentUser.phone.replaceFirst('+63', '');
      _selectedBarangay = currentUser.barangay;
    } else {
      _selectedBarangay = 'Poblacion I';
    }
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= maxImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum $maxImages photos allowed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showSampleImage() {
    showDialog(
      context: context,
      builder: (context) => const SampleImageDialog(),
    );
  }

  void _showBarangaySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BarangaySelectorSheet(
        selectedBarangay: _selectedBarangay,
        barangays: _barangays,
        onBarangaySelected: (barangay) {
          setState(() {
            _selectedBarangay = barangay;
          });
        },
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to submit a report'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _reportsService.submitReport(
        user: currentUser,
        fullName: _fullNameController.text.trim(),
        phone: '+63${_phoneController.text.trim()}',
        barangay: _selectedBarangay,
        issueDescription: _issueController.text.trim(),
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Report submitted successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        _fullNameController.clear();
        _phoneController.clear();
        _issueController.clear();
        setState(() {
          _selectedImages.clear();
        });

        Navigator.pushNamed(context, AppRoutes.issueStatus);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to submit report'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Report Issue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please fill in the details below to report an issue.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ReportFormField(
                label: 'Full Name',
                controller: _fullNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              ReportFormField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixText: '+63 ',
                prefixIcon: Icons.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              ReportBarangaySelector(
                selectedBarangay: _selectedBarangay,
                userBarangay: _authService.currentUser?.barangay,
                onTap: _showBarangaySelector,
              ),
              ReportFormField(
                label: 'Describe the Issue',
                controller: _issueController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the issue';
                  }
                  if (value.length < 10) {
                    return 'Please provide a more detailed description';
                  }
                  return null;
                },
              ),
              ReportImageAttachment(
                selectedImages: _selectedImages,
                maxImages: maxImages,
                onPickImage: _pickImage,
                onRemoveImage: _removeImage,
                onShowSample: _showSampleImage,
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 20),
              _buildCheckStatusButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Submit Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildCheckStatusButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.issueStatus);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Check Report Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

