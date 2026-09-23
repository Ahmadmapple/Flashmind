import 'package:flutter/material.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LEARNING HISTORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE87A5D),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Statistic',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: Color(0xFF192A3A),
              ),
            ),
            const SizedBox(height: 20),

            // Overall Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF192A3A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OVERALL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFFF3C279),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: '100% ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                            fontFamily: 'serif',
                          ),
                        ),
                        TextSpan(
                          text: 'recall rate',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: const Color(0xFF2C455E),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: const [
                          Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Sessions',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            '5',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Cards Studied',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Active Sets',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Recent Sessions Section
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF192A3A),
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE8E4DB), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDECE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '✓',
                          style: TextStyle(color: Color(0xFF2F776F)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Cell Biology',
                              style: TextStyle(
                                color: Color(0xFF192A3A),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Today - 8s',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: const [
                          Text(
                            '5/5',
                            style: TextStyle(
                              color: Color(0xFF2F776F),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '100%',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF9F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Total duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8A9A9E),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '8s',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF192A3A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Avg. per card',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8A9A9E),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '2s',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF192A3A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text(
              'All Sets',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                color: Color(0xFF192A3A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Card 1: Cell Biology
            _buildSetCard(
              iconWidget: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF192A3A),
                size: 22,
              ),
              iconBgColor: const Color(0xFFF3C279),
              title: 'Cell Biology',
              subtitle: '5 cards · 1 sessions',
              rightAction: 'Study →',
              rightSubtext: '100% correct',
            ),
            const SizedBox(height: 12),

            // Card 2: Japanese Language
            _buildSetCard(
              iconWidget: const Text(
                'あ',
                style: TextStyle(
                  color: Color(0xFF192A3A),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              iconBgColor: const Color(0xFFA8D5BA),
              title: 'Japanese Language',
              subtitle: '5 cards · 0 sessions',
              rightAction: 'Study →',
            ),
            const SizedBox(height: 12),

            // Card 3: Organic Chemistry
            _buildSetCard(
              iconWidget: const Icon(
                Icons.hexagon_outlined,
                color: Color(0xFF192A3A),
                size: 22,
              ),
              iconBgColor: const Color(0xFFD5C4EB),
              title: 'Organic Chemistry',
              subtitle: '3 cards · 0 sessions',
              rightAction: 'Study →',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Reusable Helper Widget for Set Cards
  Widget _buildSetCard({
    required Widget iconWidget,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String rightAction,
    String? rightSubtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rightAction,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE87A5D),
                ),
              ),
              if (rightSubtext != null) ...[
                const SizedBox(height: 4),
                Text(
                  rightSubtext,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
