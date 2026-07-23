import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/core/database/database_helper.dart';
import 'package:expense_flow/core/utils/excel_helper.dart';
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart';
import 'package:expense_flow/app/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String _githubUrl = 'https://github.com/m35hasinoob';
  static const String _facebookUrl ='https://www.facebook.com/mdmuhaiminulislam.hasin';
  static const String _linkedinUrl ='https://www.linkedin.com/in/m67hasinoob/';
  static const String _emailAddress = 'mdmuhaiminul5430@gmail.com';
  static const String _profileImagePath = 'assets/images/profile.PNG';

  Future<void> _importExcel(BuildContext context, WidgetRef ref) async {
    final imported = await ExcelHelper.importExpensesFromExcel();
    if (imported.isNotEmpty) {
      for (var expense in imported) {
        await ref.read(expenseProvider.notifier).addExpense(expense);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully imported ${imported.length} expense(s)!')),
        );
      }
    }
  }

  void _confirmResetData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will permanently delete all expenses and budgets. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await DatabaseHelper.instance.clearAllData();
              await ref.read(expenseProvider.notifier).loadExpenses();
              await ref.read(budgetProvider.notifier).loadBudgets();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database reset successfully.')),
                );
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching link: $e')),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _emailAddress,
      query: 'subject=Expense Flow Feedback',
    );
    try {
      await launchUrl(emailUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(dialogContext),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _profileImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Hasin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                child: IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutAppSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.wallet, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'About Expense Flow',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildAboutSection(
                          context,
                          icon: LucideIcons.sparkles,
                          title: 'What Expense Flow Does',
                          content:
                          'Expense Flow is an intelligent personal finance manager designed to give you total control over your money. It helps you seamlessly track daily expenses, monitor category budgets, generate visual analytics reports, and backup data effortlessly to Excel files.',
                        ),
                        const SizedBox(height: 18),
                        _buildAboutSection(
                          context,
                          icon: LucideIcons.helpCircle,
                          title: 'How to Use',
                          content:
                          '• Tap "+ Add Expense" on the Home tab to record transactions with category and note.\n'
                              '• Check History tab to filter and review past transactions.\n'
                              '• View Reports tab for automated pie charts and spending distributions.You can export you balance and expense report to excel from here.\n'
                              '• Use Settings to import your Excel sheets anytime and delete your whole database.',
                        ),
                        const SizedBox(height: 18),
                        _buildAboutSection(
                          context,
                          icon: LucideIcons.heart,
                          title: 'Why It Was Built',
                          content:
                          'Expense Flow was crafted with a vision: financial clarity should be simple, private, and fast. Built locally with offline-first storage, it keeps your data 100% private on your device without intrusive ads or forced cloud syncing.',
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Expense Flow • Version 1.0.0',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAboutSection(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
      }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          Text(
            'App Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: Icon(
                isDark ? LucideIcons.moon : LucideIcons.sun,
                color: AppColors.primary,
              ),
              title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled'),
              value: isDark,
              activeColor: AppColors.primary,
              onChanged: (bool value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Data Management',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.fileInput, color: AppColors.info),
                  title: const Text('Import from Excel'),
                  subtitle: const Text('Restore expenses from .xlsx file'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  onTap: () => _importExcel(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: AppColors.error),
                  title: const Text('Reset Database', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Clear all expenses and budget data'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  onTap: () => _confirmResetData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'About Developer',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showImagePreview(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            _profileImagePath,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 54,
                                height: 54,
                                color: Colors.white.withValues(alpha: 0.2),
                                child: const Center(
                                  child: Text(
                                    'H',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muhaiminul Islam Hasin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Software Developer',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThemeSocialChip(
                      context,
                      icon: LucideIcons.github,
                      label: 'GitHub',
                      onTap: () => _launchURL(context, _githubUrl),
                    ),
                    _buildThemeSocialChip(
                      context,
                      icon: LucideIcons.facebook,
                      label: 'Facebook',
                      onTap: () => _launchURL(context, _facebookUrl),
                    ),
                    _buildThemeSocialChip(
                      context,
                      icon: LucideIcons.linkedin,
                      label: 'LinkedIn',
                      onTap: () => _launchURL(context, _linkedinUrl),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                InkWell(
                  onTap: () => _launchEmail(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.mail, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _emailAddress,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showAboutAppSheet(context),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Icon(LucideIcons.wallet, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Expense Flow',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(LucideIcons.chevronRight, size: 14, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThemeSocialChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Material(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}