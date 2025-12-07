import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/detection_bloc.dart';
import '../widgets/threat_card_widget.dart';
import 'threat_details_page.dart';
import '../../domain/entities/detection.dart';
import '../../../../injection_container.dart';
import '../data/sample_threat_data.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DetectionBloc>()..add(const LoadDetectionsHistoryEvent()),
      child: const HistoryPageContent(),
    );
  }
}

class HistoryPageContent extends StatelessWidget {
  const HistoryPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetectionBloc, DetectionState>(
      builder: (context, state) {
        if (state is DetectionsHistoryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is DetectionsHistoryFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "Qo'ng'iroqlar tarixini yuklab bo‘lmadi",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<DetectionBloc>().add(
                          const LoadDetectionsHistoryEvent(),
                        );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Qatradan urunib ko'rish"),
                ),
              ],
            ),
          );
        }

        if (state is DetectionsHistoryLoaded) {
          final detections = state.detections;
          
          // Extract Detection objects from sample threats
          final sampleDetections = SampleThreatData.allThreats
              .map((threat) => threat.detection)
              .toList();
          
          // Combine existing detections with sample threats
          final allDetections = [...detections, ...sampleDetections];
          
          // Sort by timestamp (newest first)
          allDetections.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (allDetections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Qo'ng'iroqlar aniqlanmadi",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Qo'ng'iroqlaringiz tarixi shu yerda paydo bo'ladi",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DetectionBloc>().add(
                    const LoadDetectionsHistoryEvent(),
                  );
              // Wait a bit for the state to update
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allDetections.length,
              itemBuilder: (context, index) {
                final detection = allDetections[index];
                return ThreatCardWidget(
                  detection: detection,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ThreatDetailsPage(
                          detection: detection,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        // Initial state
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

