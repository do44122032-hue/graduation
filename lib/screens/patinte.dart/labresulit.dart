import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';

class LabTest {
  final int id;
  final String testName;
  final String value;
  final String unit;
  final String referenceRange;
  final String status;
  final String? trend;

  LabTest({
    required this.id,
    required this.testName,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.status,
    this.trend,
  });
}

class LabPanel {
  final int id;
  final String panelName;
  final String category;
  final String orderDate;
  final String collectionDate;
  final String resultDate;
  final String orderingPhysician;
  final String status;
  final int abnormalCount;
  final List<LabTest> tests;
  final String? imageUrl;

  LabPanel({
    required this.id,
    required this.panelName,
    required this.category,
    required this.orderDate,
    required this.collectionDate,
    required this.resultDate,
    required this.orderingPhysician,
    required this.status,
    required this.abnormalCount,
    required this.tests,
    this.imageUrl,
  });
}

class LabResultsPage extends StatefulWidget {
  const LabResultsPage({super.key});

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  String searchQuery = '';
  bool showFilters = false;
  List<int> expandedPanels = [];
  String filterStatus = 'all';
  String? viewingImage;

  // Color Palette
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorSecondaryBg = Color(0xFFF7F7F7);
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorSecondaryText = Color(0xFF4A4A4A);
  static const Color colorAccentOlive = Color(0xFFCBD77E);
  static const Color colorAccentBeige = Color(0xFFE6CA9A);

  void togglePanel(int id) {
    setState(() {
      if (expandedPanels.contains(id)) {
        expandedPanels.remove(id);
      } else {
        expandedPanels.add(id);
      }
    });
  }

