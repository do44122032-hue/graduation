import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class PatientCaseStudy extends StatefulWidget {
  const PatientCaseStudy({Key? key}) : super(key: key);

  @override
  State<PatientCaseStudy> createState() => _PatientCaseStudyState();
}

class _PatientCaseStudyState extends State<PatientCaseStudy>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> expandedSections = {'presentation', 'objectives'};
  Set<String> completedTasks = {'task1', 'task3'};

  // Color constants
  static const Color bgColor = Color(0xFFF7F7F7);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color charcoalColor = Color(0xFF282828);
  static const Color secondaryTextColor = Color(0xFF4A4A4A);
  static const Color accentOliveColor = Color(0xFFCBD77E);
  static const Color accentBeigeColor = Color(0xFFE8C998);

  final List<LearningTask> learningTasks = [
    LearningTask('task1', 'Review patient history and identify risk factors'),
    LearningTask(
      'task2',
      'Analyze vital signs and physical examination findings',
    ),
    LearningTask('task3', 'Interpret laboratory results'),
    LearningTask('task4', 'Formulate differential diagnosis'),
    LearningTask('task5', 'Propose treatment plan'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void toggleSection(String section) {
    setState(() {
      if (expandedSections.contains(section)) {
        expandedSections.remove(section);
      } else {
        expandedSections.add(section);
      }
    });
  }

  void toggleTask(String taskId) {
    setState(() {
      if (completedTasks.contains(taskId)) {
        completedTasks.remove(taskId);
      } else {
        completedTasks.add(taskId);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentBeigeColor, Color(0xFFF5DDB8)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderButton(Icons.arrow_back),
                        Row(
                          children: [
                            _buildHeaderButton(Icons.bookmark_add_outlined),
                            const SizedBox(width: 8),
                            _buildHeaderButton(Icons.share),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Case Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildBadge(
                                AppStrings.get(
                                  'labelCaseStudy',
                                  lang,
                                ).replaceAll('{id}', '247'),
                                accentBeigeColor,
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                AppStrings.get('labelCardiology', lang),
                                accentOliveColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.get('titleCaseStudy', lang),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: charcoalColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.get('labelCaseDuration', lang),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.error_outline,
                                size: 14,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.get('labelPriority', lang),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tabs
          Container(
            color: whiteColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: accentBeigeColor,
              indicatorWeight: 3,
              labelColor: charcoalColor,
              unselectedLabelColor: secondaryTextColor,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.description, size: 16),
                  text: AppStrings.get('tabOverview', lang),
                ),
                Tab(
                  icon: const Icon(Icons.medical_services, size: 16),
                  text: AppStrings.get('tabClinical', lang),
                ),
                Tab(
                  icon: const Icon(Icons.biotech, size: 16),
                  text: AppStrings.get('tabLabs', lang),
                ),
                Tab(
                  icon: const Icon(Icons.track_changes, size: 16),
                  text: AppStrings.get('tabDiagnosis', lang),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(lang),
                _buildClinicalTab(),
                _buildLabsTab(),
                _buildDiagnosisTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return InkWell(
      onTap: () {
        if (icon == Icons.arrow_back) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 20, color: charcoalColor),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: charcoalColor,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(String lang) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Chief Complaint
        _buildCollapsibleSection(
          AppStrings.get('labelChiefComplaint', lang),
          Icons.person,
          'presentation',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: charcoalColor,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                            text: 'Chief Complaint:\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accentBeigeColor,
                            ),
                          ),
                          TextSpan(
                            text:
                                '"I\'ve been having crushing chest pain for the past 2 hours."',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A 58-year-old male presents to the emergency department with acute onset chest pain. '
                      'The pain is described as crushing, substernal, and radiating to the left arm and jaw. '
                      'Patient appears diaphoretic and anxious.',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: accentBeigeColor, width: 4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: accentBeigeColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: charcoalColor),
                          children: [
                            TextSpan(
                              text: 'Clinical Alert: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Symptoms suggestive of acute coronary syndrome. '
                                  'Immediate assessment and intervention required.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Patient Demographics
        _buildInfoCard(
          AppStrings.get('labelPatientDemographics', lang),
          Icons.person,
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildInfoItem('Age', '58 years'),
              _buildInfoItem('Gender', 'Male'),
              _buildInfoItem('Height', '5\'10" (178 cm)'),
              _buildInfoItem('Weight', '190 lbs (86 kg)'),
              _buildInfoItem('BMI', '27.3 (Overweight)'),
              _buildInfoItem('Blood Type', 'A+'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Vital Signs
        _buildInfoCard(
          AppStrings.get('labelInitialVitals', lang),
          Icons.favorite,
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildVitalItem('Blood Pressure', '165/95 mmHg', true),
              _buildVitalItem('Heart Rate', '98 bpm', true),
              _buildVitalItem('Temperature', '98.6°F (37°C)', false),
              _buildVitalItem('Resp. Rate', '22 breaths/min', true),
              _buildVitalItem('O₂ Saturation', '96% on RA', false),
              _buildVitalItem('Pain Level', '8/10', true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Learning Objectives
        _buildCollapsibleSection(
          AppStrings.get('labelLearningObjectives', lang),
          Icons.track_changes,
          'objectives',
          Column(
            children: [
              ...learningTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => toggleTask(task.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: completedTasks.contains(task.id)
                            ? const Color(0xFFE8F5E9)
                            : bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: completedTasks.contains(task.id)
                              ? accentOliveColor
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            completedTasks.contains(task.id)
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 20,
                            color: completedTasks.contains(task.id)
                                ? accentOliveColor
                                : secondaryTextColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task.label,
                              style: TextStyle(
                                fontSize: 13,
                                color: charcoalColor,
                                decoration: completedTasks.contains(task.id)
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentBeigeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('labelProgress', lang),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: charcoalColor,
                      ),
                    ),
                    Text(
                      '${completedTasks.length} / ${learningTasks.length} completed',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: charcoalColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildClinicalTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildInfoCard(
          'History of Present Illness',
          Icons.description,
          const Text(
            'Patient reports sudden onset of severe chest pain that began 2 hours ago while watching television. '
            'Pain is described as 8/10, crushing, substernal, with radiation to left arm and jaw. Associated '
            'symptoms include diaphoresis, nausea, and shortness of breath. No relief with rest. Denies recent '
            'trauma, similar episodes, or medication non-compliance.',
            style: TextStyle(fontSize: 13, color: charcoalColor, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Physical Examination',
          Icons.medical_services,
          Column(
            children: [
              _buildExamFinding('General', 'Alert, anxious, diaphoretic'),
              const SizedBox(height: 12),
              _buildExamFinding(
                'Cardiovascular',
                'Regular rhythm, no murmurs, S1 and S2 present',
              ),
              const SizedBox(height: 12),
              _buildExamFinding(
                'Respiratory',
                'Clear to auscultation bilaterally, no wheezing',
              ),
              const SizedBox(height: 12),
              _buildExamFinding('Abdomen', 'Soft, non-tender, no organomegaly'),
              const SizedBox(height: 12),
              _buildExamFinding(
                'Extremities',
                'No edema, pulses 2+ bilaterally',
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildLabsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildInfoCard(
          'Cardiac Biomarkers',
          Icons.biotech,
          Column(
            children: [
              _buildLabResult('Troponin I', '2.8 ng/mL', '<0.04 ng/mL', true),
              const SizedBox(height: 10),
              _buildLabResult('CK-MB', '45 U/L', '<25 U/L', true),
              const SizedBox(height: 10),
              _buildLabResult('BNP', '180 pg/mL', '<100 pg/mL', true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentBeigeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ECG Findings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: charcoalColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ST-segment elevation in leads II, III, and aVF. Reciprocal ST depression in leads I and aVL. '
                'Consistent with acute inferior wall myocardial infarction.',
                style: TextStyle(
                  fontSize: 13,
                  color: charcoalColor,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDiagnosisTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentBeigeColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Primary Diagnosis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: charcoalColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Acute ST-Elevation Myocardial Infarction (STEMI)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: charcoalColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Inferior wall involvement',
                style: TextStyle(fontSize: 13, color: charcoalColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Differential Diagnosis',
          Icons.track_changes,
          Column(
            children: [
              _buildDifferentialItem('STEMI (Confirmed)', 'Primary', true),
              const SizedBox(height: 10),
              _buildDifferentialItem('Unstable Angina', 'Ruled Out', false),
              const SizedBox(height: 10),
              _buildDifferentialItem('Pulmonary Embolism', 'Unlikely', false),
              const SizedBox(height: 10),
              _buildDifferentialItem('Aortic Dissection', 'Ruled Out', false),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCollapsibleSection(
    String title,
    IconData icon,
    String sectionId,
    Widget content,
  ) {
    bool isExpanded = expandedSections.contains(sectionId);
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
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
            onTap: () => toggleSection(sectionId),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: accentBeigeColor),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: charcoalColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentBeigeColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: charcoalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: secondaryTextColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: charcoalColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalItem(String label, String value, bool alert) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: alert ? const Color(0xFFFFEBEE) : bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: alert ? const Color(0xFFE57373) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: alert ? const Color(0xFFE57373) : charcoalColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExamFinding(String system, String finding) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            system,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentBeigeColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            finding,
            style: const TextStyle(fontSize: 13, color: charcoalColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResult(
    String test,
    String value,
    String reference,
    bool abnormal,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: abnormal ? const Color(0xFFFFEBEE) : bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: abnormal ? const Color(0xFFE57373) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                test,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: charcoalColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: abnormal ? const Color(0xFFE57373) : charcoalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reference: $reference',
            style: const TextStyle(fontSize: 11, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferentialItem(
    String diagnosis,
    String likelihood,
    bool selected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? accentBeigeColor : bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            diagnosis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: charcoalColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              likelihood,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? charcoalColor : secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: accentBeigeColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Take Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accentBeigeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: accentBeigeColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Complete Case',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: charcoalColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningTask {
  final String id;
  final String label;

  LearningTask(this.id, this.label);
}
