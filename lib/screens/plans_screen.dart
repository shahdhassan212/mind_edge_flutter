// screens/plans_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/model/study_plan_models.dart';
import '../features/analysis/providers/study_plan_provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyPlanProvider.notifier).fetchArchiveNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyPlanProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDAC0)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Nav
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Row(children: [
                const AppBackButton(),
                const Spacer(),
                const Text('My Plans',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
            ),

            Expanded(
              child: switch (state.archiveStatus) {
                StudyPlanStatus.idle || StudyPlanStatus.loading =>
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                StudyPlanStatus.failure => Center(
                    child: Text(state.error ?? 'Failed to load plans',
                        style: const TextStyle(
                            fontFamily: 'DM Sans', color: AppColors.muted)),
                  ),
                StudyPlanStatus.success => state.archiveItems.isEmpty
                    ? const Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('📋', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 12),
                          Text('No plans yet',
                              style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cocoaDeep)),
                          SizedBox(height: 4),
                          Text('Generate a plan from your documents',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: AppColors.muted)),
                        ]),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                        itemCount: state.archiveItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = state.archiveItems[i];
                          return _PlanCard(
                            item: item,
                            selectedPlan: state.selectedPlan,
                            selectedPlanStatus: state.selectedPlanStatus,
                            onTap: () => ref
                                .read(studyPlanProvider.notifier)
                                .fetchPlanByFile(item.fileName),
                            onToggle: (taskId) => ref
                                .read(studyPlanProvider.notifier)
                                .toggleTask(taskId),
                          );
                        },
                      ),
              },
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Plan card ──────────────────────────────────────────────────
class _PlanCard extends StatefulWidget {
  final PlanArchiveItem item;
  final StudyPlanResponse? selectedPlan;
  final StudyPlanStatus selectedPlanStatus;
  final VoidCallback onTap;
  final void Function(int taskId) onToggle;

  const _PlanCard({
    required this.item,
    required this.selectedPlan,
    required this.selectedPlanStatus,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _expanded = false;

  bool get _isThisPlan =>
      widget.selectedPlan?.fileName == widget.item.fileName &&
      widget.selectedPlan?.id == widget.item.id;

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.item.createdAt.length >= 10
        ? widget.item.createdAt.substring(0, 10)
        : widget.item.createdAt;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.15)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.sm,
      ),
      child: Column(children: [
        // Header
        GestureDetector(
          onTap: () {
            setState(() => _expanded = !_expanded);
            if (!_expanded) widget.onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('📄', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.fileName,
                        style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cocoaDeep),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Created $dateStr',
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w300),
                      ),
                    ]),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: AppColors.muted),
              ),
            ]),
          ),
        ),

        // Expanded content
        if (_expanded) ...[
          Divider(height: 1, color: const Color(0xFFB48C50).withOpacity(0.1)),
          if (widget.selectedPlanStatus == StudyPlanStatus.loading &&
              !_isThisPlan)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          else if (_isThisPlan && widget.selectedPlan != null)
            _buildDays(widget.selectedPlan!)
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Tap to load plan details',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.muted)),
            ),
        ],
      ]),
    );
  }

  Widget _buildDays(StudyPlanResponse plan) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: plan.days.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppGradients.ctaButton,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Day ${day.dayNumber}',
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      day.topic,
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cocoaDeep),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),

                // Tasks
                ...day.tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GestureDetector(
                        onTap: () => widget.onToggle(task.id),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: task.isCompleted
                                  ? const LinearGradient(colors: [
                                      AppColors.dashTextDark,
                                      AppColors.gold
                                    ])
                                  : null,
                              border: task.isCompleted
                                  ? null
                                  : Border.all(
                                      color: AppColors.muted.withOpacity(0.4),
                                      width: 1.5),
                              color:
                                  task.isCompleted ? null : Colors.white,
                            ),
                            child: task.isCompleted
                                ? const Center(
                                    child: Text('✓',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)))
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              task.taskName,
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: task.isCompleted
                                      ? AppColors.muted
                                      : AppColors.cocoaDeep,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.muted),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PriorityBadge(priority: task.priority),
                        ]),
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Priority badge ─────────────────────────────────────────────
class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;
    switch (priority.toLowerCase()) {
      case 'high':
        bg = const Color(0xFFFFEBEB);
        text = const Color(0xFFC0392B);
        break;
      case 'medium':
        bg = const Color(0xFFFFF3E0);
        text = const Color(0xFFE67E22);
        break;
      default:
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF27AE60);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        priority[0].toUpperCase() + priority.substring(1),
        style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: text),
      ),
    );
  }
}