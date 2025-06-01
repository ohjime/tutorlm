import 'package:app/core/core.dart';
import 'package:app/core/repositories/user_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository userRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      userRepository = UserRepository(firestore: fakeFirestore);
    });

    group('createUser', () {
      test('should create a user document successfully', () async {
        const uid = 'test-uid';
        const user = User(
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.student,
          isAdmin: false,
        );

        await userRepository.createUser(uid, user);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['email'], equals('test@example.com'));
        expect(doc.data()!['name'], equals('Test User'));
        expect(doc.data()!['role'], equals('student'));
        expect(doc.data()!['isAdmin'], equals(false));
      });

      test('should handle user creation with optional fields', () async {
        const uid = 'test-uid-2';
        const user = User(
          email: 'test2@example.com',
          name: 'Test User 2',
          imageUrl: 'https://example.com/image.jpg',
          coverUrl: 'https://example.com/cover.jpg',
          role: UserRole.tutor,
          isAdmin: true,
        );

        await userRepository.createUser(uid, user);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);
        expect(
          doc.data()!['imageUrl'],
          equals('https://example.com/image.jpg'),
        );
        expect(
          doc.data()!['coverUrl'],
          equals('https://example.com/cover.jpg'),
        );
        expect(doc.data()!['role'], equals('tutor'));
        expect(doc.data()!['isAdmin'], equals(true));
      });
    });

    group('getUser', () {
      test('should return user when document exists', () async {
        const uid = 'test-uid';
        final userData = {
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'student',
          'isAdmin': false,
        };

        await fakeFirestore.collection('users').doc(uid).set(userData);

        final user = await userRepository.getUser(uid);

        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.role, equals(UserRole.student));
        expect(user.isAdmin, equals(false));
      });

      test('should return empty user when document does not exist', () async {
        const uid = 'nonexistent-uid';

        final user = await userRepository.getUser(uid);

        expect(user, equals(User.empty));
      });

      test('should handle user with schedule data', () async {
        const uid = 'test-uid-with-schedule';
        final now = DateTime.now();
        final timeSlot = TimeSlot(
          start: now,
          end: now.add(const Duration(hours: 1)),
        );
        final schedule = Schedule(monthInput: now, initialSlots: [timeSlot]);

        final userData = {
          'email': 'tutor@example.com',
          'name': 'Tutor User',
          'role': 'tutor',
          'isAdmin': false,
          'schedule': schedule.toJson(),
        };

        await fakeFirestore.collection('users').doc(uid).set(userData);

        final user = await userRepository.getUser(uid);

        expect(user.email, equals('tutor@example.com'));
        expect(user.name, equals('Tutor User'));
        expect(user.role, equals(UserRole.tutor));
        expect(user.schedule, isNotNull);
        expect(user.schedule!.slots.length, equals(1));
      });
    });

    group('updateUser', () {
      test('should update user document successfully', () async {
        const uid = 'test-uid';
        const originalUser = User(
          email: 'test@example.com',
          name: 'Original Name',
          role: UserRole.student,
        );

        // Create user first
        await userRepository.createUser(uid, originalUser);

        // Update user
        const updatedUser = User(
          email: 'updated@example.com',
          name: 'Updated Name',
          role: UserRole.tutor,
          isAdmin: true,
        );

        await userRepository.updateUser(uid, updatedUser);

        // Verify update
        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['email'], equals('updated@example.com'));
        expect(doc.data()!['name'], equals('Updated Name'));
        expect(doc.data()!['role'], equals('tutor'));
        expect(doc.data()!['isAdmin'], equals(true));
      });
    });

    group('updateUserRole', () {
      test('should update user role successfully', () async {
        const uid = 'test-uid';
        final userData = {
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'student',
          'isAdmin': false,
        };

        await fakeFirestore.collection('users').doc(uid).set(userData);

        await userRepository.updateUserRole(uid, UserRole.tutor);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['role'], equals('tutor'));
        // Other fields should remain unchanged
        expect(doc.data()!['email'], equals('test@example.com'));
        expect(doc.data()!['name'], equals('Test User'));
      });
    });

    group('updateAdminStatus', () {
      test('should update admin status successfully', () async {
        const uid = 'test-uid';
        final userData = {
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'student',
          'isAdmin': false,
        };

        await fakeFirestore.collection('users').doc(uid).set(userData);

        await userRepository.updateAdminStatus(uid, true);

        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()!['isAdmin'], equals(true));
        // Other fields should remain unchanged
        expect(doc.data()!['email'], equals('test@example.com'));
        expect(doc.data()!['role'], equals('student'));
      });
    });

    group('deleteUser', () {
      test('should delete user document successfully', () async {
        const uid = 'test-uid';
        final userData = {
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'student',
          'isAdmin': false,
        };

        await fakeFirestore.collection('users').doc(uid).set(userData);

        // Verify user exists
        var doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);

        // Delete user
        await userRepository.deleteUser(uid);

        // Verify user is deleted
        doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.exists, isFalse);
      });
    });

    group('getUsers', () {
      test('should return empty list when no users exist', () async {
        final users = await userRepository.getUsers();
        expect(users, isEmpty);
      });

      test('should return all users when multiple users exist', () async {
        final userData1 = {
          'email': 'user1@example.com',
          'name': 'User 1',
          'role': 'student',
          'isAdmin': false,
        };
        final userData2 = {
          'email': 'user2@example.com',
          'name': 'User 2',
          'role': 'tutor',
          'isAdmin': true,
        };

        await fakeFirestore.collection('users').doc('uid1').set(userData1);
        await fakeFirestore.collection('users').doc('uid2').set(userData2);

        final users = await userRepository.getUsers();

        expect(users.length, equals(2));
        expect(users.any((u) => u.email == 'user1@example.com'), isTrue);
        expect(users.any((u) => u.email == 'user2@example.com'), isTrue);
        expect(users.any((u) => u.role == UserRole.student), isTrue);
        expect(users.any((u) => u.role == UserRole.tutor), isTrue);
      });
    });
  });
}
