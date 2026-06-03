import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/academy.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/config/app_config.dart';

final academyRepositoryProvider = Provider<AcademyRepository>((ref) {
  return AcademyRepository(firestore: FirebaseFirestore.instance);
});

class AcademyRepository {
  final FirebaseFirestore _firestore;

  AcademyRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _academies => _firestore.collection('academies');

  Stream<List<Academy>> watchAcademies() {
    return _academies.snapshots().map((snapshot) {
      final academies = snapshot.docs
          .map((doc) => Academy.fromMap(doc.data(), doc.id))
          .toList();
      academies.sort((a, b) => a.name.compareTo(b.name));
      return academies;
    });
  }

  Future<Academy> createAcademy(Academy academy, String principalEmail, String principalPassword) async {
    final id = await IdGenerator.generateAcademyId();
    
    // 1. Create Principal User via a secondary Firebase app to avoid logging out the Super Admin
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'tempAuthApp-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    
    try {
      final userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: principalEmail, password: principalPassword);
      final principalUid = userCredential.user!.uid;

      // 2. Save principal data to Firestore `users` collection
      await _firestore.collection('users').doc(principalUid).set({
        'uid': principalUid,
        'email': principalEmail,
        'role': 'Principal',
        'academyId': id,
        'name': 'Principal of ${academy.name}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Create the Academy document
      final newAcademy = academy.copyWith(id: id, principalId: principalUid);
      
      final academyData = newAcademy.toMap();
      // Initialize stats
      academyData['stats'] = {
        'students': 0,
        'teachers': 0,
        'fees': 0,
        'salary': 0,
        'attendance': 0,
      };
      
      await _academies.doc(id).set(academyData);

      // Save activity log
      await _firestore.collection('activity_logs').add({
        'action': 'Academy created successfully',
        'academyId': id,
        'academyName': academy.name,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 4. Trigger Email via Firestore `mail` collection
      await _firestore.collection('mail').add({
        'to': principalEmail,
        'message': {
          'subject': 'Your Academy Pro Credentials',
          'html': '''
            <h2>Welcome to Academy Pro</h2>
            <p>Your account has been created in the Academypro.</p>
            <p>You have been assigned as the principal of <strong>${academy.name}</strong>.</p>
            <p><strong>Academy ID:</strong> $id</p>
            <p>Here are your login credentials:</p>
            <ul>
              <li><strong>Login Email:</strong> $principalEmail</li>
              <li><strong>Temporary Password:</strong> $principalPassword</li>
            </ul>
            <p><strong>Login Link:</strong> <a href="${AppConfig.appUrl}">${AppConfig.appUrl}</a></p>
            <p>Please log in and change your password as soon as possible.</p>
            <hr>
            <p>Need help? Contact support: ${AppConfig.supportEmail}</p>
          ''',
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      return newAcademy;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception("the email isn't valid try a different email");
      }
      throw Exception(e.message ?? 'Unable to create principal account.');
    } finally {
      await tempApp.delete();
    }
  }

  Future<void> updateAcademy(Academy academy) async {
    await _academies.doc(academy.id).update(academy.toMap());
  }

  Future<void> deleteAcademy(String id) async {
    // 1. Delete associated students
    final students = await _firestore.collection('students').where('academyId', isEqualTo: id).get();
    for (var doc in students.docs) {
      await doc.reference.delete();
    }

    // 2. Delete associated teachers
    final teachers = await _firestore.collection('teachers').where('academyId', isEqualTo: id).get();
    for (var doc in teachers.docs) {
      await doc.reference.delete();
    }

    // 3. Delete associated attendance
    final attendances = await _firestore.collection('attendance').where('academyId', isEqualTo: id).get();
    for (var doc in attendances.docs) {
      await doc.reference.delete();
    }

    // 4. Delete associated fees
    final fees = await _firestore.collection('fees').where('academyId', isEqualTo: id).get();
    for (var doc in fees.docs) {
      await doc.reference.delete();
    }

    // 5. Delete associated salaries
    final salaries = await _firestore.collection('salaries').where('academyId', isEqualTo: id).get();
    for (var doc in salaries.docs) {
      await doc.reference.delete();
    }

    // 6. Delete principal/users
    final users = await _firestore.collection('users').where('academyId', isEqualTo: id).get();
    for (var doc in users.docs) {
      await doc.reference.delete();
    }

    // 7. Finally delete the academy
    await _academies.doc(id).delete();
  }
}
