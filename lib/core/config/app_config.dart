import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';

class AppwriteConfig {
  static const String endpoint = AppwriteConstants.endpoint;
  static const String projectId = AppwriteConstants.projectId;

  static Client initClient() {
    return Client().setEndpoint(endpoint).setProject(projectId).setSelfSigned(status: true);
  }
}
