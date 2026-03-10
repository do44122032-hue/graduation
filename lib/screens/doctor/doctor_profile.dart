import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class DoctorProfilePage extends StatefulWidget {
  final UserModel? user;

  const DoctorProfilePage({super.key, this.user});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  bool _isEditing = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _specController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    _nameController = TextEditingController(
      text: widget.user?.name ?? 'Dr. Jaimin Panchal',
    );
    _phoneController = TextEditingController(
      text:
          widget.user?.phoneNumber ??
          AppStrings.get('labelNotSet', languageCode),
    );
    _dobController = TextEditingController(
      text:
          widget.user?.dateOfBirth ??
          AppStrings.get('labelNotSet', languageCode),
    );
    _specController = TextEditingController(
      text: AppStrings.get('specCardiology', languageCode),
    );
    _locationController = TextEditingController(
      text: AppStrings.get('locNewYork', languageCode),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _specController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('doctorProfileTitle', languageCode),
          style: AppTextStyles.h3(
            languageCode: languageCode,
          ).copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.doctorPrimary),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.get('msgProfileUpdated', languageCode),
                    ),
                    backgroundColor: AppColors.doctorPrimary,
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.doctorSecondary.withValues(
                      alpha: 0.2,
                    ),
                    backgroundImage: widget.user?.profilePicture != null
                        ? NetworkImage(widget.user!.profilePicture!)
                        : null,
                    child: widget.user?.profilePicture == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.doctorPrimary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.doctorPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isEditing ? Icons.close : Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_isEditing)
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2(languageCode: languageCode).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              )
            else
              Text(
                _nameController.text,
                style: AppTextStyles.h2(languageCode: languageCode).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            Text(
              widget.user?.email ?? 'jaimin.panchal@gmail.com',
              style: AppTextStyles.body(
                languageCode: languageCode,
              ).copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildProfileItem(
              Icons.phone,
              AppStrings.get('labelPhone', languageCode),
              _phoneController,
              languageCode,
            ),
            _buildProfileItem(
              Icons.calendar_today,
              AppStrings.get('labelDOB', languageCode),
              _dobController,
              languageCode,
            ),
            _buildProfileItem(
              Icons.local_hospital,
              AppStrings.get('labelSpecialization', languageCode),
              _specController,
              languageCode,
            ),
            _buildProfileItem(
              Icons.location_on,
              AppStrings.get('labelLocation', languageCode),
              _locationController,
              languageCode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String label,
    TextEditingController controller,
    String languageCode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.doctorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Icon(icon, color: AppColors.doctorPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption(
                    languageCode: languageCode,
                  ).copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 4),
                if (_isEditing)
                  TextField(
                    controller: controller,
                    style: AppTextStyles.body(languageCode: languageCode)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  )
                else
                  Text(
                    controller.text,
                    style: AppTextStyles.body(languageCode: languageCode)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
