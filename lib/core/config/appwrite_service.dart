import 'package:appwrite/appwrite.dart';
import 'package:final_project/core/constants/appwrite_constants.dart';

class AppwriteService {
  static const String endpoint = AppwriteConstants.endpoint;
  static const String projectId = AppwriteConstants.projectId;
  static final Client client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId)
    ..setSelfSigned();

  static final Storage storage = Storage(client);
}