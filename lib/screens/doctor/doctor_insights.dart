import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../services/language_service.dart';
import '../../services/knowledge_service.dart';
import '../../models/medical_resource_model.dart';

class DoctorInsightsPage extends StatefulWidget {
  const DoctorInsightsPage({super.key});

  @override
  State<DoctorInsightsPage> createState() => _DoctorInsightsPageState();
}

class _DoctorInsightsPageState extends State<DoctorInsightsPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';

  late String languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    languageCode = Provider.of<LanguageService>(context).currentLanguage;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openResource(MedicalResource resource) async {
    if (resource.url == null) return;

    if (resource.url!.startsWith('http')) {
      await launchUrl(
        Uri.parse(resource.url!),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Local path selected via FilePicker
      await OpenFilex.open(resource.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('doctorInsightsTitle', languageCode),
              style: AppTextStyles.h2(
                languageCode: languageCode,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              AppStrings.get('doctorInsightsSubtitle', languageCode),
              style: AppTextStyles.caption(languageCode: languageCode),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPublishResearchSheet,
        backgroundColor: AppColors.doctorPrimary,
        icon: const Icon(Icons.publish, color: Colors.white),
        label: Text(
          AppStrings.get('publishResearch', languageCode),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Categories
            _buildCategories(),
            const SizedBox(height: 24),

            // Results or Discovery Section
            if (_searchController.text.isNotEmpty)
              _buildSearchResults()
            else ...[
              // Community Research Section
              _buildSectionHeader(
                AppStrings.get('labelCommunity', languageCode),
              ),
              const SizedBox(height: 16),
              _buildCommunityResearchList(),

              const SizedBox(height: 32),

              // Trending Section
              _buildSectionHeader(
                AppStrings.get('trendingTitle', languageCode),
              ),
              const SizedBox(height: 16),
              _buildTrendingResources(),
            ],
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  void _showPublishResearchSheet() {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final sourceController = TextEditingController();
    String publishingCategory = 'Doctor Community';
    String? selectedFilePath;
    String? selectedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('postResearchTitle', languageCode),
                  style: AppTextStyles.h2(languageCode: languageCode),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Research Title',
                    hintText: 'Enter a descriptive title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    labelText: 'Source/Institution',
                    hintText: 'e.g., Mayo Clinic, Harvard Medical',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: publishingCategory,
                  items: KnowledgeService.getCategories()
                      .where((c) => c != 'All' && c != 'Doctor Community')
                      .toList()
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .followedBy([
                        const DropdownMenuItem(
                          value: 'Doctor Community',
                          child: Text('Doctor Community'),
                        ),
                      ])
                      .toList(),
                  onChanged: (val) {
                    setModalState(() {
                      publishingCategory = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // REAL PDF Picker
                InkWell(
                  onTap: () async {
                    try {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                            allowMultiple: false,
                          );

                      if (result != null && result.files.single.path != null) {
                        setModalState(() {
                          selectedFilePath = result.files.single.path;
                          selectedFileName = result.files.single.name;
                        });
                      }
                    } catch (e) {
                      debugPrint('Error picking file: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open file picker: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedFileName != null
                            ? AppColors.doctorPrimary
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: selectedFileName != null
                          ? AppColors.doctorPrimary.withOpacity(0.05)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedFileName != null
                              ? Icons.picture_as_pdf
                              : Icons.upload_file,
                          color: selectedFileName != null
                              ? AppColors.doctorPrimary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFileName ??
                                'Choose PDF File (Gallery/Desktop)',
                            style: TextStyle(
                              color: selectedFileName != null
                                  ? AppColors.doctorPrimary
                                  : Colors.grey.shade600,
                              fontWeight: selectedFileName != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedFileName != null)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.doctorPrimary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: summaryController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Short Summary',
                    hintText: 'Provide a brief overview of findings...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a research title'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (selectedFilePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a PDF file to upload'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (summaryController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please provide a short summary'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newResource = MedicalResource(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text.trim(),
                        source: sourceController.text.isEmpty
                            ? 'Peer Contributed'
                            : sourceController.text.trim(),
                        summary: summaryController.text.trim(),
                        category: publishingCategory,
                        imageUrl:
                            'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&q=80&w=200&h=200',
                        url: selectedFilePath, // Store local path
                      );

                      KnowledgeService.addResource(newResource);

                      // Show success snackbar using root context (DoctorInsightsPage) OR show before pop
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Research published successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.doctorPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Publish Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {}),
        decoration: InputDecoration(
          hintText: AppStrings.get('researchSearchHint', languageCode),
          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = KnowledgeService.getCategories();
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  selectedCategory = categories[index];
                });
              },
              selectedColor: AppColors.doctorPrimary.withOpacity(0.2),
              checkmarkColor: AppColors.doctorPrimary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.doctorPrimary
                    : AppColors.secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.doctorPrimary
                      : Colors.grey.shade200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3(languageCode: languageCode)),
        TextButton(
          onPressed: () {},
          child: Text(
            AppStrings.get('seeAll', languageCode),
            style: const TextStyle(color: AppColors.doctorPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityResearchList() {
    final communityResources = KnowledgeService.allResources
        .where((r) => r.category == 'Doctor Community')
        .toList();

    if (communityResources.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Center(
          child: Column(
            children: const [
              Icon(Icons.people_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No peer research yet. Be the first to share!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: communityResources
          .map((resource) => _buildResourceCard(resource))
          .toList(),
    );
  }

  Widget _buildTrendingResources() {
    final trending = KnowledgeService.getTrending();
    return Column(
      children: trending
          .map((resource) => _buildResourceCard(resource))
          .toList(),
    );
  }

  Widget _buildSearchResults() {
    final results = KnowledgeService.searchResources(
      _searchController.text,
      category: selectedCategory,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(
            'searchResultsTitle',
            languageCode,
          ).replaceAll('{count}', results.length.toString()),
          style: AppTextStyles.h3(languageCode: languageCode),
        ),
        const SizedBox(height: 16),
        if (results.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(AppStrings.get('noResultsFound', languageCode)),
            ),
          )
        else
          ...results.map((resource) => _buildResourceCard(resource)).toList(),
      ],
    );
  }

  Widget _buildResourceCard(MedicalResource resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openResource(resource),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        resource.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                      ),
                      if (resource.url != null)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.doctorPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                resource.category,
                                style: const TextStyle(
                                  color: AppColors.doctorPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (resource.isTrending)
                            const Icon(
                              Icons.trending_up,
                              color: Colors.orange,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resource.title,
                        style: AppTextStyles.h4(languageCode: languageCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.source,
                        style: AppTextStyles.caption(
                          languageCode: languageCode,
                          color: AppColors.doctorPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (resource.url != null)
                        TextButton.icon(
                          onPressed: () => _openResource(resource),
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text(
                            'View PDF',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.red.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      else
                        Text(
                          resource.summary,
                          style: AppTextStyles.caption(
                            languageCode: languageCode,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
