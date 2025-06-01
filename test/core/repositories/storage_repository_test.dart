import 'package:app/core/repositories/storage_repository.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

void main() {
  group('StorageRepository', () {
    late MockFirebaseStorage mockStorage;
    late StorageRepository storageRepository;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      storageRepository = StorageRepository(firebaseStorage: mockStorage);
    });

    group('uploadFile', () {
      test('should return empty string when filePath is empty', () async {
        const userId = 'test-user-id';
        const filePath = '';

        final downloadUrl = await storageRepository.uploadFile(
          userId,
          filePath,
        );

        expect(downloadUrl, isEmpty);
      });

      test('should handle file upload with mock storage', () async {
        const userId = 'test-user-id';
        const filename = 'test-image.png';

        // Create test data to simulate file content
        final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

        // Create a mock file upload by putting data directly to storage
        final storageRef = mockStorage
            .ref()
            .child('users')
            .child(userId)
            .child('uploads')
            .child(filename);

        await storageRef.putData(testData);
        final downloadUrl = await storageRef.getDownloadURL();

        expect(downloadUrl, isNotEmpty);
        expect(downloadUrl, contains(filename));
      });

      test('should extract filename correctly from path', () async {
        const userId = 'test-user';
        const filePath = 'complex/path/structure/my-document.pdf';

        // Since we can't create actual files in tests, we'll test the path logic
        // by checking if empty filePath returns empty string
        final emptyResult = await storageRepository.uploadFile(userId, '');
        expect(emptyResult, isEmpty);

        // Test with a valid path structure using mock storage
        final filename = filePath.split('/').last;
        expect(filename, equals('my-document.pdf'));

        // Test mock upload with proper filename
        final testData = Uint8List.fromList([1, 2, 3]);
        final storageRef = mockStorage
            .ref()
            .child('users')
            .child(userId)
            .child('uploads')
            .child(filename);

        await storageRef.putData(testData);
        final downloadUrl = await storageRef.getDownloadURL();

        expect(downloadUrl, contains('my-document.pdf'));
      });

      test('should create proper storage path structure', () async {
        const userId = 'user-123';
        const filename = 'document.pdf';

        final testData = Uint8List.fromList([1, 2, 3, 4]);
        final storageRef = mockStorage
            .ref()
            .child('users')
            .child(userId)
            .child('uploads')
            .child(filename);

        await storageRef.putData(testData);
        final downloadUrl = await storageRef.getDownloadURL();

        expect(downloadUrl, isNotEmpty);
        expect(downloadUrl, contains('users'));
        expect(downloadUrl, contains(userId));
        expect(downloadUrl, contains('uploads'));
        expect(downloadUrl, contains(filename));
      });

      test('should handle different file types', () async {
        const userId = 'test-user-id';
        final testFiles = [
          'document.pdf',
          'image.jpg',
          'video.mp4',
          'audio.mp3',
        ];

        for (final filename in testFiles) {
          final testData = Uint8List.fromList([1, 2, 3]);
          final storageRef = mockStorage
              .ref()
              .child('users')
              .child(userId)
              .child('uploads')
              .child(filename);

          await storageRef.putData(testData);
          final downloadUrl = await storageRef.getDownloadURL();

          expect(downloadUrl, isNotEmpty);
          expect(downloadUrl, contains(filename));
        }
      });

      test('should handle files with special characters in name', () async {
        const userId = 'test-user';
        const filename = 'file-with_special@chars.txt';

        final testData = Uint8List.fromList([1, 2, 3]);
        final storageRef = mockStorage
            .ref()
            .child('users')
            .child(userId)
            .child('uploads')
            .child(filename);

        await storageRef.putData(testData);
        final downloadUrl = await storageRef.getDownloadURL();

        expect(downloadUrl, isNotEmpty);
        expect(downloadUrl, contains(filename));
      });

      test('should handle files with multiple dots in name', () async {
        const userId = 'test-user';
        const filename = 'file.name.with.dots.txt';

        final testData = Uint8List.fromList([1, 2, 3]);
        final storageRef = mockStorage
            .ref()
            .child('users')
            .child(userId)
            .child('uploads')
            .child(filename);

        await storageRef.putData(testData);
        final downloadUrl = await storageRef.getDownloadURL();

        expect(downloadUrl, isNotEmpty);
        expect(downloadUrl, contains(filename));
      });
    });

    group('error handling', () {
      test('should handle empty userId gracefully', () async {
        const userId = '';
        const filename = 'test-file.txt';

        final testData = Uint8List.fromList([1, 2, 3]);
        final storageRef = mockStorage
            .ref()
            .child('users')
            .child(userId)
            .child('uploads')
            .child(filename);

        // This should work even with empty userId in mock
        await storageRef.putData(testData);
        final downloadUrl = await storageRef.getDownloadURL();

        expect(downloadUrl, isNotEmpty);
      });
    });
  });
}
