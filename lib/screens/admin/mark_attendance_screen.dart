import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/attendance/application/attendance_controller.dart';
import '../../features/attendance/domain/attendance.dart';
import '../../features/student/application/student_controller.dart';
import '../../features/teacher/application/teacher_controller.dart';
import '../../theme.dart';
import '../../widgets/app_side_nav.dart';
import '../../widgets/dashboard_shell.dart';

class MarkAttendanceScreen extends ConsumerWidget {
  const MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceStateProvider);
    final attendanceAsync = ref.watch(attendanceStreamProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);
    final teachersAsync = ref.watch(teachersStreamProvider);

    final peopleAsync = state.selectedType == PersonType.student
        ? studentsAsync.whenData(
            (students) => students
                .map((student) => _AttendancePerson(
                      id: student.id,
                      name: student.name,
                      subtitle: 'Class ${student.studentClass} | Roll ${student.rollNumber}',
                    ))
                .toList(),
          )
        : teachersAsync.whenData(
            (teachers) => teachers
                .map((teacher) => _AttendancePerson(
                      id: teacher.id,
                      name: teacher.name,
                      subtitle: '${teacher.subject} | ${teacher.qualification}',
                    ))
                .toList(),
          );

    return DashboardShell(
      title: 'Attendance',
      activeTab: 'Attendance',
      navItems: const [
        NavItemData(icon: Icons.dashboard, label: 'Dashboard', route: '/principal/dashboard'),
        NavItemData(icon: Icons.group, label: 'Students', route: '/principal/students'),
        NavItemData(icon: Icons.person, label: 'Teachers', route: '/principal/teachers'),
        NavItemData(icon: Icons.payments, label: 'Finance', route: '/principal/finance'),
        NavItemData(icon: Icons.event_available, label: 'Attendance', route: '/principal/attendance'),
        NavItemData(icon: Icons.analytics, label: 'Reports'),
        NavItemData(icon: Icons.settings, label: 'Settings'),
      ],
      actions: [
        OutlinedButton.icon(
          onPressed: () => _exportAttendance(context, peopleAsync, attendanceAsync, state),
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          label: const Text('Export'),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AttendanceControls(state: state),
            const SizedBox(height: 24),
            Expanded(
              child: peopleAsync.when(
                data: (people) {
                  return attendanceAsync.when(
                    data: (records) => _AttendanceList(
                      people: people,
                      records: records,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _ErrorState(message: '$error'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(message: '$error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAttendance(
    BuildContext context,
    AsyncValue<List<_AttendancePerson>> peopleAsync,
    AsyncValue<List<Attendance>> attendanceAsync,
    AttendanceStateData state,
  ) async {
    final people = peopleAsync.maybeWhen(data: (value) => value, orElse: () => <_AttendancePerson>[]);
    final records = attendanceAsync.maybeWhen(data: (value) => value, orElse: () => <Attendance>[]);
    final byPerson = {for (final record in records) record.personId: record};
    final formatter = DateFormat('yyyy-MM-dd');

    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Academy Pro Attendance',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('${state.selectedType.name.toUpperCase()} | ${formatter.format(state.selectedDate)}'),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Name', 'Status'],
              data: people
                  .map((person) => [
                        person.id,
                        person.name,
                        byPerson[person.id]?.status.name.toUpperCase() ?? 'PENDING',
                      ])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => document.save(),
      name: 'attendance-${formatter.format(state.selectedDate)}.pdf',
    );
  }
}

class _AttendanceControls extends ConsumerWidget {
  final AttendanceStateData state;

  const _AttendanceControls({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('EEE, MMM d, yyyy');

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<PersonType>(
          segments: const [
            ButtonSegment(
              value: PersonType.student,
              label: Text('Students'),
              icon: Icon(Icons.school),
            ),
            ButtonSegment(
              value: PersonType.teacher,
              label: Text('Teachers'),
              icon: Icon(Icons.badge),
            ),
          ],
          selected: {state.selectedType},
          onSelectionChanged: (value) {
            ref.read(attendanceStateProvider.notifier).updateType(value.first);
          },
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 1),
            );
            if (picked != null) {
              ref.read(attendanceStateProvider.notifier).updateDate(picked);
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(formatter.format(state.selectedDate)),
        ),
      ],
    );
  }
}

class _AttendanceList extends ConsumerWidget {
  final List<_AttendancePerson> people;
  final List<Attendance> records;

  const _AttendanceList({
    required this.people,
    required this.records,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (people.isEmpty) {
      return const Center(child: Text('No records found for this academy.'));
    }

    final byPerson = {for (final record in records) record.personId: record};
    final present = records.where((record) => record.status == AttendanceStatus.present).length;
    final absent = records.where((record) => record.status == AttendanceStatus.absent).length;
    final leave = records.where((record) => record.status == AttendanceStatus.leave).length;

    return Column(
      children: [
        Row(
          children: [
            _SummaryTile(label: 'People', value: '${people.length}', color: AppColors.primary),
            const SizedBox(width: 12),
            _SummaryTile(label: 'Present', value: '$present', color: Colors.green),
            const SizedBox(width: 12),
            _SummaryTile(label: 'Absent', value: '$absent', color: AppColors.error),
            const SizedBox(width: 12),
            _SummaryTile(label: 'Leave', value: '$leave', color: Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: people.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final person = people[index];
              final record = byPerson[person.id];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(person.name.isEmpty ? '?' : person.name.characters.first.toUpperCase()),
                ),
                title: Text(person.name),
                subtitle: Text('${person.id} | ${person.subtitle}'),
                trailing: Wrap(
                  spacing: 8,
                  children: AttendanceStatus.values.map((status) {
                    final selected = record?.status == status;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(status.name.toUpperCase()),
                      onSelected: (_) async {
                        await ref.read(attendanceControllerProvider.notifier).markAttendance(
                              personId: person.id,
                              status: status,
                              existingId: record?.id,
                            );
                        final controllerState = ref.read(attendanceControllerProvider);
                        if (!context.mounted) return;
                        if (controllerState.hasError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${controllerState.error}')),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AttendancePerson {
  final String id;
  final String name;
  final String subtitle;

  const _AttendancePerson({
    required this.id,
    required this.name,
    required this.subtitle,
  });
}
