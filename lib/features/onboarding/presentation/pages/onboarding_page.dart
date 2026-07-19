import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:product_inventory/core/widgets/premium_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final settingsBox = Hive.box('settings_box');
    await settingsBox.put('has_seen_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _OnboardingPageContent(
                    titleNormal1: 'Welcome to\n',
                    titleHighlighted: 'Product Inventory',
                    titleNormal2: '',
                    subtitle:
                        'Your ultimate solution for tracking and managing your stock in real-time.',
                    imagePath: 'assets/images/onboarding_1.png',
                    cardIcon: Icons.dashboard,
                    cardTitle: 'Smart Dashboard',
                    cardSubtitle:
                        'Get a bird\'s-eye view of your entire inventory with intuitive analytics.',
                  ),
                  _OnboardingPageContent(
                    titleNormal1: 'Manage Stock\n',
                    titleHighlighted: 'Seamlessly',
                    titleNormal2: '',
                    subtitle:
                        'Add, edit, and organize your products effortlessly. Never run out of supplies again.',
                    imagePath: 'assets/images/onboarding_2.png',
                    cardIcon: Icons.inventory_2_outlined,
                    cardTitle: 'Real-time Tracking',
                    cardSubtitle:
                        'Keep your inventory levels accurate and up-to-date at all times.',
                  ),
                  _OnboardingPageContent(
                    titleNormal1: 'Your Data,\n',
                    titleHighlighted: 'Securely Stored',
                    titleNormal2: '',
                    subtitle:
                        'All your inventory data is securely stored locally on your device for fast access.',
                    imagePath: 'assets/images/onboarding_3.png',
                    cardIcon: Icons.security,
                    cardTitle: 'Privacy First',
                    cardSubtitle:
                        'No cloud syncing. Your business data stays strictly on your device.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32.0,
                right: 32.0,
                bottom: 40.0,
                top: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: PremiumButton(
                      label: _currentPage == 2 ? 'Get Started' : 'Next',
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        if (_currentPage == 2) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ).animate().fade().slideX(begin: 0.2, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final String titleNormal1;
  final String titleHighlighted;
  final String titleNormal2;
  final String subtitle;
  final String imagePath;
  final IconData cardIcon;
  final String cardTitle;
  final String cardSubtitle;

  const _OnboardingPageContent({
    required this.titleNormal1,
    required this.titleHighlighted,
    required this.titleNormal2,
    required this.subtitle,
    required this.imagePath,
    required this.cardIcon,
    required this.cardTitle,
    required this.cardSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
              children: [
                TextSpan(text: titleNormal1),
                TextSpan(
                  text: titleHighlighted,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextSpan(text: titleNormal2),
              ],
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 16),
          Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
              )
              .animate()
              .fade(delay: 200.ms, duration: 400.ms)
              .slideY(begin: -0.1, end: 0),

          Expanded(
            child: Center(
              child: Image.asset(imagePath, fit: BoxFit.contain)
                  .animate()
                  .fade(delay: 300.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
            ),
          ),

          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cardIcon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cardTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cardSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