  List<LabPanel> getLabPanels() {
    return [
      LabPanel(
        id: 1,
        panelName: 'Complete Blood Count (CBC)',
        category: 'Hematology',
        orderDate: 'Dec 18, 2024',
        collectionDate: 'Dec 20, 2024 at 8:30 AM',
        resultDate: 'Dec 20, 2024 at 3:45 PM',
        orderingPhysician: 'Dr. Michael Chen, MD',
        status: 'completed',
        abnormalCount: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1620933967796-53cc2b175b6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwbGFiJTIwcmVzdWx0cyUyMGRvY3VtZW50fGVufDF8fHx8MTc2NjQ5NTcwMnww&ixlib=rb-4.1.0&q=80&w=1080',
        tests: [
          LabTest(
            id: 1,
            testName: 'White Blood Cell Count',
            value: '7.2',
            unit: 'K/uL',
            referenceRange: '4.5-11.0',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 2,
            testName: 'Red Blood Cell Count',
            value: '4.8',
            unit: 'M/uL',
            referenceRange: '4.2-5.4',
            status: 'normal',
            trend: 'up',
          ),
          LabTest(
            id: 3,
            testName: 'Hemoglobin',
            value: '13.2',
            unit: 'g/dL',
            referenceRange: '12.0-16.0',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 4,
            testName: 'Hematocrit',
            value: '39.5',
            unit: '%',
            referenceRange: '36.0-46.0',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 5,
            testName: 'Platelet Count',
            value: '245',
            unit: 'K/uL',
            referenceRange: '150-400',
            status: 'normal',
            trend: 'down',
          ),
          LabTest(
            id: 6,
            testName: 'Mean Corpuscular Volume',
            value: '88',
            unit: 'fL',
            referenceRange: '80-100',
            status: 'normal',
            trend: 'stable',
          ),
        ],
      ),
      LabPanel(
        id: 2,
        panelName: 'Comprehensive Metabolic Panel',
        category: 'Chemistry',
        orderDate: 'Dec 18, 2024',
        collectionDate: 'Dec 20, 2024 at 8:30 AM',
        resultDate: 'Dec 20, 2024 at 4:15 PM',
        orderingPhysician: 'Dr. Michael Chen, MD',
        status: 'completed',
        abnormalCount: 2,
        imageUrl:
            'https://images.unsplash.com/photo-1704787266051-744fbe10b5ea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsYWJvcmF0b3J5JTIwdGVzdCUyMHJlc3VsdHMlMjBwYXBlcnxlbnwxfHx8fDE3NjY0OTU3MDN8MA&ixlib=rb-4.1.0&q=80&w=1080',
        tests: [
          LabTest(
            id: 7,
            testName: 'Glucose',
            value: '102',
            unit: 'mg/dL',
            referenceRange: '70-100',
            status: 'high',
            trend: 'up',
          ),
          LabTest(
            id: 8,
            testName: 'Blood Urea Nitrogen (BUN)',
            value: '16',
            unit: 'mg/dL',
            referenceRange: '7-20',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 9,
            testName: 'Creatinine',
            value: '0.9',
            unit: 'mg/dL',
            referenceRange: '0.6-1.2',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 10,
            testName: 'Sodium',
            value: '141',
            unit: 'mmol/L',
            referenceRange: '136-145',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 11,
            testName: 'Potassium',
            value: '4.2',
            unit: 'mmol/L',
            referenceRange: '3.5-5.0',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 12,
            testName: 'Chloride',
            value: '103',
            unit: 'mmol/L',
            referenceRange: '98-107',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 13,
            testName: 'CO2',
            value: '25',
            unit: 'mmol/L',
            referenceRange: '23-29',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 14,
            testName: 'Calcium',
            value: '9.6',
            unit: 'mg/dL',
            referenceRange: '8.5-10.5',
            status: 'normal',
            trend: 'stable',
          ),
        ],
      ),
      LabPanel(
        id: 3,
        panelName: 'Lipid Panel',
        category: 'Chemistry',
        orderDate: 'Dec 18, 2024',
        collectionDate: 'Dec 20, 2024 at 8:30 AM',
        resultDate: 'Dec 20, 2024 at 4:30 PM',
        orderingPhysician: 'Dr. Michael Chen, MD',
        status: 'completed',
        abnormalCount: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1758691462814-485c3672e447?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwcmVwb3J0JTIwZG9jdW1lbnR8ZW58MXx8fHwxNzY2NDk1NzAzfDA&ixlib=rb-4.1.0&q=80&w=1080',
        tests: [
          LabTest(
            id: 15,
            testName: 'Total Cholesterol',
            value: '195',
            unit: 'mg/dL',
            referenceRange: '<200',
            status: 'normal',
            trend: 'down',
          ),
          LabTest(
            id: 16,
            testName: 'HDL Cholesterol',
            value: '58',
            unit: 'mg/dL',
            referenceRange: '>40',
            status: 'normal',
            trend: 'up',
          ),
          LabTest(
            id: 17,
            testName: 'LDL Cholesterol',
            value: '115',
            unit: 'mg/dL',
            referenceRange: '<100',
            status: 'high',
            trend: 'up',
          ),
          LabTest(
            id: 18,
            testName: 'Triglycerides',
            value: '110',
            unit: 'mg/dL',
            referenceRange: '<150',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 19,
            testName: 'Total/HDL Ratio',
            value: '3.4',
            unit: '',
            referenceRange: '<5.0',
            status: 'normal',
            trend: 'stable',
          ),
        ],
      ),
      LabPanel(
        id: 4,
        panelName: 'Thyroid Function Panel',
        category: 'Endocrinology',
        orderDate: 'Nov 25, 2024',
        collectionDate: 'Nov 28, 2024 at 9:00 AM',
        resultDate: 'Nov 29, 2024 at 2:00 PM',
        orderingPhysician: 'Dr. Michael Chen, MD',
        status: 'completed',
        abnormalCount: 0,
        imageUrl:
            'https://images.unsplash.com/photo-1620933967796-53cc2b175b6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwbGFiJTIwcmVzdWx0cyUyMGRvY3VtZW50fGVufDF8fHx8MTc2NjQ5NTcwMnww&ixlib=rb-4.1.0&q=80&w=1080',
        tests: [
          LabTest(
            id: 20,
            testName: 'TSH',
            value: '2.1',
            unit: 'mIU/L',
            referenceRange: '0.4-4.0',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 21,
            testName: 'Free T4',
            value: '1.3',
            unit: 'ng/dL',
            referenceRange: '0.8-1.8',
            status: 'normal',
            trend: 'stable',
          ),
          LabTest(
            id: 22,
            testName: 'Free T3',
            value: '3.2',
            unit: 'pg/mL',
            referenceRange: '2.3-4.2',
            status: 'normal',
            trend: 'stable',
          ),
        ],
      ),
      LabPanel(
        id: 5,
        panelName: 'Vitamin D Level',
        category: 'Endocrinology',
        orderDate: 'Nov 25, 2024',
        collectionDate: 'Nov 28, 2024 at 9:00 AM',
        resultDate: 'Dec 01, 2024 at 10:30 AM',
        orderingPhysician: 'Dr. Michael Chen, MD',
        status: 'completed',
        abnormalCount: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1704787266051-744fbe10b5ea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsYWJvcmF0b3J5JTIwdGVzdCUyMHJlc3VsdHMlMjBwYXBlcnxlbnwxfHx8fDE3NjY0OTU3MDN8MA&ixlib=rb-4.1.0&q=80&w=1080',
        tests: [
          LabTest(
            id: 23,
            testName: 'Vitamin D, 25-Hydroxy',
            value: '18',
            unit: 'ng/mL',
            referenceRange: '30-100',
            status: 'low',
            trend: 'down',
          ),
        ],
      ),
    ];
  }

