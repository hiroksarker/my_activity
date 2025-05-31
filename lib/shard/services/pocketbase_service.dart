import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090'); // Change to your PocketBase URL

  // Example: fetch records
  Future<List<RecordModel>> getTasks() async {
    final result = await pb.collection('tasks').getFullList();
    return result;
  }

  // Add more methods for CRUD as needed
}
