import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/detection_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/fraud_detection_theme.dart';
import '../utils/threat_utils.dart';
import '../../domain/entities/detection.dart';
import '../data/sample_threat_data.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/call_monitoring_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildAIMuhofizCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6B46C1), // Purple
                  Color(0xFF3B82F6), // Blue
                ],
              ),
            ),
            child: const Icon(
              Icons.shield,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'AI Muhofiz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Haqiqiy vaqtda qo'ng'iroqlarni himoya qilish",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1720),
      appBar: AppBar(
        title: _buildAIMuhofizCard(),
        backgroundColor: const Color(0xFF0F1720),
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocProvider(
        create: (_) => sl<DetectionBloc>()..add(const LoadDetectionsHistoryEvent()),
        child: const HomePageContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDebugMenu(context),
        backgroundColor: Colors.blue.withOpacity(0.5),
        child: const Icon(Icons.bug_report),
      ),
    );
  }

  void _showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1720),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug: Simulation Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: const Text('Simulate Incoming Call', style: TextStyle(color: Colors.white)),
              subtitle: const Text('+998 90 123 45 67', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await sl<CallMonitoringService>().simulateIncomingCall('+998901234567');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Simulating Call... Monitor Active')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: Colors.blue),
              title: const Text('Simulate Safe Text', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await sl<CallMonitoringService>().simulateText("Hello, how are you? I am just calling to say hi.");
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Simulate Fraud (High)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Keywords: urgent, bank, card, code', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await sl<CallMonitoringService>().simulateText(
                  "This is urgent from your bank. Your card is blocked. Please give me the code sent to your phone immediately to unblock it."
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.dangerous, color: Colors.red),
              title: const Text('Simulate Fraud (Danger)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Keywords: prize, win, money, secret', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await sl<CallMonitoringService>().simulateText(
                  "Congratulations! You won a big prize money. But keep it secret. Send money to claim your win now."
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop_circle, color: Colors.grey),
              title: const Text('Stop Monitoring', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await sl<CallMonitoringService>().stopMonitoringCall();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Monitoring Stopped')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetectionBloc, DetectionState>(
      builder: (context, state) {
        List<Detection> detections = [];
        
        if (state is DetectionsHistoryLoaded) {
          detections = state.detections;
        } else if (state is DetectionsHistoryLoading) {
          // Keep loading indicator but also show sample data if needed, 
          // or just wait. For now, let's just show the loading indicator 
          // as per original logic, but we will append sample data after.
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        // Add sample data for demonstration
        final sampleDetections = SampleThreatData.allThreats.map((e) => e.detection).toList();
        detections = [...detections, ...sampleDetections];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Grid
              _buildStatsGrid(context, detections),
              const SizedBox(height: 24),
              
              // Weekly Activity Chart
              _buildWeeklyActivityChart(context, detections),
              const SizedBox(height: 24),

              // AI Protection Card
              _buildAIProtectionCard(context),
              const SizedBox(height: 24),
              
              // Recent Threats Blocked
              _buildRecentThreatsSection(context, detections),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIProtectionCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B46C1), // Purple
            Color(0xFF3B82F6), // Blue
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Himoya',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Real vaqt rejimida faol monitoring',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Xavfni aniqlash',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Faol',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold,
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

  Widget _buildStatsGrid(BuildContext context, List<Detection> detections) {
    final stats = _calculateStats(detections);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Firibgarlik aniqlandi',
                value: stats['fraud'] ?? 0,
                color: const Color(0xFFD32F2F),
                icon: Icons.close,
                subtitle: 'Bu hafta',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Xavfsiz qo\'ng\'iroqlar',
                value: stats['safe'] ?? 0,
                color: const Color(0xFF2ECC71),
                icon: Icons.check_circle,
                subtitle: 'Bu hafta',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Shubhali',
                value: stats['suspicious'] ?? 0,
                color: const Color(0xFFFFC107),
                icon: Icons.warning,
                subtitle: 'Bu hafta',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Bloklangan',
                value: stats['blocked'] ?? 0,
                color: const Color(0xFF3B82F6),
                icon: Icons.bolt,
                subtitle: 'Avto-bloklangan',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131d2b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(BuildContext context, List<Detection> detections) {
    final weeklyData = _calculateWeeklyData(detections);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131d2b),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalik faollik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 16,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF071827),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'][group.x.toInt()];
                      final value = (rod.toY - rod.fromY).toInt();
                      String label;
                      if (rodIndex == 0) {
                        label = '$day\nfiribgarlik : $value';
                      } else {
                        label = '$day\nxavfsiz : $value';
                      }
                      return BarTooltipItem(
                        label,
                        TextStyle(
                          color: rodIndex == 0 ? const Color(0xFFD32F2F) : const Color(0xFF2ECC71),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 4 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final fraudValue = data['fraud']?.toDouble() ?? 0;
                  final safeValue = data['safe']?.toDouble() ?? 0;
                  
                  return BarChartGroupData(
                    x: index,
                    groupVertically: true,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: fraudValue,
                        color: const Color(0xFFD32F2F),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        fromY: fraudValue,
                        toY: fraudValue + safeValue,
                        color: const Color(0xFF2ECC71),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Ko\'rish',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentThreatsSection(BuildContext context, List<Detection> detections) {
    // Get recent threats (fraud and suspicious only, sorted by timestamp)
    final recentThreats = detections
        .where((d) => ThreatUtils.getRiskLevel(d.score) != FraudAlertLevel.safe)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    final displayThreats = recentThreats.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oxirgi bloklangan xavflar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (displayThreats.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131d2b),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Yaqinda hech qanday xavf bloklanmadi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          )
        else
          ...displayThreats.map((detection) => _buildThreatCard(context, detection)),
      ],
    );
  }

  Widget _buildThreatCard(BuildContext context, Detection detection) {
    final riskLevel = ThreatUtils.getRiskLevel(detection.score);
    final timeAgo = ThreatUtils.formatDate(detection.timestamp);
    
    // Map risk level to threat type name
    String threatName = detection.reason;
    if (threatName.length > 20) {
      threatName = threatName.substring(0, 20) + '...';
    }
    
    // Determine severity color
    Color severityColor;
    String severityText;
    if (riskLevel == FraudAlertLevel.fraud) {
      severityColor = const Color(0xFFD32F2F);
      severityText = 'Kritik';
    } else {
      severityColor = const Color(0xFFFFC107);
      severityText = 'Yuqori';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF071827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning,
              color: Color(0xFFD32F2F),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  threatName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severityText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats(List<Detection> detections) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final thisWeekDetections = detections.where((d) => d.timestamp.isAfter(weekAgo)).toList();
    
    int fraud = 0;
    int safe = 0;
    int suspicious = 0;
    int blocked = 0;
    
    for (final detection in thisWeekDetections) {
      final riskLevel = ThreatUtils.getRiskLevel(detection.score);
      if (riskLevel == FraudAlertLevel.fraud) {
        fraud++;
        if (detection.reported) {
          blocked++;
        }
      } else if (riskLevel == FraudAlertLevel.safe) {
        safe++;
      } else if (riskLevel == FraudAlertLevel.suspicious) {
        suspicious++;
      }
    }
    
    // Count blocked as auto-blocked frauds
    blocked = fraud; // Simplified: all frauds are considered blocked
    
    return {
      'fraud': fraud,
      'safe': safe,
      'suspicious': suspicious,
      'blocked': blocked,
    };
  }

  List<Map<String, int>> _calculateWeeklyData(List<Detection> detections) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday of current week
    final weekData = List.generate(7, (index) => {'fraud': 0, 'safe': 0});
    
    for (final detection in detections) {
      final detectionDate = DateTime(
        detection.timestamp.year,
        detection.timestamp.month,
        detection.timestamp.day,
      );
      final weekStartDate = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );
      
      final daysDiff = detectionDate.difference(weekStartDate).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        final dayIndex = daysDiff; // 0 = Monday, 6 = Sunday
        if (dayIndex >= 0 && dayIndex < 7) {
          final riskLevel = ThreatUtils.getRiskLevel(detection.score);
          if (riskLevel == FraudAlertLevel.fraud) {
            weekData[dayIndex]['fraud'] = (weekData[dayIndex]['fraud'] ?? 0) + 1;
          } else if (riskLevel == FraudAlertLevel.safe) {
            weekData[dayIndex]['safe'] = (weekData[dayIndex]['safe'] ?? 0) + 1;
          }
        }
      }
    }
    
    return weekData;
  }
}