  Map<String, dynamic> getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return {
          'bg': const Color(0xFFE8F5E9),
          'border': const Color(0xFF81C784),
          'text': const Color(0xFF2E7D32),
        };
      case 'high':
      case 'low':
        return {
          'bg': const Color(0xFFFFF3E0),
          'border': const Color(0xFFFFB74D),
          'text': const Color(0xFFE65100),
        };
      case 'critical':
        return {
          'bg': const Color(0xFFFFEBEE),
          'border': const Color(0xFFE57373),
          'text': const Color(0xFFC62828),
        };
      case 'completed':
        return {
          'bg': const Color(0xFFE8F5E9),
          'border': const Color(0xFF81C784),
          'text': const Color(0xFF2E7D32),
        };
      case 'pending':
        return {
          'bg': const Color(0xFFFFF9C4),
          'border': const Color(0xFFFDD835),
          'text': const Color(0xFFF57F17),
        };
      case 'partial':
        return {
          'bg': const Color(0xFFE1F5FE),
          'border': const Color(0xFF4FC3F7),
          'text': const Color(0xFF0277BD),
        };
      default:
        return {
          'bg': colorSecondaryBg,
          'border': colorAccentBeige,
          'text': colorSecondaryText,
        };
    }
  }

  String getLocalizedStatus(String status, String languageCode) {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppStrings.get('statusNormal', languageCode);
      case 'high':
        return AppStrings.get('statusHigh', languageCode);
      case 'low':
        return AppStrings.get('statusLow', languageCode);
      case 'critical':
        return AppStrings.get('statusCritical', languageCode);
      case 'partial':
        return AppStrings.get('statusPartial', languageCode);
      case 'pending':
        return AppStrings.get('statusPending', languageCode);
      case 'completed':
        return AppStrings.get('statusCompleted', languageCode);
      default:
        return status;
    }
  }

  Widget getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Icon(
          Icons.check_circle,
          size: 16,
          color: Color(0xFF2E7D32),
        );
      case 'high':
      case 'low':
        return const Icon(
          Icons.warning_amber_rounded,
          size: 16,
          color: Color(0xFFFFB74D),
        );
      case 'critical':
        return const Icon(Icons.error, size: 16, color: Color(0xFFE57373));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget getTrendIcon(String? trend) {
    switch (trend) {
      case 'up':
        return const Icon(Icons.trending_up, size: 14, color: colorAccentOlive);
      case 'down':
        return const Icon(
          Icons.trending_down,
          size: 14,
          color: colorAccentBeige,
        );
      case 'stable':
        return const Icon(Icons.remove, size: 14, color: colorSecondaryText);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    final labPanels = getLabPanels();
    final filteredPanels = labPanels.where((panel) {
      if (filterStatus == 'abnormal' && panel.abnormalCount == 0) {
        return false;
      }
      if (filterStatus != 'all' &&
          filterStatus != 'abnormal' &&
          panel.status != filterStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !panel.panelName.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: colorSecondaryBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(languageCode),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search & Filters
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colorAccentBeige),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 12,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: 16,
                                    color: colorSecondaryText,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) =>
                                        setState(() => searchQuery = value),
                                    decoration: InputDecoration(
                                      hintText: AppStrings.get(
                                        'searchLabTests',
                                        languageCode,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: colorSecondaryText,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: colorCharcoal,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(
                                    () => showFilters = !showFilters,
                                  ),
                                  icon: Icon(
                                    Icons.filter_list,
                                    size: 14,
                                    color: showFilters
                                        ? colorAccentOlive
                                        : colorSecondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showFilters)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    [
                                      'all',
                                      'completed',
                                      'pending',
                                      'abnormal',
                                    ].map((filter) {
                                      final isSelected = filterStatus == filter;
                                      String label;
                                      switch (filter) {
                                        case 'all':
                                          label = AppStrings.get(
                                            'labelFilterAll',
                                            languageCode,
                                          );
                                          break;
                                        case 'completed':
                                          label = AppStrings.get(
                                            'labelFilterCompleted',
                                            languageCode,
                                          );
                                          break;
                                        case 'pending':
                                          label = AppStrings.get(
                                            'labelFilterPending',
                                            languageCode,
                                          );
                                          break;
                                        case 'abnormal':
                                          label = AppStrings.get(
                                            'labelFilterAbnormal',
                                            languageCode,
                                          );
                                          break;
                                        default:
                                          label = filter;
                                      }

                                      return ChoiceChip(
                                        label: Text(label.toUpperCase()),
                                        selected: isSelected,
                                        onSelected: (val) => setState(
                                          () => filterStatus = filter,
                                        ),
                                        selectedColor: colorAccentOlive
                                            .withOpacity(0.2),
                                        backgroundColor: colorWhite,
                                      );
                                    }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Stats
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          _buildStatCard(
                            AppStrings.get('statTotalTests', languageCode),
                            '${labPanels.fold<int>(0, (sum, p) => sum + p.tests.length)}',
                            const Color(0xFF82C4E6),
                            Icons.analytics_outlined,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            AppStrings.get('statAbnormal', languageCode),
                            '${labPanels.fold<int>(0, (sum, p) => sum + p.abnormalCount)}',
                            const Color(0xFFE6CA9A),
                            Icons.warning_amber_rounded,
                          ),
                        ],
                      ),
                    ),

                    // Results List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: filteredPanels
                            .map(
                              (panel) => _buildPanelCard(panel, languageCode),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ],
            ),
          ),
          if (viewingImage != null) _buildImageViewer(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorCharcoal,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: colorSecondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelCard(LabPanel panel, String languageCode) {
    final isExpanded = expandedPanels.contains(panel.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => togglePanel(panel.id),
            title: Text(
              panel.panelName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${panel.category} • ${panel.resultDate}'),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (panel.imageUrl != null)
                    GestureDetector(
                      onTap: () =>
                          setState(() => viewingImage = panel.imageUrl),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(panel.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.zoom_in, color: Colors.white),
                        ),
                      ),
                    ),
                  ...panel.tests.map(
                    (test) => _buildTestRow(test, languageCode),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestRow(LabTest test, String languageCode) {
    final color = getStatusColor(test.status)['text'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(test.testName, style: const TextStyle(fontSize: 14)),
              Text(
                AppStrings.get(
                  'labelRangeValue',
                  languageCode,
                ).replaceAll('{range}', test.referenceRange),
                style: const TextStyle(fontSize: 11, color: colorSecondaryText),
              ),
            ],
          ),
          Text(
            '${test.value} ${test.unit}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onTap: () => setState(() => viewingImage = null),
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: Stack(
            children: [
              Image.network(viewingImage!),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => viewingImage = null),
                ),
              ),
            ],
          ),
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
      child: SafeArea(
        bottom: false,
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
                icon: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: colorCharcoal,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
            Text(
              AppStrings.get('labResultsTitle', languageCode),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorCharcoal,
              ),
            ),
            const SizedBox(width: 40), // Spacing to balance the back button
          ],
        ),
      ),
    );
  }
}
