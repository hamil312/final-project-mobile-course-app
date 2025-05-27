import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  static final String endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
  static final String projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
  static final String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  static final String bucketId = dotenv.env['APPWRITE_BUCKET_ID']!;
}
