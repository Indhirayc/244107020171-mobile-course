import 'package:flutter/material.dart';

const double kWideBreakpoint = 700;

void main() => runApp(const AcademicApp());

class AcademicApp extends StatefulWidget {
  const AcademicApp({super.key});

  @override
  State<AcademicApp> createState() => _AcademicAppState();
}

class _AcademicAppState extends State<AcademicApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: AcademicOverviewPage(
        isDark: isDark,
        onDarkChanged: (value) {
          setState(() {
            isDark = value;
          });
        },
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Semantics(
            label: 'Pengaturan tema',
            hint: isDark
                ? 'Tema gelap aktif'
                : 'Tema terang aktif',
            child: Row(
              children: [
                Icon(
                  isDark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),

                const SizedBox(width: 4),

                Switch.adaptive(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              constraints.maxWidth >= kWideBreakpoint ? 2 : 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // HEADER PROFIL
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        child: Icon(
                          Icons.person,
                          size: 36,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              label: 'Nama mahasiswa',
                              child: Text(
                                'Indhira Yuantika Christy',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'D4 Teknik Informatika',
                              style: theme.textTheme.bodyMedium,
                            ),

                            Text(
                              'Semester 5 • Kelas 3E',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =========================
                // ACADEMIC SUMMARY
                // =========================
                Text(
                  'Academic Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // =========================
                // INFO CARDS
                // =========================
                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount: columns,

                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  childAspectRatio: 2.4,

                  children: const [
                    InfoCard(
                      icon: Icons.school,
                      title: 'IPK',
                      value: '3.75',
                    ),

                    InfoCard(
                      icon: Icons.assignment,
                      title: 'Assignments',
                      value: '8',
                    ),

                    InfoCard(
                      icon: Icons.event_available,
                      title: 'Attendance',
                      value: '92%',
                    ),

                    InfoCard(
                      icon: Icons.menu_book,
                      title: 'Courses',
                      value: '8',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =========================
                // CURRENT SEMESTER
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: colorScheme.outline,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Current Semester',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: colorScheme.primary,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              'Semester 5 - Academic Year 2026',
                              style: theme.textTheme.bodyMedium,
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
      ),
    );
  }
}

// ==================================================
// REUSABLE INFO CARD
// ==================================================

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '$title: $value',

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: colorScheme.primary,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
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
}