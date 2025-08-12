import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../config/constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: API_BASE_URL));

  Future<List<Task>> getTasks() async {
    final response = await _dio.get('/tasks');
    return (response.data as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<void> addTask(Task task) async {
    print('POST data: ${task.toJson()}');
    await _dio.post('/tasks', data: task.toJson());
  }

  Future<void> updateTask(Task task) async {
    await _dio.put('/tasks/${task.id}', data: task.toJson());
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('/tasks/$id');
  }

  Future<void> createTask(Task task) async {}
}
