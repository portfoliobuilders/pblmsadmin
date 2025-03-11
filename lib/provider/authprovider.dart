import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pblmsadmin/contants/gtec_token.dart';
import 'package:pblmsadmin/models/admin_model.dart';
import 'package:pblmsadmin/screens/admin/admin_dashboard.dart';
import 'package:pblmsadmin/screens/admin/login/admin_login.dart';
import 'package:pblmsadmin/services/webservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthProvider with ChangeNotifier {
  void clearModuleData() {
    _courseModules = {};
    notifyListeners();
  }

  String? get errorMessage => _errorMessage;
  String? _errorMessage;

  String? _token;
  String? deleteMessage;
  bool isLoading = false;
  String? message;
  int? _currentUserId;

  int? courseId;

  String? _error;
  CourseCountsResponse? _courseCounts;
  CourseCountsResponse? get courseCounts => _courseCounts;
  String? get error => _error;

  int? assignmentId;
  final Map<int, List<Submission>> _submissions = {};

  List<Submission> get submissionsForAssignment =>
      _submissions[assignmentId] ?? [];
  List<dynamic> getSubmissionsForAssignment(int assignmentId) {
    return _submissions[assignmentId] ?? [];
  }

  List<Admincoursemodel> _course = []; // Correctly store courses

  List<Admincoursemodel> get course => _course;

  List<LeaveRequest> _leave = []; // Correctly store courses

  List<LeaveRequest> get leave => _leave;

  List<Bug> _bug = []; // Correctly store courses

  List<Bug> get bug => _bug;

  final Map<int, List<QuizSubmission>> _quizsubmissions = {};
  Map<int, List<QuizSubmission>> get quizsubmissions => _quizsubmissions;

  final Map<int, List<AdminLiveLinkResponse>> _livebatch = {};

  final Map<int, AdminLiveLinkResponse> _liveBatch = {};

  Future<List<AdminLiveLinkResponse>> SupergetLiveForbatch(int batchId) async {
    if (_livebatch[batchId] == null) {
      await AdminfetchLiveAdmin(batchId); // Make sure the data is fetched
    }
    return _livebatch[batchId] ?? []; // Return the list of live links
  }

  String? get token => _token;

  BatchStudentModel? _batchData;

  // Getter for the batch data
  BatchStudentModel? get batchData => _batchData;
  List<Student> get students => _batchData?.students ?? [];

  UserProfileResponse? _userProfile;
  UserProfileResponse? get userProfile => _userProfile;

  int? get currentUserId => _currentUserId;

  final AdminAPI _apiService = AdminAPI();

  Map<int, List<AdminModulemodel>> _courseModules = {};

  final Map<int, List<AdminLessonmodel>> _moduleLessons = {};

  final Map<int, List<AssignmentModel>> _moduleassignments = {};

  final Map<int, List<AdminQuizModel>> _moduleQuiz = {};

  List<AdminQuizModel> getQuizForModule(int moduleId) {
    return _moduleQuiz[moduleId] ?? [];
  }

  final List<AdminQuizModel> _quizzes = [];

  bool _isLoading = false;

  List<AdminAllusersmodel> _users =
      []; // Add this line to define the _users variable

  List<AdminAllusersmodel>? get users => _users;

  List<UnapprovedUser> _unapprovedUsers = [];
  List<UnapprovedUser>? get unapprovedUsers => _unapprovedUsers;

  final Map<int, List<AdminCourseBatch>> _courseBatches =
      {}; // Map for storing course batches

  // Loading state

  BatchTeacherModel? _batchteacherData;

  BatchTeacherModel? get batchteacherData => _batchteacherData;

  Map<int, List<AdminCourseBatch>> get courseBatches => _courseBatches;

  int? get batchId => null;

  get studentUsers => null;

  get getusers => null;
  List<AdminModulemodel> getModulesForCourse(courseId) {
    return _courseModules[courseId] ?? [];
  }

  List<AdminLessonmodel> getLessonsForModule(int moduleId) {
    return _moduleLessons[moduleId] ?? [];
  }

  List<AssignmentModel> getAssignmentsForModule(int moduleId) {
    return _moduleassignments[moduleId] ?? [];
  }

  // Modify this method to return a Future<List<AdminLiveLinkResponse>> instead of just a list
  Future<List<AdminLiveLinkResponse>> getLiveForbatch(int batchId) async {
    if (_livebatch[batchId] == null) {
      await AdminfetchLiveAdmin(batchId); // Make sure the data is fetched
    }
    return _livebatch[batchId] ?? []; // Return the list of live links
  }

  // Superadmin login
  Future<void> adminloginprovider(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await _apiService.loginAdminAPI(email, password);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _currentUserId = responseData['userId'];

        // Save the token
        await saveToken(_token!);

        // Only fetch profile if we have a valid userId
        if (_currentUserId != null) {
          await fetchUserProfileProvider(_currentUserId!);
        }

        // Rest of your login logic...
        await AdminfetchCoursesprovider();
        await AdminfetchUnApprovedusersProvider();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );

        notifyListeners();
      }
      // Rest of your error handling...
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please check your details.'),
        ),
      );
    }
  }

  Future<void> Adminregisterprovider(
    String email,
    String password,
    String name,
    String role,
    String phoneNumber,
  ) async {
    try {
      await _apiService.AdminRegisterAPI(
        email,
        password,
        name,
        role,
        phoneNumber,
      );
    } catch (e) {
      print('Error creating register: $e');
      throw Exception('Failed to create register');
    }
  }

  // Logout method
  Future<void> Superlogout() async {
    await clearToken();
    _token = null;
    notifyListeners();
  }

  // Check authentication and automatically fetch courses if authenticated
  Future<void> AdmincheckAuthprovider(BuildContext context) async {
    _token = await getToken();

    // Check if the token exists (indicating the user is logged in)
    if (_token != null) {
      // Navigate to StudentLMSHomePage if the user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
      );
    } else {
      // Navigate to UserLogin page if the user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginScreen()),
      );
    }
    notifyListeners();
  }

  Future<void> savecourseId(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('courseId', courseId);
  }

  Future<void> AdminfetchCoursesprovider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _course = await _apiService.AdminfetchCoursesAPI(_token!);

      if (_course.isNotEmpty) {
        int courseId =
            _course.first.courseId; // Assuming 'id' is the course ID field
        await savecourseId(courseId); // Store courseId
        print('Saved Course ID: $courseId');
      }

      print('Fetched courses: $_course');
      notifyListeners();
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  Future<int?> getSavedCourseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('courseId'); // Retrieve stored courseId
  }

  // Create a new course
  Future<void> AdmincreateCourseprovider(
    String title,
    String description,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.AdmincreateCourseAPI(title, description, _token!);
      await AdminfetchCoursesprovider(); // Refresh the course list after creation
    } catch (e) {
      print('Error creating course: $e');
      throw Exception('Failed to create course');
    }
  }

  Future<void> AdmindeleteCourseprovider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminCourse(courseId, _token!);
      print(result); // Optionally print success message

      await AdminfetchCoursesprovider();
    } catch (e) {
      print('Error deleting course: $e');
    }
  }

  Future<void> AdminupdateCourse(
    int courseId,
    String title,
    String description,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateCourseAPI(
        _token!,
        courseId,
        title,
        description,
      );
      await AdminfetchCoursesprovider(); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

  Future<void> AdminfetchModulesForCourseProvider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final modules = await _apiService.AdminfetchModulesForCourseAPI(
        _token!,
        courseId,
      );
      _courseModules[courseId] = modules;
      notifyListeners();
    } catch (e) {
      print('Error fetching modules for course: $e');
      throw Exception('Failed to fetch modules for course');
    }
  }

  Future<void> Admincreatemoduleprovider(
    String title,
    String content,
    int courseId,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating module for courseId: $courseId,$batchId');

      // Call API to create the module
      await _apiService.AdmincreatemoduleAPI(_token!, courseId, title, content);

      print('Module creation successful. Fetching updated modules...');

      // Fetch updated modules after creation
      await AdminfetchModulesForCourseProvider(courseId);

      print('Modules fetched successfully.');
    } catch (e) {
      print('Error creating module: $e');
      throw Exception('Failed to create module');
    }
  }

  Future<void> admindeletemoduleprovider(int courseId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminmodule(
        courseId,
        _token!,
        moduleId,
      );
      print(result); // Optionally print success message

      if (_courseModules.containsKey(courseId)) {
        _courseModules[courseId]?.removeWhere(
          (module) => module.moduleId == moduleId,
        );
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchModulesForCourseProvider(courseId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> AdminUpdatemoduleprovider(
    int courseId,
    String title,
    String content,
    int moduleId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateModuleAPI(
        _token!,
        courseId,
        title,
        content,
        moduleId,
      );
      await AdminfetchModulesForCourseProvider(
        courseId,
      ); // Refresh the course list after update
    } catch (e) {
      print('Error updating module: $e');
      throw Exception('Failed to update module');
    }
  }

  Future<void> AdminfetchLessonsForModuleProvider(
    int courseId,
    int moduleId,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final lessons = await _apiService.AdminfetchLessonsForModuleAPI(
        _token!,
        courseId,

        moduleId,
      );
      _moduleLessons[moduleId] = lessons;
      notifyListeners();
    } catch (e) {
      print('Error fetching lessons for module: $e');
      rethrow;
    }
  }

  Future<void> Admincreatelessonprovider(
    int courseId,
    int moduleId,
    String content,
    String title,
    String videoLink,
    String pdfUrl,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating lesson for courseId: $courseId');
      print('Creating lesson for moduleId: $moduleId');

      // Call API to create the lesson
      await _apiService.AdmincreatelessonseAPI(
        _token!,
        courseId,
        moduleId,
        content,
        title,
        videoLink,
        pdfUrl,
      );

      print('Lesson creation successful. Fetching updated lessons...');

      // Fetch updated lessons after creation
      await AdminfetchLessonsForModuleProvider(courseId, moduleId);

      print('Lessons fetched successfully.');
    } catch (e) {
      print('Error creating lesson: $e');
      throw Exception('Failed to create lesson: $e');
    }
  }

  Future<void> admindeletelessonprovider(
    int courseId,
    int moduleId,
    int lessonId,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminlesson(_token!, lessonId);
      print(result); // Optionally print success message

      if (_courseModules.containsKey(courseId)) {
        _moduleLessons[moduleId]?.removeWhere(
          (lesson) => lesson.lessonId == lessonId,
        );
        notifyListeners();

        // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchLessonsForModuleProvider(courseId, moduleId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> AdminUpdatelessonprovider(
  int courseId,
  String title,
  String content,
  int lessonId,
  int moduleId,
  String videoLink,
  String pdfUrl,
) async {
  if (_token == null) throw Exception('Token is missing');
  
  try {
    await _apiService.AdminupdateLessonAPI(
      _token!,
      courseId,
      title,
      content,
      moduleId,
      lessonId,
      videoLink,
      pdfUrl,
    );
    
    // Refresh the lessons list
    await AdminfetchLessonsForModuleProvider(courseId, moduleId);
    
    notifyListeners();
  } catch (e) {
    print('Error updating lesson: $e');
    throw Exception('Failed to update lesson: $e');
  }
}

  Future AdminCreateBatchProvider(
    String batchName,
    int courseId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_token == null) {
      throw Exception('Authentication token is missing');
    }

    // Validate required fields
    if (courseId <= 0) {
      throw Exception('Invalid courseId');
    }
    if (batchName.trim().isEmpty) {
      throw Exception('Batch name is required');
    }

    try {
      final result = await _apiService.adminCreateBatch(
        _token!,
        courseId,
        batchName.trim(),
        startDate,
        endDate,
      );

      // Update the local state with the new batch
      final currentBatches = courseBatches[courseId] ?? [];
      courseBatches[courseId] = [...currentBatches, result];
      notifyListeners();
    } catch (e) {
      print('Error in AdminCreateBatchProvider: $e');
      rethrow;
    }
  }

  Future<void> AdminfetchBatchForCourseProvider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      _isLoading = true; // Set loading to true
      notifyListeners(); // Notify listeners that the loading state has changed

      final Batches = await _apiService.AdminfetctBatchForCourseAPI(
        _token!,
        courseId,
      );
      _courseBatches[courseId] = Batches; // Store fetched batches

      _isLoading = false; // Set loading to false once data is fetched
      notifyListeners(); // Notify listeners that the loading state has changed
    } catch (e) {
      _isLoading = false; // Set loading to false if there’s an error
      notifyListeners(); // Notify listeners that the loading state has changed
      print('Error fetching batch for course: $e');
      throw Exception('Failed to fetch batch for course');
    }
  }

  Future<void> AdminUpdatebatchprovider(
    int courseId,
    int batchId,
    String batchName,
    String medium,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.AdminupdateBatchAPI(
        _token!,
        courseId,
        batchId,
        batchName,
        medium,
        startDate,
        endDate,
      );
      await AdminfetchBatchForCourseProvider(courseId);
    } catch (e) {
      print('Error updating batch: $e');
      throw Exception('Failed to update batch');
    }
  }

  Future<void> AdmindeleteBatchprovider(
    int courseId,
    int batchId,
    String medium,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminBatch(
        courseId,
        _token!,
        batchId,
      );
      print(result); // Optionally print success message

      if (_courseBatches.containsKey(courseId)) {
        _courseBatches[courseId]?.removeWhere(
          (Batche) => Batche.batchId == batchId,
        );
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchModulesForCourseProvider(courseId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> AdminfetchallusersProvider() async {
    if (_token == null) {
      _errorMessage = 'Token is missing';
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final fetchedUsers = await _apiService.fetchAdminUsers(_token!);
      _users = fetchedUsers;

      // Print the fetched users for debugging
      print('Fetched users: $_users');
    } catch (e) {
      _errorMessage = 'Error fetching users: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when data is updated
    }
  }

  Future<void> assignUserToBatchProvider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.AdminassignUserToBatch(
        token: _token!,
        courseId: courseId,
        batchId: batchId,
        userId: userId,
      );

      if (isSuccess) {
        print('User successfully assigned to batch.');
        notifyListeners(); // Notify listeners if needed
      }
    } catch (e) {
      print('Error assigning user to batch: $e');
    }
  }

  Future<void> AdmindeleteUserFromBatchprovider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.AdmindeleteUserFromBatch(
        token: _token!,
        courseId: courseId,
        batchId: batchId,
        userId: userId,
      );

      if (isSuccess) {
        print('User successfully assigned to batch.');
        notifyListeners(); // Notify listeners if needed
      }
    } catch (e) {
      print('Error assigning user to batch: $e');
    }
  }

  Future<void> adminApproveUserprovider({
    required int userId,
    required String role,
    required String action, // 'approve' or 'reject'
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.adminApproveUser(
        token: _token!,
        userId: userId,
        role: role,
        action: action,
      );

      if (isSuccess) {
        print('User successfully ${action}ed.');
        notifyListeners();
      }
    } catch (e) {
      print('Error processing user approval/rejection: $e');
      rethrow; // Rethrow to handle in UI
    }
    await AdminfetchallusersProvider();
  }

  Future<void> AdminUploadlessonprovider(
    int courseId,
    int batchId,
    String title,
    String content,
    int lessonId,
    int moduleId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminuploadLessonFile(
        _token!,
        courseId,
        batchId,
        title,
        content,
        moduleId,
        lessonId,
      );

      // Refresh the lessons list
      await AdminfetchLessonsForModuleProvider(courseId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error uploading lesson: $e');
      throw Exception('Failed to upload lesson: $e');
    }
  }

  Future<void> fetchQuizzesForModuleProvider(int courseId, int moduleId) async {
    if (_token == null) {
      throw Exception('Token is missing');
    }

    try {
      print('Fetching quizzes for Course: $courseId, Module: $moduleId');

      // Fetch quizzes from the API service
      final quizzes = await _apiService.fetchQuizzes(
        _token!,
        courseId,
        moduleId,
      );

      // Update the local quiz map
      _moduleQuiz[moduleId] = quizzes;

      print('Fetched ${quizzes.length} quizzes for Module $moduleId');
      notifyListeners();
    } catch (e, stackTrace) {
      print('Error in provider while fetching quizzes: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow the exception for further handling
    }
  }

  Future<void> createAssignmentProvider({
    required int courseId,
    required int moduleId,
    required String title,
    required String description,
    required String dueDate,
  }) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.createAssignmentAPI(
        token: _token!,
        courseId: courseId,
        moduleId: moduleId,
        title: title,
        description: description,
        dueDate: dueDate,
      );

      // Optionally, fetch updated data or provide UI feedback
      notifyListeners();
    } catch (e) {
      print('Error creating assignment: $e');
      throw Exception('Failed to create assignment');
    }
    await fetchAssignmentForModuleProvider(courseId, moduleId);
  }

  Future<void> fetchAssignmentForModuleProvider(
    int courseId,
    int moduleId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      print('Fetching assignments for Course: $courseId, Module: $moduleId');
      final assignments = await _apiService.fetchAssignmentForModuleAPI(
        _token!,
        courseId,
        moduleId,
      );

      _moduleassignments[moduleId] = assignments;
      print('Fetched ${assignments.length} assignments');
      notifyListeners();
    } catch (e, stackTrace) {
      print('Error in provider while fetching assignments: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> admindeleteassignmentprovider(
    int courseId,
    int moduleId,
    int assignmentId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final result = await _apiService.deleteAdminAssignmentAPI(
        _token!,
        assignmentId,
        courseId,
        moduleId,
      );
      print(result);

      // Update the local state
      _moduleassignments[moduleId]?.removeWhere(
        (assignment) => assignment.assignmentId == assignmentId,
      );
      notifyListeners();

      // Fetch updated assignments list
      await fetchAssignmentForModuleProvider(courseId, moduleId);
    } catch (e) {
      print('Error deleting assignment: $e');
      throw Exception('Failed to delete assignment');
    }
  }

  Future<void> AdminUpdateAssignment(
    int courseId,
    String title,
    String description,
    int assignmentId,
    int moduleId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.adminupdateAssignmentAPI(
        // Corrected function name
        _token!,
        courseId,
        title,
        description,
        moduleId,
        assignmentId,
      );

      // Update this to fetch assignments instead of lessons
      await fetchAssignmentForModuleProvider(courseId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error updating assignment: $e');
      throw Exception('Failed to update assignment: $e');
    }
  }

  Future<void> AdminfetchallusersBatchProvider(
    int courseId,
    int batchId,
  ) async {
    if (_token == null) {
      _error = 'Token is missing';
      notifyListeners();
      throw Exception(_error);
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.AdminfetchUsersBatchAPI(
        _token!,
        courseId,
        batchId,
      );

      _batchData = response;
      _isLoading = false;
      print('Fetched batch data: $_batchData');
      print('Number of students: ${_batchData?.students.length}');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error fetching users: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> AdminfetchUnApprovedusersProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      // Update the list with fetched data
      _unapprovedUsers = await _apiService.AdminfetchUnApprovedUsersAPI(
        _token!,
      );
      print('Fetched unapproved users: $_unapprovedUsers');
      notifyListeners();
    } catch (e) {
      print('Error fetching unapproved users: $e');
      // In case of error, keep the list empty but not null
      _unapprovedUsers = [];
      notifyListeners();
    }
  }

  Future<void> fetchUserProfileProvider(int userId) async {
    if (_token == null) {
      print('Token is missing');
      return;
    }

    try {
      final response = await _apiService.fetchUserProfile(_token!, userId);
      _userProfile = response;
      print('Fetched user profile: ${_userProfile?.profile.name}');
      notifyListeners();
    } catch (e) {
      print('Error fetching user profile: $e');
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<void> fetchSubmissions(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final submissions = await _apiService.fetchSubmission(
        assignmentId,
        _token!,
      );
      _submissions[assignmentId] = submissions;
    } catch (e) {
      print('Error fetching submissions: $e');
      _submissions[assignmentId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizSubmissions(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final quizsubmissions = await _apiService.fetchQuizAnswers(
        quizId,
        _token!,
      );
      _quizsubmissions[quizId] = quizsubmissions;
    } catch (e) {
      _quizsubmissions[quizId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuizProvider(
    int courseId,
    int moduleId,
    int quizId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      print(
        "Calling API to delete quiz: Course=$courseId, Module=$moduleId, Quiz=$quizId",
      );

      await _apiService.AdmindeleteQuizAPI(
        token: _token!,
        courseId: courseId,
        moduleId: moduleId,
        quizId: quizId,
      );

      print("Quiz deleted successfully from API. Now updating local state...");

      // Remove the quiz from the moduleQuiz map
      if (_moduleQuiz.containsKey(moduleId)) {
        _moduleQuiz[moduleId]?.removeWhere((quiz) => quiz.quizId == quizId);

        // If the module has no more quizzes, remove the module entry
        if (_moduleQuiz[moduleId]!.isEmpty) {
          _moduleQuiz.remove(moduleId);
        }
      }

      notifyListeners(); // Ensure UI updates
    } catch (e) {
      print('Error in deleteQuizProvider: $e');
      throw Exception('Unable to delete quiz. Please try again later.');
    }
  }

  Future<void> refreshQuizzes(int courseId, int moduleId) async {
    try {
      final updatedQuizzes = await _apiService.fetchQuizzes(
        _token!,
        courseId,
        moduleId,
      );
      _moduleQuiz[moduleId] = updatedQuizzes;
      notifyListeners();
    } catch (e) {
      print('Error refreshing quizzes: $e');
    }
  }

  Future<void> updateQuizProvider({
    required int quizId,
    required String name,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    // Validate input data
    if (name.isEmpty) throw Exception('Quiz name cannot be empty');
    if (description.isEmpty) {
      throw Exception('Quiz description cannot be empty');
    }
    if (questions.isEmpty) {
      throw Exception('Quiz must have at least one question');
    }

    try {
      await _apiService.updateQuizAPI(
        token: _token!,
        quizId: quizId,
        data: {
          'name': name,
          'description': description,
          'questions': questions,
        },
      );

      notifyListeners();
    } catch (e) {
      print('Error in updateQuizProvider: $e');
      throw Exception('Failed to update quiz: $e');
    }
  }

  Future<void> updateQuestionProvider({
    required int quizId,
    required int questionId,
    required String text,
    required List<Map<String, dynamic>> answers,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.updateQuestionAPI(
        token: _token!,
        quizId: quizId,
        questionId: questionId,
        data: {'text': text, 'answers': answers},
      );

      notifyListeners();
    } catch (e) {
      print('Error in updateQuestionProvider: $e');
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestionProvider({
    required int quizId,
    required int questionId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.deleteQuestionAPI(
        token: _token!,
        quizId: quizId,
        questionId: questionId,
      );

      // Update local state if needed
      notifyListeners();
    } catch (e) {
      // Log the error for debugging
      print('Error in deleteQuestionProvider: $e');

      // Rethrow with a more user-friendly message
      if (e.toString().contains('Question not found')) {
        throw Exception('Question not found or already deleted');
      } else if (e.toString().contains('Network error')) {
        throw Exception('Please check your internet connection and try again');
      } else {
        throw Exception('Unable to delete question. Please try again later.');
      }
    }
  }

  Future<AdminLiveLinkResponse?> AdminfetchLiveAdmin(int batchId) async {
    if (_token == null) {
      print('Error: Token is null. Please authenticate first.');
      return null; // Return null instead of throwing an exception
    }

    try {
      final liveData = await _apiService.AdminfetchLiveAdmin(_token!, batchId);
      _liveBatch[batchId] = liveData!;
      notifyListeners(); // Trigger UI rebuild
      return liveData;
    } catch (error) {
      print('Failed to fetch live data: $error');
      return null; // Return null so UI can handle it gracefully
    }
  }

  Future<void> AdmincreateLivelinkprovider(
    int batchId,
    String liveLink,
    DateTime liveStartTime,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      // Remove courseId reference as it's not needed or defined
      print('Creating LiveLink for batchId: $batchId');

      // Call API to create the live link
      await _apiService.AdminpostLiveLink(
        _token!,
        batchId,
        liveLink,
        liveStartTime,
      );

      print('LiveLink creation successful. Fetching updated live data...');
      // Fetch updated live data after creation
      await AdminfetchLiveAdmin(batchId);
      print('LiveLink created and data refreshed successfully.');
    } catch (e) {
      print('Error creating LiveLink: $e');
      // Modify this condition to not reference courseId
      if (e.toString().contains("Batch not found")) {
        throw Exception('Batch ID $batchId not found. Please verify.');
      } else {
        throw Exception('Failed to create LiveLink: $e');
      }
    }
  }

  Future<void> AdminupdateLive(
    int batchId,
    String liveLink,
    DateTime startTime,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateLIveAPI(
        _token!,
        batchId,
        liveLink,
        startTime,
      );
      await AdminfetchLiveAdmin(
        batchId,
      ); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

  Future<void> AdmindeleteLiveprovider(int courseId, int batchId) async {
    if (_token == null || _token!.isEmpty) {
      throw Exception('Invalid or missing token');
    }
    try {
      // Fix: Change parameter order to match API expectation
      final result = await _apiService.AdmindeleteAdminLive(
        batchId,
        courseId,
        _token!,
      );
      print("Delete result: $result");
      notifyListeners();
    } catch (e) {
      print('Error in provider while deleting: $e');
      rethrow;
    }
  }

  Future<void> AdminfetchCourseCountsProvider() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courseCounts = await _apiService.AdminfetchCourseCounts(_token!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> AdminfetchallteachersBatchProvider(
    int courseId,
    int batchId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.AdminfetchTeachersBatchAPI(
        _token!,
        courseId,
        batchId,
      );

      _batchteacherData = response;
      print('Fetched batch data: $_batchteacherData');
      print('Number of teachers: ${_batchteacherData?.teachers.length}');

      notifyListeners();
    } catch (e) {
      print('Error fetching teachers: $e');
      rethrow;
    }
  }

  Future<void> sendResetEmail(String email, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      bool success = await _apiService.sendResetEmail(email);
      if (success) {
        Navigator.pop(context); // Close the email input dialog
        ForgotPasswordHandler.showOtpPopup(
          context,
          email,
        ); // Open the OTP dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Resets password and navigates to login page
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
    BuildContext context,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      bool success = await _apiService.resetPassword(email, otp, newPassword);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password Reset Successfully!')));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminLoginScreen()),
          (route) => false, // Clear navigation stack
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  UserResponse? _user;

  UserResponse? get user => _user;

  Future<void> fetchUserDetails(int userId) async {
    if (_token == null) {
      print('Token is missing');
      return;
    }
    try {
      final response = await _apiService.fetchUserDetails(_token!, userId);
      _user = response;
      notifyListeners();
    } catch (e) {
      print('Error fetching user details: $e');
      _user = null;
      notifyListeners();
    }
  }

  Future<void> adminApprovelessonsprovider({
    required int lessonId,
    required String status,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.adminApprovependinglesson(
        token: _token!,
        lessonId: lessonId,
        status: status,
      );

      if (isSuccess) {
        print('lesson approved');
        notifyListeners();
      }
    } catch (e) {
      print('Error processing user approval/rejection: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> adminApproveassignmentprovider({
    required int assignmentId,
    required String status,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.adminApprovependingassignment(
        token: _token!,
        assignmentId: assignmentId,
        status: status,
      );

      if (isSuccess) {
        print('assignment approved');
        notifyListeners();
      }
    } catch (e) {
      print('Error processing assignment approval/rejection: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> adminApprovequizprovider({
    required int quizId,
    required String status,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.adminApprovependingquiz(
        token: _token!,
        quizId: quizId,
        status: status,
      );

      if (isSuccess) {
        print('quiz approved');
        notifyListeners();
      }
    } catch (e) {
      print('Error processing user approval/rejection: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Fetch courses from the API
  Future<void> Adminfetchleaveprovider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _leave = await _apiService.AdminfetchgetAllLeaveRequestssAPI(_token!);
      // Print the fetched leave requests to the terminal
      print('Fetched leave requests: $_leave'); // Fixed to print _leave
      notifyListeners(); // Notify listeners that leave requests are fetched
    } catch (e) {
      print('Error fetching leave requests: $e');
    }
  }

  Future<void> adminApproveleaveprovider({
    required int leaveId,
    required String status,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.adminApprovependingleave(
        token: _token!,
        leaveId: leaveId, // Check this is being sent correctly
        status: status,
      );

      if (isSuccess) {
        print('Leave request processed successfully');
        notifyListeners();
      } else {
        print('Failed to process leave request');
      }
    } catch (e) {
      print('Error processing leave approval/rejection: $e');
      rethrow;
    }
  }

  Future<void> Adminfetchbugs() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _bug = await _apiService.AdminfetchgetAllBugsAPI(
        _token!,
      ); // Fetch courses correctly

      // Print the fetched courses to the terminal
      print('Fetched bugs: $_course');

      notifyListeners(); // Notify listeners that courses are fetched
    } catch (e) {
      print('Error fetching bugs: $e');
    }
  }

  Future<void> manageStudentAccess({
    required int studentId,
    required int batchId,
    required String action,
  }) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final isSuccess = await _apiService.manageStudentAccessAPI(
        token: _token!,
        studentId: studentId,
        batchId: batchId,
        action: action,
      );
      if (isSuccess) {
        print('Student access updated successfully');
        notifyListeners();
      }
    } catch (e) {
      print('Error managing student access: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  List<AttendanceHistory> _attendanceHistory = [];

  List<AttendanceHistory> get attendanceHistory => _attendanceHistory;

  Future<void> fetchAttendanceHistoryProvider(int studentId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.fetchAttendanceHistory(
        studentId,
        _token!,
      );

      _attendanceHistory = response;
      print('Fetched attendance history: $_attendanceHistory');
      print('Number of records: ${_attendanceHistory.length}');

      notifyListeners();
    } catch (e) {
      print('Error fetching attendance history: $e');
      rethrow;
    }
  }

  Future<void> updateStudentAttendance({
    required int attendanceId,
    required String status,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      // Call API to update attendance
      await _apiService.updateStudentAttendance(_token!, attendanceId, status);

      // Update local list
      final index = _attendanceHistory.indexWhere(
        (att) => att.id == attendanceId,
      );
      if (index != -1) {
        // Create a new instance with updated status
        final updatedAttendance = AttendanceHistory(
          id: _attendanceHistory[index].id,
          studentId: _attendanceHistory[index].studentId,
          batchId: _attendanceHistory[index].batchId,
          date: _attendanceHistory[index].date,
          status: status,
          createdAt: _attendanceHistory[index].createdAt,
          updatedAt:
              DateTime.now().toIso8601String(), // Update with current timestamp
          studentBatch: _attendanceHistory[index].studentBatch,
        );

        _attendanceHistory[index] = updatedAttendance;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Future<void> fetchStudentTransactions({
    required int studentId,
    String? token,
  }) async {
    if (token != null) _token = token;

    if (_token == null) {
      throw Exception('Token is missing');
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _apiService.fetchTransactions(_token!, studentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
