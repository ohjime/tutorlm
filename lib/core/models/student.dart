import 'package:equatable/equatable.dart';
import 'package:app/core/core.dart';

class Student extends Equatable {
  const Student({
    required this.uid,
    required this.bio,
    required this.headline,
    required this.status,
    required this.courses,
    required this.gradeLevel,
    required this.educationInstitute,
  });

  // Empty constructor for initialization
  static const empty = Student(
    uid: '',
    bio: '',
    courses: [],
    gradeLevel: Grade.unknown,
    educationInstitute: '',
    headline: '',
    status: StudentStatus.inactive,
  );

  final String uid;
  final String bio;
  final List<Course> courses;
  final Grade gradeLevel;
  final String educationInstitute;
  final String headline;
  final StudentStatus status;

  Student copyWith({
    String? uid,
    String? bio,
    List<Course>? courses,
    String? headline,
    Grade? gradeLevel,
    String? educationInstitute,
    StudentStatus? status,
  }) {
    return Student(
      uid: uid ?? this.uid,
      bio: bio ?? this.bio,
      courses: courses ?? this.courses,
      headline: headline ?? this.headline,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      educationInstitute: educationInstitute ?? this.educationInstitute,
      status: status ?? this.status,
    );
  }

  /// Creates a [Student] instance from a JSON‑compatible map.
  /// Nested objects delegate to their own `fromJson` implementations.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      uid: json['uid'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      status: StudentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StudentStatus.inactive,
      ),
      courses:
          (json['courses'] as List<dynamic>?)
              ?.map(
                (courseJson) =>
                    Course.fromJson(courseJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      gradeLevel: Grade.values.firstWhere(
        (e) => e.name == json['gradeLevel'],
        orElse: () => Grade.unknown,
      ),
      educationInstitute: json['educationInstitute'] as String? ?? '',
    );
  }

  /// Serializes this [Student] instance into a JSON‑compatible map.
  /// Nested objects delegate to their own `toJson` implementations.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'bio': bio,
      'headline': headline,
      'status': status.name,
      'courses': courses.map((course) => course.toJson()).toList(),
      'gradeLevel': gradeLevel.name,
      'educationInstitute': educationInstitute,
    };
  }

  @override
  List<Object?> get props => [
    uid,
    bio,
    courses,
    headline,
    gradeLevel,
    educationInstitute,
    status,
  ];
}

// Not made a global model because its specific to only the Student Model
enum StudentStatus { active, inactive }
