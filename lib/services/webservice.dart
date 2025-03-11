import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pblmsadmin/models/admin_model.dart';

class AdminAPI {
  final String baseUrl = 'https://api.portfoliobuilders.in/api';

  Future<http.Response> loginAdminAPI(String email, String password) async {
    final url = Uri.parse('$baseUrl/superadmin/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> AdminRegisterAPI(
    String email,
    String password,
    String name,
    String role,
    String phoneNumber,
  ) async {
    final url = Uri.parse('$baseUrl/registerUser');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return response; // Return the response object for further handling
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred during registration: $e');
    }
  }

  Future<List<Admincoursemodel>> AdminfetchCoursesAPI(String token) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllCourses');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> courses = jsonDecode(response.body)['courses'];
        return courses.map((item) => Admincoursemodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch courses: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> AdmincreateCourseAPI(
    String title,
    String description,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/createCourse');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed to create course: ${response.reasonPhrase}');
    }
  }

  Future<String> deleteAdminCourse(int courseId, String token) async {
    final url = Uri.parse("$baseUrl/superadmin/deleteCourse/$courseId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Course deleted successfully";
      } else {
        throw Exception(
          "Failed to delete course. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting course: $e");
    }
  }

  Future<String> AdminupdateCourseAPI(
    String token,
    int courseId,
    String title,
    String description,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/updateCourse/$courseId',
    ); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'courseId': courseId, // Ensure courseId is passed as a string if required
      'title': title,
      'description': description,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update course: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  Future<List<AdminModulemodel>> AdminfetchModulesForCourseAPI(
    String token,
    int courseId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getmodules/$courseId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> modules = jsonDecode(response.body)['modules'];
        // Filter modules for the specific course
        return modules.map((item) => AdminModulemodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch modules: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> AdmincreatemoduleAPI(
    String token,
    int courseId,
    String title,
    String content,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/createModule');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'courseId': courseId,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
        'Module created successfully: ${response.body}',
      ); // Log the response body
      return response.body;
    } else {
      print(
        'Failed to create module: ${response.reasonPhrase}',
      ); // Log failure reason
      throw Exception('Failed to create module: ${response.reasonPhrase}');
    }
  }

  Future<String> deleteAdminmodule(
    int courseId,
    String token,
    int moduleId,
  ) async {
    final url = Uri.parse(
      "$baseUrl/superadmin/deleteModule/$courseId/$moduleId",
    );
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Module deleted successfully";
      } else {
        throw Exception(
          "Failed to delete Module. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting Module: $e");
    }
  }

  Future<String> AdminupdateModuleAPI(
    String token,
    int courseId,
    String title,
    String content,
    int moduleId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/updateModule',
    ); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'courseId': courseId,
      'moduleId': moduleId, // Ensure courseId is passed as a string if required
      'title': title,
      'content': content,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update course: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  Future<List<AdminLessonmodel>> AdminfetchLessonsForModuleAPI(
    String token,
    int courseId,
    int moduleId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getLesson/$courseId/$moduleId/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> lessons = jsonDecode(response.body)['lessons'];
        return lessons.map((item) => AdminLessonmodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch lessons: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> AdmincreatelessonseAPI(
  String token,
  int courseId,
  int moduleId,
  String content,
  String title,
  String videoLink,
  String pdfUrl, // Added pdfUrl parameter
) async {
  final url = Uri.parse('$baseUrl/superadmin/createLesson');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'courseId': courseId,
        'moduleId': moduleId,
        'title': title,
        'content': content,
        'videoLink': videoLink,
        'pdfUrl': pdfUrl, // Added pdfUrl to the request body
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Lesson created successfully: ${response.body}');
      return response.body;
    } else {
      print('Failed to create Lesson: ${response.reasonPhrase}');
      throw Exception('Failed to create Lesson: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error in createlessonseAPI: $e');
    throw Exception('Failed to create lesson: $e');
  }
}

  Future<String> AdminuploadLessonFile(
    String token,
    int courseId,
    int batchId,
    String title,
    String content,
    int moduleId,
    int lessonId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/admin/uploadLessonFile/$courseId/$moduleId/$lessonId/$batchId',
    );

    final payload = jsonEncode({
      'lessonId': lessonId,
      'courseId': courseId,
      'batchId': batchId,
      'moduleId': moduleId,
      'title': title,
      'content': content,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      print(
        'Upload Lesson Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception(
          'Failed to upload lesson: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error uploading lesson: $e');
      rethrow;
    }
  }

  Future<String> deleteAdminlesson(String token, int lessonId) async {
    final url = Uri.parse("$baseUrl/superadmin/deleteLesson/$lessonId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Lesson deleted successfull";
      } else {
        throw Exception(
          "Failed to delete Lesson. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting Lesson: $e");
    }
  }

  Future<String> AdminupdateLessonAPI(
  String token,
  int courseId,
  String title,
  String content,
  int moduleId,
  int lessonId,
  String videoLink,
  String pdfUrl,
) async {
  final url = Uri.parse('$baseUrl/superadmin/updateLesson');
  final payload = jsonEncode({
    'lessonId': lessonId,
    'courseId': courseId,
    'moduleId': moduleId,
    'title': title,
    'content': content,
    'videoLink': videoLink,
    'pdfUrl': pdfUrl,
  });
  
  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: payload,
    );
    
    print(
      'Update Lesson Response: ${response.statusCode} - ${response.body}',
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception(
        'Failed to update lesson: ${response.statusCode} - ${response.body}',
      );
    }
  } catch (e) {
    print('Error updating lesson: $e');
    rethrow;
  }
}

  Future adminCreateBatch(
    String token,
    int courseId,
    String batchName,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/createBatch');
    final requestBody = {
      'courseId': courseId,
      'name': batchName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AdminCourseBatch.fromJson(jsonDecode(response.body));
      } else {
        Map errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create batch');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      }
      rethrow;
    }
  }

  Future<List<AdminCourseBatch>> AdminfetctBatchForCourseAPI(
    String token,
    int courseId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getBatchesByCourseId/$courseId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (!responseData.containsKey('batches')) {
          print('Response does not contain batches key: $responseData');
          throw Exception('Invalid response format: missing batches key');
        }

        final List<dynamic> batches = responseData['batches'];

        return batches.map((item) {
          try {
            return AdminCourseBatch.fromJson(item);
          } catch (e) {
            print('Error parsing batch item: $item');
            print('Error details: $e');
            rethrow;
          }
        }).toList();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to fetch batches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in AdminfetctBatchForCourseAPI: $e');
      rethrow;
    }
  }

  Future<String> AdminupdateBatchAPI(
    String token,
    int courseId,
    int batchId,
    String batchName,
    String medium,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/updateBatch');

    final payload = jsonEncode({
      'courseId': courseId,
      'batchId': batchId,
      'name': batchName,
      'medium': medium,
      'startDate': startTime.toIso8601String(),
      'endDate': endTime.toIso8601String(),
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update batch: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating batch: $e');
      rethrow;
    }
  }

  Future<String> deleteAdminBatch(
    int courseId,
    String token,
    int batchId,
  ) async {
    final url = Uri.parse("$baseUrl/superadmin/deleteBatch/$batchId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Module deleted successfully";
      } else {
        throw Exception(
          "Failed to delete Module. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting Module: $e");
    }
  }

  Future<List<AdminAllusersmodel>> fetchAdminUsers(String token) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllUsers');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (!responseBody.containsKey('users') ||
            responseBody['users'] == null) {
          throw Exception('Invalid response format: Missing "users" key');
        }

        final List<dynamic> users = responseBody['users'];

        return users.map((user) => AdminAllusersmodel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<bool> AdminassignUserToBatch({
    required String token,
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/assignStudentToBatch');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId,
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Indicates success
      } else {
        throw Exception('Failed to assign user to batch: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> AdmindeleteUserFromBatch({
    required String token,
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/removeStudentFromBatch/$courseId/$batchId/$userId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId,
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Indicates success
      } else {
        throw Exception('Failed to delete user to batch: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> adminApproveUser({
    required String token,
    required int userId,
    required String role,
    required String action,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/manageUserApproval');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'role': role,
          'action': action.toLowerCase(), // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to process user: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> createQuizAPI({
    required String token,
    required int batchId,
    required int courseId,
    required int moduleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('Creating quiz with data: ${jsonEncode(data)}');

      final url = Uri.parse('$baseUrl/admin/createQuiz/$courseId/$moduleId');
      print('Making request to: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          ...data,
          'batchId': batchId, // Include batchId in the request body
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to create quiz. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }

      // Try to parse the response to verify it's valid JSON
      final responseData = jsonDecode(response.body);
      print('Parsed response: $responseData');
    } catch (e, stackTrace) {
      print('Error creating quiz: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create quiz: $e');
    }
  }

  Future<List<AdminQuizModel>> fetchQuizzes(
    String token,
    int courseId,
    int moduleId,
  ) async {
    final url = Uri.parse('$baseUrl/admin/viewQuiz/$courseId/$moduleId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 404) {
        // Handle 404 (No quizzes found for the module)
        print('No quizzes found for Course $courseId, Module $moduleId');
        return [];
      } else if (response.statusCode == 200) {
        // Parse the quizzes from the response body
        final responseBody = json.decode(response.body);
        final List<dynamic> quizList = responseBody['quizzes'];
        return quizList.map((item) => AdminQuizModel.fromJson(item)).toList();
      } else {
        // Handle unexpected status codes
        throw Exception('Failed to fetch quizzes: ${response.body}');
      }
    } catch (e) {
      print('Error while fetching quizzes: $e');
      throw Exception('An error occurred while fetching quizzes');
    }
  }

  Future<void> createAssignmentAPI({
    required String token,
    required int courseId,
    required int moduleId,
    required String title,
    required String description,
    required String dueDate,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/createAssignment');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'description': description,
          'dueDate': dueDate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Assignment created successfully: ${response.body}');
      } else {
        print('Failed to create assignment: ${response.body}');
        throw Exception(
          'Failed to create assignment: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error in createAssignmentAPI: $e');
      throw Exception('Failed to create assignment: $e');
    }
  }

  Future<List<AssignmentModel>> fetchAssignmentForModuleAPI(
    String token,
    int courseId,
    int moduleId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/viewAssignments/$courseId/$moduleId');
    try {
      print('Fetching assignments from: $url'); // Debug URL

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('Decoded response: $decodedResponse'); // Debug decoded JSON

        if (decodedResponse['assignments'] == null) {
          print('No assignments key in response');
          return [];
        }

        final List<dynamic> assignments = decodedResponse['assignments'];
        return assignments
            .map((item) => AssignmentModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch assignments: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching assignments: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> deleteAdminAssignmentAPI(
    String token,
    int assignmentId,
    int courseId,
    int moduleId,
  ) async {
    final url = Uri.parse(
      "$baseUrl/superadmin/deleteAssignment/$assignmentId/$courseId/$moduleId",
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Assignment deleted successfully";
      } else if (response.statusCode == 404) {
        throw Exception("Assignment not found.");
      } else {
        throw Exception(
          "Failed to delete assignment. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting assignment: $e");
    }
  }

  Future<String> adminupdateAssignmentAPI(
    String token,
    int courseId,
    String title,
    String description,
    int moduleId,
    int assignmentId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/updateAssignment/$assignmentId');

    final payload = jsonEncode({
      'assignmentId': assignmentId,
      'courseId': courseId,
      'moduleId': moduleId,
      'title': title,
      'description': description,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      print(
        'Update assignment Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception(
          'Failed to assignment lesson: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error updating lesson: $e');
      rethrow;
    }
  }

  Future<BatchStudentModel> AdminfetchUsersBatchAPI(
    String token,
    int courseId,
    int batchId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/getStudentsByBatchId/$courseId/$batchId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return BatchStudentModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<UnapprovedUser>> AdminfetchUnApprovedUsersAPI(
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/admin/getUnapprovedUsers');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Changed from 'unapprovedusers' to 'unapprovedUsers' to match API response
        final List<dynamic> unapprovedUsers =
            responseData['unapprovedUsers'] ?? [];
        return unapprovedUsers
            .map((item) => UnapprovedUser.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch users: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error in API call: $e');
      return [];
    }
  }

  Future<UserProfileResponse> fetchUserProfile(String token, int userId) async {
    final url = Uri.parse('$baseUrl/getProfile/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserProfileResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error in API call: $e');
      rethrow;
    }
  }

  Future<List<Submission>> fetchSubmission(
    int assignmentId,
    String token,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/getSubmittedAssignments/$assignmentId',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Extract the submissions array from the response
        final List<dynamic> submissions = responseData['submissions'];
        print('Submissions array: $submissions'); // Debug print
        return submissions.map((item) => Submission.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load submissions: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<QuizSubmission>> fetchQuizAnswers(
    int quizId,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/admin/getAnswerquiz/$quizId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> quizSubmissions = responseData['quizSubmissions'];
        return quizSubmissions
            .map((item) => QuizSubmission.fromMap(item))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load quiz answers: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuestionAPI({
    required String token,
    required int quizId,
    required int questionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/admin/updateQuestion/$quizId/$questionId',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update question: ${response.body}');
      }
    } catch (e) {
      print('Error updating question: $e');
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> updateQuizAPI({
    required String token,
    required int quizId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/admin/updateQuiz/$quizId');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update quiz: ${response.body}');
      }
    } catch (e) {
      print('Error updating quiz: $e');
      throw Exception('Failed to update quiz: $e');
    }
  }

  // API Service methods
  Future<void> AdmindeleteQuizAPI({
    required String token,
    required int courseId,
    required int moduleId,
    required int quizId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/admin/deleteQuiz/$courseId/$moduleId/$quizId',
      );

      print("Sending DELETE request to: $url");

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Quiz deleted successfully.");
        return;
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
          'API Error: ${response.statusCode} - ${responseData['message']}',
        );
      }
    } catch (e) {
      print("Error in deleteQuiz API: $e");
      throw Exception('Failed to delete quiz: $e');
    }
  }

  Future<void> deleteQuestionAPI({
    required String token,
    required int quizId,
    required int questionId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/admin/deleteQuestion/$quizId/$questionId',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Parse the response body
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return; // Successful deletion
      } else if (response.statusCode == 404) {
        throw Exception('Question not found');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete question');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid server response');
      } else if (e is SocketException) {
        throw Exception('Network error occurred');
      } else {
        throw Exception('Failed to delete question: $e');
      }
    }
  }

  Future<AdminLiveLinkResponse?> AdminfetchLiveAdmin(
    String token,
    int batchId,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getLiveLinkBatch/$batchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched live data: $data');
        if (data == null || data.isEmpty) {
          return null;
        }
        return AdminLiveLinkResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching live data: $e');
      return null;
    }
  }

  Future<String> AdminpostLiveLink(
    String token,
    int batchId,
    String liveLink,
    DateTime? liveStartTime,
  ) async {
    if (liveStartTime == null) {
      throw Exception('Live start time cannot be null');
    }

    final url = Uri.parse('$baseUrl/superadmin/postLiveLink/$batchId');

    // Ensure the date-time is in IST (local time in India)
    DateTime istDateTime = liveStartTime.toLocal();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'liveLink': liveLink,
        'liveStartTime': DateFormat(
          "yyyy-MM-dd HH:mm:ss",
        ).format(istDateTime), // Correct format
      }),
    );

    print('IST Time Sent: $istDateTime');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Live link posted successfully: ${response.body}');
      return response.body;
    } else {
      print('Failed to create Live link: ${response.body}');
      throw Exception('Failed to create Live link: ${response.body}');
    }
  }

  Future<String> AdminupdateLIveAPI(
    String token,
    int batchId,
    String liveLink,
    DateTime startTime,
  ) async {
    final url = Uri.parse(
      '$baseUrl/superadmin/updateLiveLink/$batchId',
    ); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'batchId': batchId, // Ensure courseId is passed as a string if required
      'liveLink': liveLink,
      'startTime': startTime,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update course: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  Future<String> AdmindeleteAdminLive(
    int batchId,
    int courseId,
    String token,
  ) async {
    final url = Uri.parse(
      "$baseUrl/superadmin/deleteLiveLink/$batchId/$courseId",
    );
    print("Delete URL: $url");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Live deleted successfully";
      } else {
        throw Exception(
          "Failed to delete live course. Status Code: ${response.statusCode}. Response: ${response.body}",
        );
      }
    } catch (e) {
      print("Exception details: $e");
      throw Exception("Error deleting Live: $e");
    }
  }

  Future<CourseCountsResponse> AdminfetchCourseCounts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/getCount'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return CourseCountsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course counts: ${response.statusCode}');
    }
  }

  Future<BatchTeacherModel> AdminfetchTeachersBatchAPI(
    String token,
    int courseId,
    int batchId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/admin/getTeacherByBatchId/$courseId/$batchId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return BatchTeacherModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch teachers: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> sendResetEmail(String email) async {
    final url = Uri.parse(
      'https://api.portfoliobuilders.in/api/forgotPassword',
    );
    final response = await http.post(
      url,
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  /// Resets the password with OTP and new password
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final url = Uri.parse(
      'https://api.portfoliobuilders.in/api/resetPasswordWithOtp',
    );
    final response = await http.post(
      url,
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<UserResponse> fetchUserDetails(String token, int userId) async {
    final url = Uri.parse('$baseUrl/admin/getDetails/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body:${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch user details: ${response.body}');
      }
    } catch (e) {
      print('Error in API call: $e');
      rethrow;
    }
  }

  Future<bool> adminApprovependinglesson({
    required String token,
    required int lessonId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/admin/handleLessonRequest/$lessonId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status, // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to update lesson: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> adminApprovependingassignment({
    required String token,
    required int assignmentId,
    required String status,
  }) async {
    final url = Uri.parse(
      '$baseUrl/admin/handleAssignmentRequest/$assignmentId',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status, // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to update assignment: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> adminApprovependingquiz({
    required String token,
    required int quizId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/admin/handleQuizRequest/$quizId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status, // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to update quizId: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<LeaveRequest>> AdminfetchgetAllLeaveRequestssAPI(
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllLeaveRequests');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> leave = jsonDecode(response.body)['leaveRequests'];
        return leave.map((item) => LeaveRequest.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch LeaveRequest: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> adminApprovependingleave({
    required String token,
    required int leaveId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/updateLeaveStatus/$leaveId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status, // Ensure consistent casing
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to update leaveId: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<Bug>> AdminfetchgetAllBugsAPI(String token) async {
    final url = Uri.parse('$baseUrl/admin/getBugReports');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> bug = jsonDecode(response.body)['bugs'];
        return bug.map((item) => Bug.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch bugs: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

Future<bool> manageStudentAccessAPI({
  required String token,
  required int studentId,
  required int batchId,
  required String action,
}) async {
  final url = Uri.parse('$baseUrl/superadmin/manageStudentAccess');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'studentId': studentId,
        'batchId': batchId,
        'action': action,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Student access updated successfully: ${response.body}');
      return true;
    } else {
      print('Failed to update student access: ${response.body}');
      throw Exception(
        'Failed to update student access: ${response.reasonPhrase}',
      );
    }
  } catch (e) {
    print('Error in manageStudentAccessAPI: $e');
    throw Exception('Failed to update student access: $e');
  }
}

Future<List<AttendanceHistory>> fetchAttendanceHistory(
  int studentId,
  String token,
) async {
  final url = Uri.parse('$baseUrl/superadmin/getStudentAttendanceHistory/$studentId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Extract the attendance history array from the response
      final List<dynamic> historyList = responseData['attendanceHistory'];
      print('Attendance History array: $historyList'); // Debug print

      return historyList
          .map((item) => AttendanceHistory.fromMap(item))
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load attendance history: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

  
Future<String> updateStudentAttendance(
  String token,
  int attendanceId,
  String status,
) async {
  final url = Uri.parse('$baseUrl/superadmin/editStudentAttendance');

  // Prepare the request payload
  final payload = jsonEncode({
    'attendanceId': attendanceId,
    'status': status,
  });

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: payload,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed to update attendance: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error updating attendance: $e');
    rethrow;
  }
}

Future<List<Transaction>> fetchTransactions(String token, int studentId) async {
  final url = Uri.parse('$baseUrl/superadmin/getTransactions/$studentId');
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      // Check if 'transactions' key exists and is a list
      if (responseBody['transactions'] is List) {
        final List<dynamic> transactions = responseBody['transactions'];
        return transactions
            .map((item) => Transaction.fromJson(item))
            .whereType<Transaction>()
            .toList();
      } else {
        print('No transactions found or invalid format');
        return [];
      }
    } else {
      print('Failed to fetch transactions: ${response.body}');
      throw Exception('Failed to fetch transactions: ${response.body}');
    }
  } catch (e) {
    print('Error fetching transactions: $e');
    rethrow;
  }
}

}
