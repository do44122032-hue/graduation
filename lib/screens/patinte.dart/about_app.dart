import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF121212), const Color(0xFF1A1F1C), const Color(0xFF2D5F4C).withOpacity(0.3)]
                  : [
                    const Color(0xFF7ECFC8),
                    const Color(0xFFA8D8A0),
                    const Color(0xFFC8DC88),
                    const Color(0xFFD8D070),
                    const Color(0xFFC8C868),
                    const Color(0xFFB8C060),
                  ],
                stops: isDark ? [0.0, 0.5, 1.0] : [0.0, 0.25, 0.5, 0.65, 0.8, 1.0],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.get('optAboutApp', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Hero Logo (Clean)
                        Image.asset(
                          'assets/logo.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.health_and_safety_rounded,
                            size: 150,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Carely',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.get('labelVersion', lang)} 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Glass Card for Content
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1F1C) : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, AppStrings.get('labelMission', lang)),
                              Text(
                                'Carely is an innovative healthcare platform bridging the gap between patients and specialized medical care through cutting-edge technology.',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: isDark ? Colors.white70 : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildSectionHeader(context, AppStrings.get('labelCredits', lang)),
                              _buildCreditItem(
                                context: context,
                                title: 'Lead Developer & Architect',
                                name: 'Eng.dania Al-Zubaidi',
                                icon: Icons.code_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildCreditItem(
                                context: context,
                                title: 'UI/UX Design',
                                name: 'Dania Al-Zubaidi',
                                icon: Icons.design_services_rounded,
                              ),
                              const SizedBox(height: 32),
                              // Footer
                              Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      '© 2026 Carely Health',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Built with excellence for a better future',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? Colors.white24 : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isDark ? const Color(0xFFCBD77E) : const Color(0xFF2D5F4C),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 35,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D5F4C) : const Color(0xFFCBD77E),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCreditItem({
    required BuildContext context,
    required String title,
    required String name,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFFCBD77E) : const Color(0xFF2D5F4C)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? const Color(0xFFCBD77E) : const Color(0xFF2D5F4C), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A3A2E),
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



