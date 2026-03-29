import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../medical/doctor_schedule_management.dart';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final appointments = await DashboardService.fetchDoctorAppointments(user.id);
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load appointments')),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(String id, String newStatus) async {
    final success = newStatus == 'completed' || newStatus == 'confirmed'
        ? await DashboardService.confirmAppointment(id)
        : await DashboardService.cancelAppointment(id);

    if (success) {
      setState(() {
        final index = _appointments.indexWhere((a) => a['id'] == id);
        if (index != -1) {
          _appointments[index]['status'] = newStatus == 'completed' ? 'confirmed' : 'cancelled';
        }
      });

      final languageCode = Provider.of<LanguageService>(
        context,
        listen: false,
      ).currentLanguage;
      final message = newStatus == 'completed' || newStatus == 'confirmed'
          ? AppStrings.get('msgAppointmentConfirmed', languageCode)
          : AppStrings.get('msgAppointmentCancelled', languageCode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: newStatus == 'completed' || newStatus == 'confirmed'
              ? AppColors.doctorPrimary
              : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update appointment status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('doctorScheduleTitle', languageCode),
          style: AppTextStyles.h3(
            languageCode: languageCode,
          ).copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.doctorPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorScheduleManagementScreen(),
                ),
              ).then((_) => _loadAppointments());
            },
            tooltip: 'Manage Availability',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.doctorPrimary,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.doctorPrimary,
          tabs: [
            Tab(text: AppStrings.get('tabUpcoming', languageCode)),
            Tab(text: AppStrings.get('tabCompleted', languageCode)),
            Tab(text: AppStrings.get('tabCancelled', languageCode)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.doctorPrimary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(_appointments, 'scheduled', languageCode),
                _buildAppointmentList(_appointments, 'confirmed', languageCode),
                _buildAppointmentList(_appointments, 'cancelled', languageCode),
              ],
            ),
    );
  }

  Widget _buildAppointmentList(
    List<Map<String, dynamic>> allAppointments,
    String status,
    String languageCode,
  ) {
    final filtered = allAppointments
        .where((a) => a['status'] == status)
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.get('msgNoAppointments', languageCode),
              style: AppTextStyles.body(
                languageCode: languageCode,
              ).copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        100,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final apt = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            border: Border(
              left: BorderSide(color: AppColors.doctorPrimary, width: 4),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${apt['time']}',
                      style: AppTextStyles.h3(languageCode: languageCode)
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.doctorPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXS,
                        ),
                      ),
                      child: Text(
                        apt['type'] ?? 'Visit',
                        style: AppTextStyles.caption(languageCode: languageCode)
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.doctorPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondaryBackground,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apt['patientName'] ?? 'Unknown Patient',
                            style:
                                AppTextStyles.body(
                                  languageCode: languageCode,
                                ).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                          ),
                          Text(
                            '${apt['date']} at ${apt['time']}',
                            style: AppTextStyles.caption(
                              languageCode: languageCode,
                            ).copyWith(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    if (status == 'scheduled' && (apt['type'] ?? '').toString().toLowerCase().contains('video'))
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.videocam,
                          size: AppSpacing.iconXS,
                        ),
                        label: Text(
                          AppStrings.get('actionJoin', languageCode),
                          style: AppTextStyles.buttonSmall(
                            languageCode: languageCode,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.doctorPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                      ),
                  ],
                ),
                if (status == 'scheduled') ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _updateAppointmentStatus(apt['id'], 'cancelled'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                          ),
                          child: Text(
                            AppStrings.get('actionCancel', languageCode),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateAppointmentStatus(apt['id'], 'completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.doctorPrimary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            AppStrings.get('actionConfirm', languageCode),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
