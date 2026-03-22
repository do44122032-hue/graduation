import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/auth_service.dart';
import 'patient_data_entry.dart';

// Data Models
class ChronicCondition {
  final int id;
  final String diseaseName;
  final String icdCode;
  final String diagnosedDate;
  final String
  currentStatus; // 'active', 'controlled', 'in-remission', 'resolved'
  final String severityLevel; // 'mild', 'moderate', 'severe'
  final String treatingPhysician;
  final String lastUpdated;
  final String managementPlan;

  ChronicCondition({
    required this.id,
    required this.diseaseName,
    required this.icdCode,
    required this.diagnosedDate,
    required this.currentStatus,
    required this.severityLevel,
    required this.treatingPhysician,
    required this.lastUpdated,
    required this.managementPlan,
  });
}

class CurrentMedication {
  final int id;
  final String genericName;
  final String brandName;
  final String strength;
  final String form;
  final String route;
  final String frequency;
  final String prescribingPhysician;
  final String startDate;
  final String reasonForMedication;
  final String specialInstructions;
  final String pharmacy;
  final String lastFillDate;
  final String nextRefillDate;
  final int quantityRemaining;
  final String priorAuthStatus;

  CurrentMedication({
    required this.id,
    required this.genericName,
    required this.brandName,
    required this.strength,
    required this.form,
    required this.route,
    required this.frequency,
    required this.prescribingPhysician,
    required this.startDate,
    required this.reasonForMedication,
    required this.specialInstructions,
    required this.pharmacy,
    required this.lastFillDate,
    required this.nextRefillDate,
    required this.quantityRemaining,
    required this.priorAuthStatus,
  });
}

class VitalSignRecord {
  final String date;
  final int bloodPressureSys;
  final int bloodPressureDia;
  final int heartRate;
  final double temperature;
  final int respiratoryRate;
  final int oxygenSaturation;
  final int weight;
  final double bmi;
  final int bloodGlucose;

  VitalSignRecord({
    required this.date,
    required this.bloodPressureSys,
    required this.bloodPressureDia,
    required this.heartRate,
    required this.temperature,
    required this.respiratoryRate,
    required this.oxygenSaturation,
    required this.weight,
    required this.bmi,
    required this.bloodGlucose,
  });
}

class VisitEncounter {
  final int id;
  final String dateTime;
  final String visitType;
  final String providerName;
  final String specialty;
  final String department;
  final String chiefComplaint;
  final String symptomsDuration;
  final String assessment;
  final String treatmentPlan;
  final List<String> proceduresPerformed;
  final String followUpInstructions;
  final String? nextAppointmentDate;

  VisitEncounter({
    required this.id,
    required this.dateTime,
    required this.visitType,
    required this.providerName,
    required this.specialty,
    required this.department,
    required this.chiefComplaint,
    required this.symptomsDuration,
    required this.assessment,
    required this.treatmentPlan,
    required this.proceduresPerformed,
    required this.followUpInstructions,
    this.nextAppointmentDate,
  });
}

class PatientInfo {
  final String name;
  final int age;
  final String bloodType;
  final String height;
  final String weight;
  final String mrn;
  final String dob;

  PatientInfo({
    required this.name,
    required this.age,
    required this.bloodType,
    required this.height,
    required this.weight,
    required this.mrn,
    required this.dob,
  });
}

