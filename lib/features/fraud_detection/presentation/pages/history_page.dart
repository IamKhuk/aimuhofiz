import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/detection_bloc.dart';
import '../widgets/threat_card_widget.dart';
import 'threat_details_page.dart';
import '../../domain/entities/detection.dart';
import '../../../../injection_container.dart';

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
        // Get database detections (empty if loading/initial/failure)
        List<Detection> dbDetections = [];
        bool isLoading = false;

        if (state is DetectionsHistoryLoaded) {
          dbDetections = state.detections;
        } else if (state is DetectionsHistoryLoading || state is DetectionInitial) {
          isLoading = true;
        }

        final allDetections = [...dbDetections];

        // Sort by timestamp (newest first)
        allDetections.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (allDetections.isEmpty && !isLoading) {
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

        // Show list immediately with sample data, database data will merge in when ready
        return RefreshIndicator(
          onRefresh: () async {
            context.read<DetectionBloc>().add(
                  const LoadDetectionsHistoryEvent(),
                );
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Stack(
            children: [
              ListView.builder(
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
              // Show small loading indicator if database is still loading
              if (isLoading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
}

