import 'package:cloud_firestore/cloud_firestore.dart';

class IdGenerator {
  /// Generates a sequential ID formatted like 'PREFIX-0001'
  static Future<String> generateId(
      String collectionPath, String prefix, String idField) async {
    final firestore = FirebaseFirestore.instance;
    final counterRef = firestore.collection('_counters').doc(collectionPath);

    final seededValue = await _readHighestExistingNumber(
      firestore,
      collectionPath,
      prefix,
      idField,
    );

    final nextNumber = await firestore.runTransaction<int>((transaction) async {
      final counter = await transaction.get(counterRef);
      final current = counter.exists
          ? ((counter.data()?['value'] as num?)?.toInt() ?? 0)
          : seededValue;
      final next = current + 1;
      transaction.set(counterRef, {
        'value': next,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return next;
    });

    return '$prefix-${nextNumber.toString().padLeft(4, '0')}';
  }

  static Future<int> _readHighestExistingNumber(
    FirebaseFirestore firestore,
    String collectionPath,
    String prefix,
    String idField,
  ) async {
    final byField = await firestore
        .collection(collectionPath)
        .where(idField, isGreaterThanOrEqualTo: '$prefix-')
        .where(idField, isLessThan: '$prefix-\uf8ff')
        .orderBy(idField, descending: true)
        .limit(1)
        .get();

    final value = byField.docs.isNotEmpty
        ? byField.docs.first.data()[idField] as String?
        : null;

    if (value != null && value.startsWith('$prefix-')) {
      return int.tryParse(value.split('-').last) ?? 0;
    }

    final byDocumentId = await firestore
        .collection(collectionPath)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$prefix-')
        .where(FieldPath.documentId, isLessThan: '$prefix-\uf8ff')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(1)
        .get();

    if (byDocumentId.docs.isEmpty) return 0;
    return int.tryParse(byDocumentId.docs.first.id.split('-').last) ?? 0;
  }

  static Future<String> generateAcademyId() =>
      generateId('academies', 'ACA', 'academyId');

  static Future<String> generateStudentId() =>
      generateId('students', 'STD', 'studentId');

  static Future<String> generateTeacherId() =>
      generateId('teachers', 'TCH', 'teacherId');

  static Future<String> generateAttendanceId() =>
      generateId('attendances', 'ATT', 'attendanceId');

  static Future<String> generateFeeId() =>
      generateId('fees', 'FEE', 'feeId');

  static Future<String> generateSalaryId() =>
      generateId('salaries', 'SAL', 'salaryId');
}