// Main Widget
class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  String _activeTab = 'vitals';
  String _activeNav = 'records';
  String _searchQuery = '';
  bool _showFilters = false;
  List<int> _expandedItems = [];
  bool _isLoading = true;
  
  List<VitalSignRecord> _apiVitals = [];
  List<CurrentMedication> _apiMedications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null || user.id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await DashboardService.fetchPatientDashboard(user.id!);
      if (data['success'] == true && mounted) {
        setState(() {
          // Map Vitals
          if (data['recentVitals'] != null) {
            _apiVitals = (data['recentVitals'] as List).map((v) => VitalSignRecord(
              date: v['date']?.toString() ?? '',
              bloodPressureSys: v['bloodPressureSys'] ?? 0,
              bloodPressureDia: v['bloodPressureDia'] ?? 0,
              heartRate: v['heartRate'] ?? 0,
              temperature: (v['temperature'] ?? 0).toDouble(),
              respiratoryRate: v['respiratoryRate'] ?? 0,
              oxygenSaturation: v['oxygenSaturation'] ?? 0,
              weight: v['weight'] ?? 0,
              bmi: (v['bmi'] ?? 0).toDouble(),
              bloodGlucose: v['bloodGlucose'] ?? 0,
            )).toList();
          }
          
          // Map Medications
          if (data['activeMedications'] != null) {
            _apiMedications = (data['activeMedications'] as List).map((m) => CurrentMedication(
              id: m['id'] ?? 0,
              genericName: m['genericName']?.toString() ?? '',
              brandName: m['brandName']?.toString() ?? '',
              strength: m['strength']?.toString() ?? '',
              form: m['form']?.toString() ?? '',
              route: m['route']?.toString() ?? '',
              frequency: m['frequency']?.toString() ?? '',
              prescribingPhysician: m['prescribingPhysician']?.toString() ?? '',
              startDate: m['startDate']?.toString() ?? '',
              reasonForMedication: m['reasonForMedication']?.toString() ?? '',
              specialInstructions: m['specialInstructions']?.toString() ?? '',
              pharmacy: '', // Not in API yet
              lastFillDate: '',
              nextRefillDate: '',
              quantityRemaining: 0,
              priorAuthStatus: '',
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

  final List<CurrentMedication> currentMedications = [
    CurrentMedication(
      id: 1,
      genericName: 'Lisinopril',
      brandName: 'Prinivil, Zestril',
      strength: '10mg',
      form: 'Tablet',
      route: 'Oral',
      frequency: 'Once daily (morning)',
      prescribingPhysician: 'Dr. Michael Chen, MD',
      startDate: 'Jan 15, 2023',
      reasonForMedication: 'Hypertension management',
      specialInstructions:
          'Take with or without food. Avoid high potassium foods.',
      pharmacy: 'CVS Pharmacy - Main St',
      lastFillDate: 'Dec 20, 2024',
      nextRefillDate: 'Jan 19, 2025',
      quantityRemaining: 15,
      priorAuthStatus: 'Not required',
    ),
    CurrentMedication(
      id: 2,
      genericName: 'Cholecalciferol',
      brandName: 'Vitamin D3',
      strength: '2000 IU',
      form: 'Softgel',
      route: 'Oral',
      frequency: 'Once daily (with breakfast)',
      prescribingPhysician: 'Dr. Michael Chen, MD',
      startDate: 'Dec 01, 2024',
      reasonForMedication: 'Vitamin D deficiency',
      specialInstructions: 'Take with food for better absorption',
      pharmacy: 'CVS Pharmacy - Main St',
      lastFillDate: 'Dec 01, 2024',
      nextRefillDate: 'March 01, 2025',
      quantityRemaining: 68,
      priorAuthStatus: 'Not required',
    ),
  ];

  final List<VitalSignRecord> vitalSignsHistory = [
    VitalSignRecord(
      date: 'Dec 23',
      bloodPressureSys: 118,
      bloodPressureDia: 78,
      heartRate: 72,
      temperature: 98.6,
      respiratoryRate: 16,
      oxygenSaturation: 98,
      weight: 140,
      bmi: 22.6,
      bloodGlucose: 95,
    ),
    VitalSignRecord(
      date: 'Dec 20',
      bloodPressureSys: 120,
      bloodPressureDia: 80,
      heartRate: 75,
      temperature: 98.4,
      respiratoryRate: 15,
      oxygenSaturation: 99,
      weight: 140,
      bmi: 22.6,
      bloodGlucose: 92,
    ),
    VitalSignRecord(
      date: 'Dec 15',
      bloodPressureSys: 122,
      bloodPressureDia: 82,
      heartRate: 73,
      temperature: 98.7,
      respiratoryRate: 16,
      oxygenSaturation: 98,
      weight: 141,
      bmi: 22.7,
      bloodGlucose: 89,
    ),
    VitalSignRecord(
      date: 'Dec 10',
      bloodPressureSys: 125,
      bloodPressureDia: 85,
      heartRate: 78,
      temperature: 98.5,
      respiratoryRate: 17,
      oxygenSaturation: 97,
      weight: 142,
      bmi: 22.9,
      bloodGlucose: 98,
    ),
    VitalSignRecord(
      date: 'Dec 5',
      bloodPressureSys: 128,
      bloodPressureDia: 84,
      heartRate: 76,
      temperature: 98.6,
      respiratoryRate: 16,
      oxygenSaturation: 98,
      weight: 142,
      bmi: 22.9,
      bloodGlucose: 94,
    ),
    VitalSignRecord(
      date: 'Nov 30',
      bloodPressureSys: 130,
      bloodPressureDia: 86,
      heartRate: 80,
      temperature: 98.8,
      respiratoryRate: 18,
      oxygenSaturation: 97,
      weight: 143,
      bmi: 23.1,
      bloodGlucose: 96,
    ),
  ];

  final List<VisitEncounter> visitHistory = [
    VisitEncounter(
      id: 1,
      dateTime: 'Dec 20, 2024 at 10:30 AM',
      visitType: 'Office Visit - Follow-up',
      providerName: 'Dr. Michael Chen',
      specialty: 'Internal Medicine',
      department: 'Primary Care Clinic',
      chiefComplaint: 'Hypertension follow-up',
      symptomsDuration: 'Ongoing management since Jan 2023',
      assessment:
          'Essential hypertension, well-controlled on current medication',
      treatmentPlan:
          'Continue Lisinopril 10mg daily. Lifestyle modifications: low sodium diet, regular exercise.',
      proceduresPerformed: ['Blood Pressure Check', 'Medication Review'],
      followUpInstructions:
          'Return in 6 months for BP check. Call if BP readings consistently >140/90.',
      nextAppointmentDate: 'June 20, 2025',
    ),
    VisitEncounter(
      id: 2,
      dateTime: 'Dec 01, 2024 at 2:15 PM',
      visitType: 'Office Visit - Results Review',
      providerName: 'Dr. Michael Chen',
      specialty: 'Internal Medicine',
      department: 'Primary Care Clinic',
      chiefComplaint: 'Review vitamin D lab results',
      symptomsDuration: 'Recent fatigue, 3 weeks',
      assessment: 'Vitamin D deficiency (level 18 ng/mL)',
      treatmentPlan:
          'Start Vitamin D3 2000 IU daily. Recheck levels in 3 months.',
      proceduresPerformed: ['Lab Results Review', 'Nutrition Counseling'],
      followUpInstructions:
          'Take vitamin with food. Increase sun exposure 15 min/day.',
      nextAppointmentDate: 'March 01, 2025',
    ),
    VisitEncounter(
      id: 3,
      dateTime: 'Nov 12, 2024 at 9:00 AM',
      visitType: 'Office Visit - Sick Visit',
      providerName: 'Dr. Emily Rodriguez',
      specialty: 'Family Medicine',
      department: 'Urgent Care',
      chiefComplaint: 'Cough and fever',
      symptomsDuration: '5 days',
      assessment: 'Acute bronchitis',
      treatmentPlan:
          'Amoxicillin 500mg TID x 7 days. Rest, fluids, OTC cough suppressant.',
      proceduresPerformed: [
        'Physical Examination',
        'Chest X-Ray',
        'Rapid Strep Test',
      ],
      followUpInstructions:
          'Return if symptoms worsen or persist after 7 days.',
    ),
  ];

  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }

  void _cancelAppointment(int visitId, String languageCode) {
    setState(() {
      final index = visitHistory.indexWhere((v) => v.id == visitId);
      if (index != -1) {
        // Simulated cancellation: clear the next appointment date
        visitHistory[index] = VisitEncounter(
          id: visitHistory[index].id,
          dateTime: visitHistory[index].dateTime,
          visitType: visitHistory[index].visitType,
          providerName: visitHistory[index].providerName,
          specialty: visitHistory[index].specialty,
          department: visitHistory[index].department,
          chiefComplaint: visitHistory[index].chiefComplaint,
          symptomsDuration: visitHistory[index].symptomsDuration,
          assessment: visitHistory[index].assessment,
          treatmentPlan: visitHistory[index].treatmentPlan,
          proceduresPerformed: visitHistory[index].proceduresPerformed,
          followUpInstructions: visitHistory[index].followUpInstructions,
          nextAppointmentDate: null,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('msgAppointmentCancelled', languageCode)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

            // Search Bar
            _buildSearchBar(languageCode),

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

  Widget _buildSearchBar(String languageCode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      color: colorSecondaryBg,
      child: Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorAccentBeige),
        ),
        child: Row(
          children: [
            const Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Icon(Icons.search, size: 16, color: colorSecondaryText),
            ),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: AppStrings.get('searchRecords', languageCode),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: colorSecondaryText,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(fontSize: 13, color: colorCharcoal),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _showFilters
                    ? colorAccentOlive.withOpacity(0.2)
                    : colorWhite,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _showFilters ? colorAccentOlive : colorAccentBeige,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  size: 14,
                  color: _showFilters ? colorAccentOlive : colorSecondaryText,
                ),
                onPressed: () => setState(() => _showFilters = !_showFilters),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(String languageCode) {
    final tabs = [
      {'id': 'vitals', 'label': AppStrings.get('tabVitals', languageCode)},
      {'id': 'current-meds', 'label': AppStrings.get('tabMedications', languageCode)},
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
      case 'current-meds':
        return _buildMedicationsTab(languageCode);
      case 'vitals':
        return _buildVitalsTab(languageCode);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab(String languageCode) {
    final activeConditions = chronicConditions
        .where(
          (c) => c.currentStatus == 'active' || c.currentStatus == 'controlled',
        )
        .length;

    // Use API data or fallback to mock data if empty
    final vitalsList = _apiVitals.isNotEmpty ? _apiVitals : vitalSignsHistory;
    final medsList = _apiMedications.isNotEmpty ? _apiMedications : currentMedications;
    final latestVital = vitalsList.isNotEmpty ? vitalsList.first : null;

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
                icon: Icons.favorite,
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
            Expanded(
              child: _buildStatCard(
                icon: Icons.medication,
                value: medsList.length.toString(),
                label: AppStrings.get('sectCurrentMedications', languageCode),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE6CA9A), Color(0xFFD9B882)],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                value: visitHistory.length.toString(),
                label: AppStrings.get('tabVisits', languageCode),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF82C4E6), Color(0xFF6AB5D8)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Recent Activity
        Text(
          AppStrings.get(
            'navHome',
            languageCode,
          ), // Using Home as a proxy for activity
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorCharcoal,
          ),
        ),
        _buildActivityCard(
          'Dec 20, 2024',
          'Office Visit - Dr. Michael Chen',
          'Hypertension follow-up • Blood pressure well-controlled',
          colorAccentOlive,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'Dec 01, 2024',
          'New Prescription - Vitamin D3',
          'Started 2000 IU daily for vitamin D deficiency',
          colorAccentBeige,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'Nov 12, 2024',
          'Urgent Care Visit - Acute Bronchitis',
          'Treatment completed • Full recovery',
          const Color(0xFFFFB74D),
        ),
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

  Widget _buildActivityCard(
    String date,
    String title,
    String description,
    Color borderColor,
  ) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: colorSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: colorSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsTab(String languageCode) {
    return Column(
      children: chronicConditions.map((condition) {
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

  Widget _buildMedicationsTab(String languageCode) {
    final medsList = _apiMedications;

    if (medsList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            AppStrings.get('noData', languageCode) ?? 'No medications found.',
            style: const TextStyle(color: colorSecondaryText),
          ),
        ),
      );
    }

    return Column(
      children: medsList.map((med) {
        final isExpanded = _expandedItems.contains(med.id);
        final daysUntilRefill = DateTime.parse(
          '2025-01-19',
        ).difference(DateTime.now()).inDays;
        final needsRefillSoon = daysUntilRefill <= 7;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: needsRefillSoon
                    ? const Color(0xFFFFB74D)
                    : colorSecondaryBg,
                width: needsRefillSoon ? 2 : 1,
              ),
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
                  onTap: () => _toggleExpanded(med.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colorAccentOlive, colorAccentBeige],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medication,
                            color: colorCharcoal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${med.genericName} ${med.strength}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med.brandName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: colorSecondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${med.form} • ${med.route} • ${med.frequency}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: colorSecondaryText,
                                ),
                              ),
                              if (needsRefillSoon) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    border: Border.all(
                                      color: const Color(0xFFFFB74D),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppStrings.get(
                                      'labelRefillNeeded',
                                      languageCode,
                                    ).replaceAll(
                                      '{count}',
                                      daysUntilRefill.toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: isExpanded
                              ? colorAccentOlive
                              : colorSecondaryText,
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                AppStrings.get('labelStartDate', languageCode),
                                med.startDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoRow(
                                AppStrings.get(
                                  'labelQuantityRemaining',
                                  languageCode,
                                ),
                                '${med.quantityRemaining} ${AppStrings.get('labelPills', languageCode)}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('labelReason', languageCode),
                          med.reasonForMedication,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('labelInstructions', languageCode),
                          med.specialInstructions,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('treatingPhysician', languageCode),
                          med.prescribingPhysician,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('pharmacyShort', languageCode),
                          med.pharmacy,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorAccentOlive,
                                  foregroundColor: colorCharcoal,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  AppStrings.get('requestRefill', languageCode),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colorAccentBeige),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share, size: 16),
                                onPressed: () {},
                                color: colorSecondaryText,
                              ),
                            ),
                          ],
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
                  Navigator.pop(context); // Close the sheet immediately so Snackbars are visible

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

                  // Call the backend service
                  final success = await DashboardService.logVitals(
                    uid: user.id!,
                    sys: sys,
                    dia: dia,
                    hr: hr,
                    temp: 98.6,
                    rr: 16,
                    o2: 98,
                    weight: weight,
                    bmi: 22.6,
                    glucose: 95,
                  );

                  if (success) {
                    await _fetchData(); // Refresh API data
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to save vitals via API.'),
                          backgroundColor: Colors.red,
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
      final int currentYear = DateTime.now().year;
      final DateTime parsed = DateFormat('MMM dd yyyy').parse('$dateStr $currentYear');
      return DateFormat('E').format(parsed);
    } catch (e) {
      return dateStr;
    }
  }

  List<VitalSignRecord> get _chartVitals {
    final source = _apiVitals.isNotEmpty ? _apiVitals : vitalSignsHistory;
    return source.take(7).toList().reversed.toList();
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
                final chronologicalVitals = (_apiVitals.isNotEmpty ? _apiVitals : vitalSignsHistory)
                    .reversed.toList();
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
        minY: 60,
        maxY: 140,
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
            barWidth: 2,
            dotData: const FlDotData(show: false),
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
            barWidth: 2,
            dotData: const FlDotData(show: false),
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
        minY: 60,
        maxY: 90,
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
            barWidth: 2,
            dotData: const FlDotData(show: false),
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
        minY: 135,
        maxY: 145,
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
        minY: 80,
        maxY: 105,
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
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab(String languageCode) {
    return Column(
      children: visitHistory.map((visit) {
        final isExpanded = _expandedItems.contains(visit.id);

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
                  onTap: () => _toggleExpanded(visit.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visit.visitType,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colorCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                visit.dateTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: colorSecondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${visit.providerName} • ${visit.specialty}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: colorSecondaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F5FE),
                                  border: Border.all(
                                    color: const Color(0xFF4FC3F7),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  visit.chiefComplaint,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0277BD),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: isExpanded
                              ? colorAccentOlive
                              : colorSecondaryText,
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
                          AppStrings.get('labelDepartment', languageCode),
                          visit.department,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('labelSymptomsDuration', languageCode),
                          visit.symptomsDuration,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('labelAssessment', languageCode),
                          visit.assessment,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('labelTreatmentPlan', languageCode),
                          visit.treatmentPlan,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.get('labelProcedures', languageCode),
                          style: const TextStyle(
                            fontSize: 11,
                            color: colorSecondaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: visit.proceduresPerformed.map((proc) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorAccentOlive.withOpacity(0.2),
                                border: Border.all(color: colorAccentOlive),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                proc,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colorAccentOlive,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          AppStrings.get('labelFollowUp', languageCode),
                          visit.followUpInstructions,
                        ),
                        if (visit.nextAppointmentDate != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            AppStrings.get(
                              'labelNextAppointment',
                              languageCode,
                            ),
                            visit.nextAppointmentDate!,
                            valueColor: colorAccentOlive,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _cancelAppointment(visit.id, languageCode),
                              icon: const Icon(Icons.cancel_outlined, size: 16),
                              label: Text(
                                AppStrings.get('actionCancel', languageCode),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
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
