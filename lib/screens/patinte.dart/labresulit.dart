import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';

class LabResultsPage extends StatefulWidget {
  const LabResultsPage({super.key});

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  List<Map<String, dynamic>> _labResults = [];
  bool _isLoading = true;

  // Color Palette
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorSecondaryBg = Color(0xFFF7F7F7);
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorSecondaryText = Color(0xFF4A4A4A);
  static const Color colorAccentOlive = Color(0xFFCBD77E);
  static const Color colorAccentBeige = Color(0xFFE6CA9A);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _labResults = [
          {'date': '2024-12-01', 'glucose': 95.0, 'image': 'https://images.unsplash.com/photo-1620933967796-53cc2b175b6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwbGFiJTIwcmVzdWx0cyUyMGRvY3VtZW50fGVufDF8fHx8MTc2NjQ5NTcwMnww&ixlib=rb-4.1.0&q=80&w=1080'},
          {'date': '2024-12-05', 'glucose': 105.0, 'image': 'https://images.unsplash.com/photo-1704787266051-744fbe10b5ea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsYWJvcmF0b3J5JTIwdGVzdCUyMHJlc3VsdHMlMjBwYXBlcnxlbnwxfHx8fDE3NjY0OTU3MDN8MA&ixlib=rb-4.1.0&q=80&w=1080'},
          {'date': '2024-12-10', 'glucose': 98.0, 'image': 'https://images.unsplash.com/photo-1758691462814-485c3672e447?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwcmVwb3J0JTIwZG9jdW1lbnR8ZW58MXx8fHwxNzY2NDk1NzAzfDA&ixlib=rb-4.1.0&q=80&w=1080'},
          {'date': '2024-12-15', 'glucose': 110.0, 'image': 'https://images.unsplash.com/photo-1620933967796-53cc2b175b6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwbGFiJTIwcmVzdWx0cyUyMGRvY3VtZW50fGVufDF8fHx8MTc2NjQ5NTcwMnww&ixlib=rb-4.1.0&q=80&w=1080'},
          {'date': '2024-12-20', 'glucose': 92.0, 'image': 'https://images.unsplash.com/photo-1704787266051-744fbe10b5ea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsYWJvcmF0b3J5JTIwdGVzdCUyMHJlc3VsdHMlMjBwYXBlcnxlbnwxfHx8fDE3NjY0OTU3MDN8MA&ixlib=rb-4.1.0&q=80&w=1080'},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: colorSecondaryBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: colorAccentOlive))
          : Column(
              children: [
                _buildHeader(languageCode),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: _buildLabResultsContent(languageCode),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(String languageCode) {
    // We use the gradient style from the original labresulit.dart header
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorAccentOlive, colorAccentBeige],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
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
              // Using fallback if string is not available
              AppStrings.get('labResultsTitle', languageCode) == 'labResultsTitle' 
                  ? 'Lab Results' 
                  : AppStrings.get('labResultsTitle', languageCode),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorCharcoal,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultsContent(String languageCode) {
    if (_labResults.isEmpty) {
      return const Center(child: Text("No lab results available."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Blood Glucose Trends",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorCharcoal),
        ),
        const SizedBox(height: 8),
        const Text(
          "Extracted from your uploaded lab reports using Smart OCR.",
          style: TextStyle(fontSize: 12, color: colorSecondaryText),
        ),
        const SizedBox(height: 20),
        
        // OCR Data Chart
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 20, top: 10),
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    const FlLine(color: colorSecondaryBg, strokeWidth: 1),
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
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Too small to show dates cleanly without custom logic
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
              maxY: 120,
              lineBarsData: [
                LineChartBarData(
                  spots: _labResults.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value['glucose']?.toDouble() ?? 0.0);
                  }).toList(),
                  isCurved: true,
                  color: colorAccentOlive,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorAccentOlive.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        
        const Text(
          "Recent Lab Reports",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorCharcoal),
        ),
        const SizedBox(height: 12),
        
        // List of Original Pictures
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _labResults.length,
          itemBuilder: (context, index) {
            final result = _labResults[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(result['image'] ?? '', width: 50, height: 50, fit: BoxFit.cover, 
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: colorAccentBeige),
                  ),
                ),
                title: Text(
                  "Report from ${result['date']}",
                  style: const TextStyle(fontWeight: FontWeight.w600, color: colorCharcoal),
                ),
                subtitle: Text(
                  "Extracted Glucose: ${result['glucose']} mg/dL",
                  style: const TextStyle(color: colorSecondaryText),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorAccentOlive.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, size: 20, color: colorAccentOlive),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(result['image'] ?? ''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorCharcoal,
                                foregroundColor: colorWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed: () => Navigator.pop(context), 
                              child: const Text("Close"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
