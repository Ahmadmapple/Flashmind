import 'package:flutter/material.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  // GANTI KE 'null' JIKA INGIN DUMMY DATA KOSONG:
  //static const _RecentSession? _latestSession = null;

  static const _RecentSession? _latestSession = _RecentSession(
    title: 'Cell Biology',
    durationText: 'Today - 8s',
    scoreText: '5/5',
    accuracyText: '100%',
    totalDuration: '8s',
    avgPerCard: '2s',
  );

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

            // WIDGET KARTU RECENT SESSION (Mengecek otomatis apakah null atau ada data)
            const _RecentSessionCard(session: _latestSession),

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
              title: 'Cell Biology',
              subtitle: '5 cards · 1 sessions',
              rightAction: 'Study →',
              rightSubtext: '100% correct',
            ),
            const SizedBox(height: 12),

            // Card 2: Japanese Language
            _buildSetCard(
              title: 'Japanese Language',
              subtitle: '5 cards · 0 sessions',
              rightAction: 'Study →',
            ),
            const SizedBox(height: 12),

            // Card 3: Organic Chemistry
            _buildSetCard(
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

  Widget _buildSetCard({
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

class _RecentSession {
  final String title;
  final String durationText;
  final String scoreText;
  final String accuracyText;
  final String totalDuration;
  final String avgPerCard;

  const _RecentSession({
    required this.title,
    required this.durationText,
    required this.scoreText,
    required this.accuracyText,
    required this.totalDuration,
    required this.avgPerCard,
  });
}

class _RecentSessionCard extends StatelessWidget {
  final _RecentSession? session;

  const _RecentSessionCard({this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8E4DB), width: 2),
        ),
        child: const Center(
          child: Text(
            'No study sessions. Start studying to see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // 2. TAMPILAN JIKA ADA SESI BELAJAR
    return Container(
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
                  children: [
                    Text(
                      session!.title,
                      style: const TextStyle(
                        color: Color(0xFF192A3A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      session!.durationText,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    session!.scoreText,
                    style: const TextStyle(
                      color: Color(0xFF2F776F),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    session!.accuracyText,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                    children: [
                      const Text(
                        'Total duration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A9A9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session!.totalDuration,
                        style: const TextStyle(
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
                    children: [
                      const Text(
                        'Avg. per card',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A9A9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session!.avgPerCard,
                        style: const TextStyle(
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
    );
  }
}