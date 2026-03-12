import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface, size: 20),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'LICENCIAS',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.withValues(alpha: 0.1),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Image.asset('assets/Logo.png', height: 60),
                        const SizedBox(height: 10),
                        Text(
                          'AhorrApp v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<LicenseEntry>>(
            future: LicenseRegistry.licenses.toList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No se encontraron licencias.'),
                  ),
                );
              }

              // Agrupación de licencias por paquete
              final Map<String, List<LicenseParagraph>> groupedLicenses = {};
              for (final entry in snapshot.data!) {
                for (final package in entry.packages) {
                  groupedLicenses
                      .putIfAbsent(package, () => [])
                      .addAll(entry.paragraphs);
                }
              }

              final sortedPackages = groupedLicenses.keys.toList()..sort();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final package = sortedPackages[index];
                      final paragraphs = groupedLicenses[package]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: theme.copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.description_outlined,
                                  color: Colors.orange.shade400, size: 18),
                            ),
                            title: Text(
                              package,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              '${paragraphs.length} párrafos legales',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            children: [
                              Text(
                                paragraphs.map((p) => p.text).join('\n\n'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: sortedPackages.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 50),
          ),
        ],
      ),
    );
  }
}
