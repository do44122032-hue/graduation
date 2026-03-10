import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage>
    with SingleTickerProviderStateMixin {
  // Color Palette (Consistent with other patient screens)
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorSecondaryBg = Color(0xFFF7F7F7);
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorSecondaryText = Color(0xFF4A4A4A);
  static const Color colorAccentOlive = Color(0xFFCBD77E);
  static const Color colorAccentBeige = Color(0xFFE6CA9A);
  static const Color colorAlert = Color(0xFFFFB74D);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: colorSecondaryBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(languageCode),
            const SizedBox(height: 8),
            _buildPreferredPharmacyCard(languageCode),
            const SizedBox(height: 24),
            _buildTabBar(languageCode),
            // Using a fixed height for TabBarView to work inside SingleChildScrollView
            // Alternatively, use a NestedScrollView. Given the scope, a generous height is used.
            SizedBox(
              height: 800,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveMedicationsTab(languageCode),
                  _buildOrdersTab(languageCode),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement new prescription scan or manual entry
        },
        backgroundColor: colorCharcoal,
        icon: const Icon(Icons.add_a_photo, color: colorAccentOlive),
        label: Text(
          AppStrings.get('actionNewPrescription', languageCode),
          style: const TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
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
              AppStrings.get('pharmacyTitle', languageCode),
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

  Widget _buildPreferredPharmacyCard(String languageCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorAccentOlive.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront, color: colorCharcoal, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CVS Pharmacy #1234',
                  style: TextStyle(
                    color: colorCharcoal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '123 Health Ave, Wellness City',
                  style: TextStyle(color: colorSecondaryText, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get(
                    'labelOpenToday',
                    languageCode,
                  ).replaceAll('{hours}', '8:00 AM - 9:00 PM'),
                  style: const TextStyle(
                    color: colorAccentOlive,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: colorAccentOlive),
        ],
      ),
    );
  }

  Widget _buildTabBar(String languageCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorAccentBeige.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: colorCharcoal,
        unselectedLabelColor: colorSecondaryText,
        indicator: BoxDecoration(
          color: colorAccentOlive.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorAccentOlive),
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: AppStrings.get('tabActiveMeds', languageCode)),
          Tab(text: AppStrings.get('tabOrderHistory', languageCode)),
        ],
      ),
    );
  }

  Widget _buildActiveMedicationsTab(String languageCode) {
    // Mock Data
    final meds = [
      {
        'name': 'Lisinopril',
        'dosage': '10mg Tablet',
        'frequency': 'Once Daily',
        'remaining': 15,
        'total': 30,
        'refillDate': 'Jan 15, 2024',
        'image':
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=150',
        'canRefill': true,
      },
      {
        'name': 'Vitamin D3',
        'dosage': '2000 IU Softgel',
        'frequency': 'Once Daily',
        'remaining': 45,
        'total': 90,
        'refillDate': 'Feb 20, 2024',
        'image':
            'https://images.unsplash.com/photo-1628771065518-0d82f1938462?auto=format&fit=crop&q=80&w=150',
        'canRefill': false,
      },
      {
        'name': 'Amoxicillin',
        'dosage': '500mg Capsule',
        'frequency': '3 times daily',
        'remaining': 2,
        'total': 21,
        'refillDate': 'No Refills',
        'image':
            'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&q=80&w=150',
        'canRefill': false,
        'alert': 'Finish Course',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: meds.length,
      itemBuilder: (context, index) {
        final med = meds[index];
        final progress = (med['remaining'] as int) / (med['total'] as int);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorSecondaryBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorAccentBeige.withOpacity(0.5),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(med['image'] as String),
                        fit: BoxFit.cover,
                      ),
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
                            Text(
                              med['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorCharcoal,
                              ),
                            ),
                            if (med.containsKey('alert'))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorAlert.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colorAlert),
                                ),
                                child: Text(
                                  med['alert'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colorAlert,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${med['dosage']} • ${med['frequency']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: colorSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Supply Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get(
                          'labelPillsRemaining',
                          languageCode,
                        ).replaceAll('{count}', med['remaining'].toString()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorCharcoal,
                        ),
                      ),
                      Text(
                        AppStrings.get(
                          'labelRefillDate',
                          languageCode,
                        ).replaceAll('{date}', med['refillDate'] as String),
                        style: const TextStyle(
                          fontSize: 12,
                          color: colorSecondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colorSecondaryBg,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress < 0.2 ? colorAlert : colorAccentOlive,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (med['canRefill'] == true)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.get(
                              'msgRefillRequested',
                              languageCode,
                            ).replaceAll('{name}', med['name'] as String),
                          ),
                          backgroundColor: colorAccentOlive,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorCharcoal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      AppStrings.get('actionRequestRefill', languageCode),
                      style: const TextStyle(
                        color: colorWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(String languageCode) {
    final orders = [
      {
        'id': '#ORD-2489',
        'date': 'Dec 28, 2024',
        'items': 'Lisinopril, Atorvastatin',
        'status': 'Processing',
        'price': 15.00,
      },
      {
        'id': '#ORD-2412',
        'date': 'Nov 15, 2024',
        'items': 'Vitamin D3',
        'status': 'Ready',
        'price': 8.50,
      },
      {
        'id': '#ORD-2390',
        'date': 'Oct 02, 2024',
        'items': 'Amoxicillin',
        'status': 'Picked Up',
        'price': 12.00,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final status = order['status'] as String;
        Color statusColor;
        String localizedStatus;

        switch (status) {
          case 'Processing':
            statusColor = Colors.blue;
            localizedStatus = AppStrings.get('statusProcessing', languageCode);
            break;
          case 'Ready':
            statusColor = colorAccentOlive;
            localizedStatus = AppStrings.get('statusReady', languageCode);
            break;
          case 'Picked Up':
            statusColor = Colors.grey;
            localizedStatus = AppStrings.get('statusPickedUp', languageCode);
            break;
          default:
            statusColor = colorCharcoal;
            localizedStatus = status;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorSecondaryBg),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorSecondaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: colorSecondaryText,
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
                        Text(
                          order['id'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorCharcoal,
                          ),
                        ),
                        Text(
                          '\$${(order['price'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['items'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: colorSecondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['date'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: colorSecondaryText,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            localizedStatus,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
