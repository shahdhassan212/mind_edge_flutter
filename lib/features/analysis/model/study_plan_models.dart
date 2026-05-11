// features/study_plan/model/study_plan_models.dart

// ── Generate request ──────────────────────────────────────────
class StudyPlanGenerateRequest {
  final int days;
  final int hoursPerDay;
  final String level;

  const StudyPlanGenerateRequest({
    required this.days,
    required this.hoursPerDay,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
        'days': days,
        'hours_per_day': hoursPerDay,
        'level': level,
      };
}

// ── Task ──────────────────────────────────────────────────────
class StudyTask {
  final int id;
  final String taskName;
  final String duration;
  final String priority;
  final bool isCompleted;
  final int studyDayId;

  const StudyTask({
    required this.id,
    required this.taskName,
    required this.duration,
    required this.priority,
    required this.isCompleted,
    required this.studyDayId,
  });

  factory StudyTask.fromJson(Map<String, dynamic> j) => StudyTask(
        id: j['id'] as int,
        taskName: j['taskName']?.toString() ?? '',
        duration: j['duration']?.toString() ?? '',
        priority: j['priority']?.toString() ?? 'medium',
        isCompleted: j['isCompleted'] as bool? ?? false,
        studyDayId: j['studyDayId'] as int? ?? 0,
      );
}

// ── Study day ─────────────────────────────────────────────────
class StudyDay {
  final int id;
  final int dayNumber;
  final String topic;
  final List<StudyTask> tasks;

  const StudyDay({
    required this.id,
    required this.dayNumber,
    required this.topic,
    required this.tasks,
  });

  factory StudyDay.fromJson(Map<String, dynamic> j) => StudyDay(
        id: j['id'] as int,
        dayNumber: j['dayNumber'] as int,
        topic: j['topic']?.toString() ?? '',
        tasks: (j['tasks'] as List<dynamic>? ?? [])
            .map((t) => StudyTask.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

// ── Generate response ─────────────────────────────────────────
class StudyPlanResponse {
  final int id;
  final String fileName;
  final String createdAt;
  final List<StudyDay> days;

  const StudyPlanResponse({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.days,
  });

  int get totalTasks => days.fold(0, (sum, d) => sum + d.tasks.length);

  factory StudyPlanResponse.fromJson(Map<String, dynamic> j) =>
      StudyPlanResponse(
        id: j['id'] as int,
        fileName: j['fileName']?.toString() ?? '',
        createdAt: j['createdAt']?.toString() ?? '',
        days: (j['days'] as List<dynamic>? ?? [])
            .map((d) => StudyDay.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

// ── Dashboard task ────────────────────────────────────────────
class DashboardTask {
  final int id;
  final String taskName;
  final String priority;
  final String duration;
  final String fileName;
  final String topicName;
  final bool isCompleted;

  const DashboardTask({
    required this.id,
    required this.taskName,
    required this.priority,
    required this.duration,
    required this.fileName,
    required this.topicName,
    this.isCompleted = false,
  });

  factory DashboardTask.fromJson(Map<String, dynamic> j) => DashboardTask(
        id: j['id'] as int,
        taskName: j['taskName']?.toString() ?? '',
        priority: j['priority']?.toString() ?? 'medium',
        duration: j['duration']?.toString() ?? '',
        fileName: j['fileName']?.toString() ?? '',
        topicName: j['topicName']?.toString() ?? '',
        isCompleted: j['isCompleted'] as bool? ?? false,
      );

  DashboardTask copyWith({bool? isCompleted}) => DashboardTask(
        id: id,
        taskName: taskName,
        priority: priority,
        duration: duration,
        fileName: fileName,
        topicName: topicName,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

// ── Plan archive item ─────────────────────────────────────────
class PlanArchiveItem {
  final int id;
  final String fileName;
  final String createdAt;

  const PlanArchiveItem({
    required this.id,
    required this.fileName,
    required this.createdAt,
  });

  factory PlanArchiveItem.fromJson(Map<String, dynamic> j) => PlanArchiveItem(
        id: j['id'] as int,
        fileName: j['fileName']?.toString() ?? '',
        createdAt: j['createdAt']?.toString() ?? '',
      );
}

// ── State ─────────────────────────────────────────────────────
enum StudyPlanStatus { idle, loading, success, failure }

class StudyPlanState {
  final StudyPlanStatus generateStatus;
  final StudyPlanStatus dashboardStatus;
  final StudyPlanStatus archiveStatus;
  final StudyPlanStatus selectedPlanStatus;
  final StudyPlanResponse? planData;
  final List<DashboardTask> dashboardTasks;
  final List<PlanArchiveItem> archiveItems;
  final StudyPlanResponse? selectedPlan;
  final String? error;

  const StudyPlanState({
    this.generateStatus = StudyPlanStatus.idle,
    this.dashboardStatus = StudyPlanStatus.idle,
    this.archiveStatus = StudyPlanStatus.idle,
    this.selectedPlanStatus = StudyPlanStatus.idle,
    this.planData,
    this.dashboardTasks = const [],
    this.archiveItems = const [],
    this.selectedPlan,
    this.error,
  });

  bool get hasPlan => dashboardTasks.isNotEmpty;

  StudyPlanState copyWith({
    StudyPlanStatus? generateStatus,
    StudyPlanStatus? dashboardStatus,
    StudyPlanStatus? archiveStatus,
    StudyPlanStatus? selectedPlanStatus,
    StudyPlanResponse? planData,
    List<DashboardTask>? dashboardTasks,
    List<PlanArchiveItem>? archiveItems,
    StudyPlanResponse? selectedPlan,
    String? error,
  }) =>
      StudyPlanState(
        generateStatus: generateStatus ?? this.generateStatus,
        dashboardStatus: dashboardStatus ?? this.dashboardStatus,
        archiveStatus: archiveStatus ?? this.archiveStatus,
        selectedPlanStatus: selectedPlanStatus ?? this.selectedPlanStatus,
        planData: planData ?? this.planData,
        dashboardTasks: dashboardTasks ?? this.dashboardTasks,
        archiveItems: archiveItems ?? this.archiveItems,
        selectedPlan: selectedPlan ?? this.selectedPlan,
        error: error ?? this.error,
      );
}