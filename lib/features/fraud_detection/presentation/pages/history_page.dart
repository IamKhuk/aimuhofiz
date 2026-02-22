import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call_history_bloc.dart';
import '../widgets/threat_card_widget.dart';
import 'threat_details_page.dart';
import '../../domain/entities/detection.dart';
import '../../../../injection_container.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CallHistoryBloc>()..add(const LoadCallHistoryEvent()),
      child: const HistoryPageContent(),
    );
  }
}

class HistoryPageContent extends StatefulWidget {
  const HistoryPageContent({super.key});

  @override
  State<HistoryPageContent> createState() => _HistoryPageContentState();
}

class _HistoryPageContentState extends State<HistoryPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<CallHistoryBloc>().state;
      if (state is CallHistoryLoaded && state.hasMore) {
        context.read<CallHistoryBloc>().add(const LoadMoreCallHistoryEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallHistoryBloc, CallHistoryState>(
      listener: (context, state) {
        if (state is CallHistoryDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("O'chirildi")),
          );
        } else if (state is CallHistoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        List<Detection> allDetections = [];
        bool isLoading = false;
        bool hasMore = false;

        if (state is CallHistoryLoaded) {
          allDetections = state.detections;
          hasMore = state.hasMore;
        } else if (state is CallHistoryLoading || state is CallHistoryInitial) {
          isLoading = true;
        }

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

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CallHistoryBloc>().add(
                  const LoadCallHistoryEvent(),
                );
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: allDetections.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= allDetections.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final detection = allDetections[index];
                  return Dismissible(
                    key: ValueKey(detection.id ?? index),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      if (detection.id != null) {
                        context.read<CallHistoryBloc>().add(
                              DeleteCallRecordEvent(detection.id.toString()),
                            );
                      }
                    },
                    child: ThreatCardWidget(
                      detection: detection,
                      onTap: () {
                        final bloc = context.read<CallHistoryBloc>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: ThreatDetailsPage(
                                detection: detection,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
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
