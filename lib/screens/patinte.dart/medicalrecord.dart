import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/api_config.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/auth_service.dart';
import 'package:graduation_project/models/medical_models.dart';
import 'patient_data_entry.dart';



// Main Widget
class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  String _activeTab = 'vitals';
  String _activeNav = 'records';
  bool _isLoading = true;
  List<int> _expandedItems = [];
  List<VitalSignRecord> _apiVitals = [];
  List<ChronicCondition> _apiConditions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null || user.id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // 1. Load from local cache for instant display
    final localVital = await DashboardService.getLocalVital();
    if (localVital != null && mounted) {
      final localRecord = VitalSignRecord(
        date: localVital['date'] ?? 'Just Now',
        bloodPressureSys: localVital['bloodPressureSys'] ?? 0,
        bloodPressureDia: localVital['bloodPressureDia'] ?? 0,
        heartRate: localVital['heartRate'] ?? 0,
        temperature: (localVital['temperature'] as num?)?.toDouble() ?? 37.0,
        respiratoryRate: 16,
        oxygenSaturation: 98,
        weight: localVital['weight'] ?? 0,
        bmi: 22.0,
        bloodGlucose: 100,
      );
      setState(() {
        if (_apiVitals.isEmpty) _apiVitals = [localRecord];
        _isLoading = false; 
      });
    }

    try {
      print('DEBUG: Fetching dashboard for user: ${user.id}');
      final data = await DashboardService.fetchPatientDashboard(user.id!);
      print('DEBUG: Dashboard Success: ${data['success']}');
      if (data['success'] == true && mounted) {
        print('DEBUG: Recent Vitals Count: ${data['recentVitals']?.length}');
        setState(() {
          // Map Vitals
          if (data['recentVitals'] != null) {
            _apiVitals = (data['recentVitals'] as List).map((v) {
              return VitalSignRecord(
                date: v['date']?.toString() ?? '',
                bloodPressureSys: (v['bloodPressureSys'] as num?)?.toInt() ?? 0,
                bloodPressureDia: (v['bloodPressureDia'] as num?)?.toInt() ?? 0,
                heartRate: (v['heartRate'] as num?)?.toInt() ?? 0,
                temperature: (v['temperature'] as num?)?.toDouble() ?? 0.0,
                respiratoryRate: (v['respiratoryRate'] as num?)?.toInt() ?? 0,
                oxygenSaturation: (v['oxygenSaturation'] as num?)?.toInt() ?? 0,
                weight: (v['weight'] as num?)?.toInt() ?? 0,
                bmi: (v['bmi'] as num?)?.toDouble() ?? 0.0,
                bloodGlucose: (v['bloodGlucose'] as num?)?.toInt() ?? 0,
              );
            }).toList();
            
            // Sort by date newest first to ensure the latest is at index 0
            _apiVitals.sort((a, b) {
              try {
                DateTime da = _parseDateString(a.date);
                DateTime db = _parseDateString(b.date);
                return db.compareTo(da);
              } catch(e) { 
                print('DEBUG: Sorting fail for ${a.date} vs ${b.date}: $e');
                return 0; 
              }
            });
            print('DEBUG: Processed and sorted ${_apiVitals.length} vitals');
          }

          // Map Chronic Conditions from User Model if available
          if (user.chronicConditions != null) {
            _apiConditions = (user.chronicConditions as List).asMap().entries.map((entry) => ChronicCondition(
              id: entry.key,
              diseaseName: entry.value,
              icdCode: 'N/A',
              diagnosedDate: 'Ongoing',
              currentStatus: 'active',
              severityLevel: 'moderate',
              treatingPhysician: 'Assigned Doctor',
              lastUpdated: 'Recently',
              managementPlan: 'Follow medical advice',
            )).toList();
          }
          
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching medical records data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Helper to parse various date formats safely
  DateTime _parseDateString(String dateStr) {
    if (dateStr.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    
    // List of formats to try
    final formats = [
      'MMM d yyyy',           // Mar 29 2026
      'MMM dd yyyy',          // Mar 29 2026 (two digit)
      'yyyy-MM-ddTHH:mm:ss',  // ISO
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
    ];

    String cleanDate = dateStr.trim();
    // Special case for our app which sometimes misses the year in manually entered dates
    if (!cleanDate.contains(RegExp(r'\d{4}'))) {
      cleanDate = "$cleanDate ${DateTime.now().year}";
    }

    for (var format in formats) {
      try {
        return DateFormat(format).parse(cleanDate);
      } catch (_) {
        continue;
      }
    }

    // Fallback: try native DateTime.parse for ISO formats it knows
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('CRITICAL: Failed to parse date string "$dateStr": $e');
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  // Color Constants
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorSecondaryBg = Color(0xFFF7F7F7);
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorSecondaryText = Color(0xFF4A4A4A);
  static const Color colorAccentOlive = Color(0xFFCBD77E);
  static const Color colorAccentBeige = Color(0xFFE6CA9A);

  // Mock Data
  final PatientInfo patientInfo = PatientInfo(
    name: 'Sarah Johnson',
    age: 32,
    bloodType: 'A+',
    height: '5\'6"',
    weight: '140 lbs',
    mrn: 'MRN-2024-8956',
    dob: 'March 15, 1992',
  );

  final List<ChronicCondition> chronicConditions = [
    ChronicCondition(
      id: 1,
      diseaseName: 'Hypertension (Essential)',
      icdCode: 'I10',
      diagnosedDate: 'Jan 15, 2023',
      currentStatus: 'controlled',
      severityLevel: 'moderate',
      treatingPhysician: 'Dr. Michael Chen, MD',
      lastUpdated: 'Dec 20, 2024',
      managementPlan:
          'Lisinopril 10mg daily, low-sodium diet, regular BP monitoring, cardiology follow-up every 6 months',
    ),
    ChronicCondition(
      id: 2,
      diseaseName: 'Vitamin D Deficiency',
      icdCode: 'E55.9',
      diagnosedDate: 'Nov 28, 2024',
      currentStatus: 'active',
      severityLevel: 'mild',
      treatingPhysician: 'Dr. Michael Chen, MD',
      lastUpdated: 'Dec 01, 2024',
      managementPlan:
          'Vitamin D3 2000 IU daily, recheck levels in 3 months, increase sun exposure',
    ),
    ChronicCondition(
      id: 3,
      diseaseName: 'Acute Bronchitis',
      icdCode: 'J20.9',
      diagnosedDate: 'Nov 10, 2024',
      currentStatus: 'resolved',
      severityLevel: 'mild',
      treatingPhysician: 'Dr. Emily Rodriguez, MD',
      lastUpdated: 'Nov 25, 2024',
      managementPlan: 'Course completed - antibiotics, rest, hydration',
    ),
  ];



  // Mock Data - DELETED to ensure only real data is shown
  final List<VitalSignRecord> vitalSignsHistory = [];

  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }



  Map<String, Color> _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return {
          'bg': const Color(0xFFFFF3E0),
          'border': const Color(0xFFFFB74D),
          'text': const Color(0xFFE65100),
        };
      case 'controlled':
        return {
          'bg': const Color(0xFFE8F5E9),
          'border': const Color(0xFF81C784),
          'text': const Color(0xFF2E7D32),
        };
      case 'in-remission':
        return {
          'bg': const Color(0xFFE1F5FE),
          'border': const Color(0xFF4FC3F7),
          'text': const Color(0xFF0277BD),
        };
      case 'resolved':
        return {
          'bg': const Color(0xFFF3E5F5),
          'border': const Color(0xFFBA68C8),
          'text': const Color(0xFF6A1B9A),
        };
      default:
        return {
          'bg': colorSecondaryBg,
          'border': colorAccentBeige,
          'text': colorSecondaryText,
        };
    }
  }

  Map<String, Color> _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return {
          'bg': const Color(0xFFFFF9C4),
          'border': const Color(0xFFFDD835),
          'text': const Color(0xFFF57F17),
        };
      case 'moderate':
        return {
          'bg': const Color(0xFFFFE0B2),
          'border': const Color(0xFFFB8C00),
          'text': const Color(0xFFE65100),
        };
      case 'severe':
        return {
          'bg': const Color(0xFFFFCCBC),
          'border': const Color(0xFFFF5722),
          'text': const Color(0xFFBF360C),
        };
      default:
        return {
          'bg': colorSecondaryBg,
          'border': colorAccentBeige,
          'text': colorSecondaryText,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: colorSecondaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(languageCode),

            // Tabs
            _buildTabs(languageCode),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: 88,
                ),
                child: _buildContent(languageCode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String languageCode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorAccentOlive, colorAccentBeige],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 20, color: colorCharcoal),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          Text(
            AppStrings.get('medicalRecords', languageCode),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorCharcoal,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, size: 22, color: colorCharcoal),
              onPressed: _fetchData,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_note, size: 22, color: colorCharcoal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientDataEntryPage(),
                  ),
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTabs(String languageCode) {
    final tabs = [
      {'id': 'overview', 'label': AppStrings.get('tabOverview', languageCode)},
      {'id': 'vitals', 'label': AppStrings.get('tabVitals', languageCode)},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 0, 12),
      decoration: const BoxDecoration(
        color: colorWhite,
        border: Border(bottom: BorderSide(color: colorSecondaryBg)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isActive = _activeTab == tab['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = tab['id']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorAccentOlive.withOpacity(0.2)
                        : colorWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? colorAccentOlive
                          : colorAccentBeige.withOpacity(0.4),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    tab['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? colorAccentOlive : colorSecondaryText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(String languageCode) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: colorAccentOlive),
        ),
      );
    }
    
    switch (_activeTab) {
      case 'overview':
        return _buildOverviewTab(languageCode);
      case 'vitals':
        return _buildVitalsTab(languageCode);
      default:
        return _buildOverviewTab(languageCode);
    }
  }

  Widget _buildOverviewTab(String languageCode) {
    final latestVital = _apiVitals.isNotEmpty ? _apiVitals.first : null;
    final activeConditions = _apiConditions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Vitals
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get('tabVitals', languageCode),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorCharcoal,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _activeTab = 'vitals'),
              child: Text(
                AppStrings.get('viewDetails', languageCode),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorAccentOlive,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (latestVital != null)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildVitalCard(
                Icons.favorite,
                AppStrings.get('labelHeartRate', languageCode),
                latestVital.heartRate.toString(),
                AppStrings.get('unitBpm', languageCode),
                onTap: () => _showQuickAddVitalsSheet(context, languageCode),
              ),
              _buildVitalCard(
                Icons.timeline,
                AppStrings.get('labelBloodPressure', languageCode),
                '${latestVital.bloodPressureSys}/${latestVital.bloodPressureDia}',
                AppStrings.get('unitMmHg', languageCode),
                onTap: () => _showQuickAddVitalsSheet(context, languageCode),
              ),
              _buildVitalCard(
                Icons.monitor_weight,
                AppStrings.get('labelWeight', languageCode),
                latestVital.weight.toString(),
                AppStrings.get('unitLbs', languageCode),
                onTap: () => _showQuickAddVitalsSheet(context, languageCode),
              ),
              _buildVitalCard(
                Icons.water_drop,
                AppStrings.get('labelBloodGlucose', languageCode),
                latestVital.bloodGlucose.toString(),
                AppStrings.get('unitMgDl', languageCode),
                onTap: () => _showQuickAddVitalsSheet(context, languageCode),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // Quick Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.personal_injury,
                value: activeConditions.toString(),
                label: AppStrings.get('sectChronicConditions', languageCode),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCBD77E), Color(0xFFB8C96E)],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox.shrink()), // Keep balance or remove if needed
          ],
        ),
        const SizedBox(height: 24),

        // No recent activity for now as we removed visits
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVitalCard(
    IconData icon,
    String label,
    String value,
    String unit, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorSecondaryBg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: colorAccentOlive),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: colorSecondaryText,
                  ),
                ),
              ],
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorCharcoal,
                ),
                children: [
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: colorWhite),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: colorWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: colorWhite.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsTab(String languageCode) {
    final conditionsToShow = _apiConditions.isNotEmpty ? _apiConditions : chronicConditions;
    return Column(
      children: conditionsToShow.map((condition) {
        final isExpanded = _expandedItems.contains(condition.id);
        final statusColors = _getStatusColor(condition.currentStatus);
        final severityColors = _getSeverityColor(condition.severityLevel);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorSecondaryBg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _toggleExpanded(condition.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    condition.diseaseName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colorCharcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ICD-10: ${condition.icdCode} • ${AppStrings.get('labelDiagnosedDate', languageCode)}: ${condition.diagnosedDate}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: colorSecondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      _buildBadge(
                                        condition.currentStatus.replaceAll(
                                          '-',
                                          ' ',
                                        ),
                                        statusColors['bg']!,
                                        statusColors['border']!,
                                        statusColors['text']!,
                                      ),
                                      _buildBadge(
                                        condition.severityLevel,
                                        severityColors['bg']!,
                                        severityColors['border']!,
                                        severityColors['text']!,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: isExpanded
                                  ? colorAccentOlive
                                  : colorSecondaryText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorSecondaryBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          AppStrings.get('treatingPhysician', languageCode),
                          condition.treatingPhysician,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('managementPlan', languageCode),
                          condition.managementPlan,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('lastUpdated', languageCode),
                          condition.lastUpdated,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }



  Widget _buildVitalsTab(String languageCode) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: () => _showQuickAddVitalsSheet(context, languageCode),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAccentOlive,
              foregroundColor: colorCharcoal,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_chart, size: 20),
            label: Text(
              AppStrings.get('quickAddVitals', languageCode),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_apiVitals.isNotEmpty) _buildMedicalHealthAlerts(languageCode),
        _buildVitalChartCard(
          AppStrings.get('labelBPTrend', languageCode),
          _buildBloodPressureChart(),
        ),
        const SizedBox(height: 16),
        _buildVitalChartCard(
          AppStrings.get('labelHRTrend', languageCode),
          _buildHeartRateChart(),
        ),
        const SizedBox(height: 16),
        _buildVitalChartCard(
          AppStrings.get('labelWeightTrend', languageCode),
          _buildWeightChart(),
        ),
        const SizedBox(height: 16),
        _buildVitalChartCard(
          AppStrings.get('labelBGTrend', languageCode),
          _buildBloodGlucoseChart(),
        ),
        const SizedBox(height: 24),
        _buildVitalsHistory(languageCode),
      ],
    );
  }

  Widget _buildVitalsHistory(String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent History', // Fixed string for now, can be localized later
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorCharcoal,
              ),
            ),
            if (_apiVitals.isEmpty)
              Text(
                '(Showing Mock Data)', 
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_apiVitals.isEmpty && vitalSignsHistory.isNotEmpty)
          ...vitalSignsHistory.take(3).map((v) => _buildVitalHistoryItem(v, languageCode, isMock: true))
        else if (_apiVitals.isNotEmpty)
          ..._apiVitals.map((v) => _buildVitalHistoryItem(v, languageCode))
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('No vitals recorded yet.')),
          ),
      ],
    );
  }

  Widget _buildVitalHistoryItem(VitalSignRecord v, String languageCode, {bool isMock = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMock ? Colors.grey.shade50 : colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMock ? Colors.grey.shade200 : colorSecondaryBg),
        boxShadow: isMock ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                v.date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorCharcoal,
                ),
              ),
              if (isMock)
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleVitalStat('BP', '${v.bloodPressureSys}/${v.bloodPressureDia}'),
              _buildSimpleVitalStat('HR', '${v.heartRate} bpm'),
              _buildSimpleVitalStat('Weight', '${v.weight} lbs'),
              _buildSimpleVitalStat('Glucose', '${v.bloodGlucose}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleVitalStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: colorSecondaryText),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorCharcoal,
          ),
        ),
      ],
    );
  }

  void _showQuickAddVitalsSheet(BuildContext context, String languageCode) {
    final sysController = TextEditingController();
    final diaController = TextEditingController();
    final hrController = TextEditingController();
    final weightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('quickAddVitals', languageCode),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorCharcoal,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleInput(
                      label: AppStrings.get('labelSystolic', languageCode),
                      controller: sysController,
                      suffix: AppStrings.get('unitMmHg', languageCode),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleInput(
                      label: AppStrings.get('labelDiastolic', languageCode),
                      controller: diaController,
                      suffix: AppStrings.get('unitMmHg', languageCode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSimpleInput(
                label: AppStrings.get('labelHeartRate', languageCode),
                controller: hrController,
                suffix: AppStrings.get('unitBpm', languageCode),
              ),
              const SizedBox(height: 16),
              _buildSimpleInput(
                label: AppStrings.get('labelWeight', languageCode),
                controller: weightController,
                suffix: AppStrings.get('unitLbs', languageCode),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final user = authService.currentUser;
                  if (user == null || user.id == null || user.id!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found. Cannot save vitals.')),
                    );
                    return;
                  }

                  final sys = int.tryParse(sysController.text) ?? 120;
                  final dia = int.tryParse(diaController.text) ?? 80;
                  final hr = int.tryParse(hrController.text) ?? 72;
                  final weight = int.tryParse(weightController.text) ?? 140;

                  Navigator.pop(context); // Close sheet

                  final result = await DashboardService.logVitals(
                    uid: user.id!,
                    sys: sys,
                    dia: dia,
                    hr: hr,
                    temp: 37.0,
                    rr: 16,
                    o2: 98,
                    weight: weight,
                    bmi: 22.0,
                    glucose: 95,
                  );

                  if (result['success']) {
                    // Update locally first for instant feedback (Optimistic UI)
                    final newVitalRecord = VitalSignRecord(
                      date: DateFormat('MMM d yyyy').format(DateTime.now()),
                      bloodPressureSys: sys,
                      bloodPressureDia: dia,
                      heartRate: hr,
                      temperature: 37.0,
                      respiratoryRate: 16,
                      oxygenSaturation: 98,
                      weight: weight,
                      bmi: 22.0,
                      bloodGlucose: 100,
                    );
                    
                    if (mounted) {
                      setState(() {
                        _apiVitals.insert(0, newVitalRecord);
                      });
                    }

                    await _fetchData(); // Sync with server in background
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.get('msgSuccess', languageCode)),
                          backgroundColor: colorAccentOlive,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Save Error (Diagnostic)'),
                          content: SingleChildScrollView(
                            child: Text('Message: ${result['message']}\n\nUID used: ${user.id}\nBaseURL: ${ApiConfig.baseUrl}'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorCharcoal,
                  foregroundColor: colorWhite,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppStrings.get('save', languageCode),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleInput({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: colorSecondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: colorSecondaryBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: colorSecondaryText,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalChartCard(String title, Widget chart) {
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorSecondaryBg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  String _formatDateToWeekday(String dateStr) {
    try {
      DateTime parsed = _parseDateString(dateStr);
      return DateFormat('E').format(parsed);
    } catch (e) {
      return dateStr;
    }
  }

  List<VitalSignRecord> get _chartVitals {
    // Only use real data from API. Take the 7 most recent and show them chronologically.
    final List<VitalSignRecord> sorted = List.from(_apiVitals);
    // Ensure they are sorted newest first if not already
    sorted.sort((a, b) => _parseDateString(b.date).compareTo(_parseDateString(a.date)));
    
    return sorted.take(7).toList().reversed.toList();
  }


  Widget _buildBloodPressureChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colorSecondaryBg, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: colorSecondaryText),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _chartVitals.length) {
                  return Text(
                    _formatDateToWeekday(_chartVitals[value.toInt()].date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: colorSecondaryText,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 40,
        maxY: 180,
        lineBarsData: [
          LineChartBarData(
            spots: _chartVitals
                .asMap()
                .entries
                .map((e) {
                  return FlSpot(
                    e.key.toDouble(),
                    e.value.bloodPressureSys.toDouble(),
                  );
                })
                .toList(),
            isCurved: true,
            color: colorAccentOlive,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: _chartVitals
                .asMap()
                .entries
                .map((e) {
                  return FlSpot(
                    e.key.toDouble(),
                    e.value.bloodPressureDia.toDouble(),
                  );
                })
                .toList(),
            isCurved: true,
            color: colorAccentBeige,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colorSecondaryBg, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: colorSecondaryText),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final chronologicalVitals = _chartVitals;
                if (value.toInt() >= 0 &&
                    value.toInt() < chronologicalVitals.length) {
                  return Text(
                    _formatDateToWeekday(chronologicalVitals[value.toInt()].date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: colorSecondaryText,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 40,
        maxY: 120,
        lineBarsData: [
          LineChartBarData(
            spots: _chartVitals
                .asMap()
                .entries
                .map((e) {
                  return FlSpot(e.key.toDouble(), e.value.heartRate.toDouble());
                })
                .toList(),
            isCurved: true,
            color: colorAccentOlive,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colorSecondaryBg, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: colorSecondaryText),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final chronologicalVitals = _chartVitals;
                if (value.toInt() >= 0 &&
                    value.toInt() < chronologicalVitals.length) {
                  return Text(
                    _formatDateToWeekday(chronologicalVitals[value.toInt()].date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: colorSecondaryText,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        // Auto-scaling enabled by leaving minY/maxY null
        barGroups: _chartVitals
            .asMap()
            .entries
            .map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.weight.toDouble(),
                    color: colorAccentBeige,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ],
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildBloodGlucoseChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colorSecondaryBg, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: colorSecondaryText),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final chronologicalVitals = _chartVitals;
                if (value.toInt() >= 0 &&
                    value.toInt() < chronologicalVitals.length) {
                  return Text(
                    _formatDateToWeekday(chronologicalVitals[value.toInt()].date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: colorSecondaryText,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        // Auto-scaling enabled
        lineBarsData: [
          LineChartBarData(
            spots: _chartVitals
                .asMap()
                .entries
                .map((e) {
                  return FlSpot(
                    e.key.toDouble(),
                    e.value.bloodGlucose.toDouble(),
                  );
                })
                .toList(),
            isCurved: true,
            color: colorAccentOlive,
            barWidth: 2,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color border, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMedicalHealthAlerts(String languageCode) {
    if (_apiVitals.isEmpty) return const SizedBox.shrink();
    
    // After sorting in _fetchData, the first record is the latest
    final latest = _apiVitals.first;
    if (latest.bloodPressureSys > 130 || latest.bloodPressureDia > 85) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'High Blood Pressure Alert',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your last reading was ${latest.bloodPressureSys}/${latest.bloodPressureDia}. Please monitor closely.',
                    style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: colorSecondaryText),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.w500,
            color: valueColor ?? colorCharcoal,
          ),
        ),
      ],
    );
  }

}
