import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../widgets/main_screen_widgets.dart';
import '../widgets/robot_widget.dart';
import '../features/auth/auth_providers.dart';
import '../features/analysis/model/study_plan_models.dart';
import '../features/analysis/providers/study_plan_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyPlanProvider.notifier).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(currentUserProvider).when(
          data: (u) => u?.firstName ?? 'there',
          loading: () => '…',
          error: (_, __) => 'there',
        );

    final planState = ref.watch(studyPlanProvider);
    final hasPlan = planState.hasPlan;

    final allTasks = planState.dashboardTasks;

    // Logic: Group ALL tasks by topicName, then find the FIRST topic that has incomplete tasks.
    // This represents the "Current Active Day/Lecture".
    final Map<String, List<DashboardTask>> groupedByTopic = {};
    final List<String> topicOrder = [];

    for (final task in allTasks) {
      if (!groupedByTopic.containsKey(task.topicName)) {
        groupedByTopic[task.topicName] = [];
        topicOrder.add(task.topicName);
      }
      groupedByTopic[task.topicName]!.add(task);
    }

    String? activeTopic;
    for (final topic in topicOrder) {
      if (groupedByTopic[topic]!.any((t) => !t.isCompleted)) {
        activeTopic = topic;
        break;
      }
    }

    // If everything is done, activeTopic will be null.
    final tasksToDisplay = activeTopic != null ? groupedByTopic[activeTopic]! : <DashboardTask>[];

    return Scaffold(
      backgroundColor: AppColors.dashBgTop,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8),
              Color(0xFFF0E0C0),
              Color(0xFFE8D0A8),
            ],
          ),
        ),
        child: Stack(children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.dashGoldLight.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  radius: 0.65,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(children: [
              // ── Greeting header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(
                          text: 'Good morning, ',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dashTextDark,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(
                                text: '$firstName ',
                                style: TextStyle(color: AppColors.dashNameAmber)),
                            const TextSpan(text: '👋'),
                          ],
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(children: [
                    // ── NO PLAN
                    if (!hasPlan) ...[
                      const SizedBox(height: 32),
                      const MainRobot(),
                      const SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          text: "Let's push to the\n",
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dashTextDark,
                            height: 1.25,
                          ),
                          children: [
                            TextSpan(
                              text: 'max! ',
                              style: TextStyle(color: AppColors.dashNameAmber),
                            ),
                            const TextSpan(text: '🚀'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Your journey starts now. Set up a plan and we'll guide you every step of the way.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.dashTextMuted,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── HAS PLAN
                    if (hasPlan) ...[
                      // Robot + motivation strip
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                            border:
                                Border.all(color: AppColors.dashGoldLight.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dashTextDark.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(children: [
                            const SizedBox(
                              width: 72,
                              height: 84,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: MainRobot(),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "You're on fire! 🔥",
                                    style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dashTextDark,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Keep crushing it!',
                                    style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dashTextDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tasksToDisplay.where((t) => t.isCompleted).length} of ${tasksToDisplay.length} tasks done',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 11.5,
                                      color: AppColors.dashTextMuted,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Today's Tasks header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      child: Row(children: [
                        Text(
                          "Today's Tasks",
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dashTextDark,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/plans'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.dashTextDark,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              'View Plans',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),

                    // ── NO PLAN: empty box
                    if (!hasPlan || (hasPlan && tasksToDisplay.isEmpty))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.dashGoldLight.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('📬', style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 10),
                            Text(
                              tasksToDisplay.isEmpty && hasPlan
                                  ? 'All caught up!'
                                  : 'No tasks for today',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dashTextDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tasksToDisplay.isEmpty && hasPlan
                                  ? 'You have completed all your tasks'
                                  : 'Start a plan to get your daily tasks here',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.dashTextMuted,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ]),
                        ),
                      ),

                    // ── HAS PLAN: task list (Only the current active topic)
                    if (hasPlan && tasksToDisplay.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                            child: Text(
                              activeTopic!.isNotEmpty ? activeTopic : "General Tasks",
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dashTextDark.withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: tasksToDisplay.asMap().entries.map((e) {
                                final i = e.key;
                                final task = e.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: i < tasksToDisplay.length - 1 ? 7 : 0),
                                  child: DashTaskCard(
                                    taskId: task.id,
                                    done: task.isCompleted,
                                    name: task.taskName,
                                    meta: task.duration,
                                    priority: task.priority,
                                    onToggle: () =>
                                        ref.read(studyPlanProvider.notifier).toggleTask(task.id),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),
                  ]),
                ),
              ),

              // ── Bottom nav
              DashBottomNav(
                active: 0,
                onTap: (i) {
                  if (i == 0) Navigator.pushNamed(context, '/settings');
                  if (i == 1) Navigator.pushNamed(context, '/library');
                  if (i == 2) Navigator.pushNamed(context, '/scan');
                  if (i == 3) Navigator.pushNamed(context, '/chats');
                  if (i == 4) Navigator.pushNamed(context, '/upload');
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
