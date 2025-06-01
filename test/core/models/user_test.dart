import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/models/user.dart';
import 'package:app/core/models/schedule.dart';
import 'package:app/core/models/timeslot.dart';

void main() {
  group('User', () {
    final schedule = Schedule(
      monthInput: DateTime(2025, 5, 1),
      initialSlots: [
        TimeSlot(
          id: 'slot1',
          name: 'Morning',
          start: DateTime(2025, 5, 10, 9, 0),
          end: DateTime(2025, 5, 10, 10, 0),
        ),
      ],
    );

    test('empty user isEmpty/isNotEmpty', () {
      expect(User.empty.isEmpty, isTrue);
      expect(User.empty.isNotEmpty, isFalse);
      final notEmpty = User(email: 'a@b.com', name: 'A');
      expect(notEmpty.isEmpty, isFalse);
      expect(notEmpty.isNotEmpty, isTrue);
    });

    test('equality and hashCode', () {
      final u1 = User(
        email: 'a@b.com',
        name: 'A',
        role: UserRole.tutor,
        isAdmin: true,
        schedule: schedule,
      );
      final u2 = User(
        email: 'a@b.com',
        name: 'A',
        role: UserRole.tutor,
        isAdmin: true,
        schedule: schedule,
      );
      final u3 = User(email: 'b@b.com', name: 'B');
      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1, isNot(equals(u3)));
    });

    test('toMap and fromJson round-trip', () {
      final user = User(
        email: 'test@user.com',
        name: 'Test User',
        imageUrl: 'img.png',
        coverUrl: 'cover.png',
        role: UserRole.student,
        isAdmin: false,
        schedule: schedule,
      );
      final map = user.toJson();
      final fromJson = User.fromJson(map);
      expect(fromJson.email, equals(user.email));
      expect(fromJson.name, equals(user.name));
      expect(fromJson.role, equals(user.role));
      expect(fromJson.isAdmin, equals(user.isAdmin));
      expect(fromJson.schedule, equals(user.schedule));
    });

    test('copyWith returns updated user', () {
      final user = User(email: 'a@b.com', name: 'A', role: UserRole.tutor);
      final updated = user.copyWith(
        name: 'B',
        role: UserRole.student,
        isAdmin: true,
      );
      expect(updated.name, equals('B'));
      expect(updated.role, equals(UserRole.student));
      expect(updated.isAdmin, isTrue);
      expect(updated.email, equals('a@b.com'));
    });

    test('role parsing from JSON', () {
      final tutor = User.fromJson({'email': 'a', 'name': 'b', 'role': 'tutor'});
      final student = User.fromJson({
        'email': 'a',
        'name': 'b',
        'role': 'student',
      });
      final unknown = User.fromJson({
        'email': 'a',
        'name': 'b',
        'role': 'other',
      });
      expect(tutor.role, UserRole.tutor);
      expect(student.role, UserRole.student);
      expect(unknown.role, UserRole.unknown);
    });

    test('handles null/empty schedule in fromJson', () {
      final user1 = User.fromJson({
        'email': 'a',
        'name': 'b',
        'schedule': null,
      });
      final user2 = User.fromJson({'email': 'a', 'name': 'b', 'schedule': {}});
      expect(user1.schedule, isNull);
      expect(user2.schedule, isNull);
    });
  });
}
