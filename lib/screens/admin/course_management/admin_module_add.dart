import 'package:flutter/material.dart';
import 'package:pblmsadmin/models/admin_model.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:pblmsadmin/screens/admin/course_management/asignment_submission.dart';
import 'package:pblmsadmin/screens/admin/course_management/quiz_submission.dart';
import 'package:pblmsadmin/screens/admin/widgets/videoplayer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class AdminModuleAddScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const AdminModuleAddScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<AdminModuleAddScreen> createState() => _AdminModuleAddScreenState();
}

class _AdminModuleAddScreenState extends State<AdminModuleAddScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  AdminModulemodel? selectedModule;
  bool isLoading = false;
  AdminLessonmodel? selectedLesson;
  bool isFabMenuOpen = false;
  late AnimationController _animationController;
  int? selectedQuizId;
  int? selectedAssignmentId;

  final primaryBlue = Color(0xFF2E7D32);
  final mediumBlue = Color.fromARGB(255, 41, 147, 46);
  final lightBlue = Color.fromARGB(255, 155, 246, 159);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      isFabMenuOpen = !isFabMenuOpen;
      if (isFabMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Load both modules and batch data
    _loadInitialData();
  }

  // New method to handle all initial data loading
  Future<void> _loadInitialData() async {
    // Load modules
    await _loadModules();

    // Load batch data
    // final adminProvider = Provider.of<AdminAuthProvider>(
    //   context,
    //   listen: false,
    // );
    // await adminProvider.AdminfetchallusersBatchProvider(
    //   widget.courseId,
    //   widget.batchId,
    // );
  }

  Future<void> _loadModules() async {
    await Provider.of<AdminAuthProvider>(
      context,
      listen: false,
    ).AdminfetchModulesForCourseProvider(widget.courseId);
  }

  Future<void> _loadLessonsAndAssignmentsquiz() async {
    if (selectedModule != null) {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);

      await provider.AdminfetchLessonsForModuleProvider(
        widget.courseId,
        selectedModule!.moduleId,
      );

      await provider.fetchAssignmentForModuleProvider(
        widget.courseId,
        selectedModule!.moduleId,
      );
      await provider.fetchQuizzesForModuleProvider(
        widget.courseId,
        selectedModule!.moduleId,
      );
    }
  }

  void _showEditAssignmentDialog(
    BuildContext context,
    AssignmentModel assignment,
  ) {
    final TextEditingController editAssignmentTitleController =
        TextEditingController(text: assignment.title);
    final TextEditingController editAssignmentDescriptionController =
        TextEditingController(text: assignment.description);
    final TextEditingController editDueDateController = TextEditingController(
      text: assignment.dueDate.toIso8601String().split('T')[0],
    );
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Assignment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600, // Set desired dialog width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editAssignmentTitleController,
                      decoration: InputDecoration(
                        labelText: 'Assignment Title*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editAssignmentDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Assignment Content*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editDueDateController,
                      decoration: InputDecoration(
                        labelText: 'Due Date (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            isUpdating
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isUpdating
                                ? null
                                : () async {
                                  if (editAssignmentTitleController.text
                                          .trim()
                                          .isEmpty ||
                                      editAssignmentDescriptionController.text
                                          .trim()
                                          .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill all required fields',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isUpdating = true;
                                  });

                                  try {
                                    final provider =
                                        Provider.of<AdminAuthProvider>(
                                          context,
                                          listen: false,
                                        );

                                    await provider.AdminUpdateAssignment(
                                      widget.courseId,
                                      editAssignmentTitleController.text.trim(),
                                      editAssignmentDescriptionController.text
                                          .trim(),
                                      assignment.assignmentId,
                                      selectedModule!.moduleId,
                                    );

                                    Navigator.of(context).pop();

                                    // Refresh assignments
                                    await _loadLessonsAndAssignmentsquiz();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Assignment updated successfully!',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating assignment: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isUpdating = false;
                                    });
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            isUpdating
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditLessonDialog(BuildContext context, AdminLessonmodel lesson) {
    final TextEditingController editTitleController = TextEditingController(
      text: lesson.title,
    );
    final TextEditingController editContentController = TextEditingController(
      text: lesson.content,
    );
    final TextEditingController editVideoLinkController = TextEditingController(
      text: lesson.videoLink,
    );
    final TextEditingController editPdfUrlController = TextEditingController(
      text: lesson.pdfPath ?? '',
    );
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Lesson',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600, // Set desired dialog width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        labelText: 'Lesson Title*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editContentController,
                      decoration: InputDecoration(
                        labelText: 'Lesson Content*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editVideoLinkController,
                      decoration: InputDecoration(
                        labelText: 'Video Link (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editPdfUrlController,
                      decoration: InputDecoration(
                        labelText: 'PDF URL (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            isUpdating
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isUpdating
                                ? null
                                : () async {
                                  if (editTitleController.text.trim().isEmpty ||
                                      editContentController.text
                                          .trim()
                                          .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill all required fields',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isUpdating = true;
                                  });

                                  try {
                                    final provider =
                                        Provider.of<AdminAuthProvider>(
                                          context,
                                          listen: false,
                                        );

                                    await provider.AdminUpdatelessonprovider(
                                      widget.courseId,
                                      editTitleController.text.trim(),
                                      editContentController.text.trim(),
                                      lesson.lessonId,
                                      selectedModule!.moduleId,
                                      editVideoLinkController.text.trim(),
                                      editPdfUrlController.text.trim(),
                                    );

                                    Navigator.of(context).pop();

                                    await _loadLessonsAndAssignmentsquiz();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lesson updated successfully!',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating lesson: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isUpdating = false;
                                    });
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            isUpdating
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditModuleDialog(BuildContext context, AdminModulemodel module) {
    final TextEditingController editTitleController = TextEditingController(
      text: module.title,
    );
    final TextEditingController editContentController = TextEditingController(
      text: module.content,
    );
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Module',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        labelText: 'Module Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editContentController,
                      decoration: InputDecoration(
                        labelText: 'Module Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            isUpdating
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isUpdating
                                ? null
                                : () async {
                                  if (editTitleController.text.trim().isEmpty ||
                                      editContentController.text
                                          .trim()
                                          .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill all required fields',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isUpdating = true;
                                  });

                                  try {
                                    final provider =
                                        Provider.of<AdminAuthProvider>(
                                          context,
                                          listen: false,
                                        );

                                    await provider.AdminUpdatemoduleprovider(
                                      widget.courseId,
                                      editTitleController.text.trim(),
                                      editContentController.text.trim(),
                                      module.moduleId,
                                    );

                                    Navigator.of(context).pop();
                                    await _loadModules();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Module updated successfully!',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating module: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isUpdating = false;
                                    });
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            isUpdating
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateModuleDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Create Module',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Module Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Module Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            isCreating
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isCreating
                                ? null
                                : () async {
                                  if (titleController.text.trim().isEmpty ||
                                      contentController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill all required fields',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isCreating = true;
                                  });

                                  try {
                                    final provider =
                                        Provider.of<AdminAuthProvider>(
                                          context,
                                          listen: false,
                                        );

                                    await provider.Admincreatemoduleprovider(
                                      titleController.text.trim(),
                                      contentController.text.trim(),
                                      widget.courseId,
                                    );

                                    Navigator.of(context).pop();
                                    await _loadModules();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Module created successfully!',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error creating module: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isCreating = false;
                                    });
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            isCreating
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Create',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModuleDropdown(List<AdminModulemodel> modules) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, size: 24, color: primaryBlue),
              const SizedBox(width: 12),
              Text(
                'SELECT MODULE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              setState(() {
                isExpanded = !isExpanded;
              });
              if (selectedModule != null) {
                await _loadLessonsAndAssignmentsquiz();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: lightBlue),
                borderRadius: BorderRadius.circular(12),
                color: Color.fromARGB(255, 198, 247, 201),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Module',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (modules.isNotEmpty)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color(0xFF2E7D32),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && modules.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: modules.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final isSelected =
                      selectedModule?.moduleId == module.moduleId;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedModule = module;
                        isExpanded = false;
                      });
                      Provider.of<AdminAuthProvider>(context, listen: false);
                      _loadLessonsAndAssignmentsquiz();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color:
                          isSelected
                              ? Color.fromARGB(255, 198, 255, 201)
                              : null,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.green.shade100
                                      : Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? Colors.green.shade900
                                          : Colors.green.shade700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? Colors.green.shade900
                                            : Colors.black87,
                                  ),
                                ),
                                if (module.content.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    module.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedModuleCard(AdminModulemodel module) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  module.content.isNotEmpty
                      ? module.content
                      : 'No module description provided',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_note,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () => _showEditModuleDialog(context, module),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () => _handleDeleteModule(module),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteModule(AdminModulemodel module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Module'),
            content: const Text('Are you sure you want to delete this module?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<AdminAuthProvider>(context, listen: false);
        await provider.admindeletemoduleprovider(
          widget.courseId,
          module.moduleId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module deleted successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete module: $error')),
        );
      }
    }
  }

  Widget _buildLessonsAndAssignmentsquizView() {
    if (selectedModule == null) {
      print('UI: No module selected');
      return const SizedBox.shrink();
    }

    return Consumer<AdminAuthProvider>(
      builder: (context, provider, child) {
        final lessons = provider.getLessonsForModule(selectedModule!.moduleId);
        final assignments = provider.getAssignmentsForModule(
          selectedModule!.moduleId,
        );
        final quiz = provider.getQuizForModule(selectedModule!.moduleId);

        print('UI: Building section for module ${selectedModule!.moduleId}');
        print(
          'UI: Found ${lessons.length} lessons, ${assignments.length} assignments, and ${quiz.length} quizzes',
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lessons Section
              Row(
                children: [
                  Icon(Icons.library_books, size: 24, color: primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    'LESSONS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (lessons.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No lessons available for this module',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                _buildLessonsList(lessons),

              // Assignments Section
              const SizedBox(height: 32),
              Row(
                children: [
                  Icon(Icons.assignment, size: 24, color: primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    'ASSIGNMENTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (assignments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No assignments available for this module',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                _buildAssignmentsList(assignments),

              // Quizzes Section
              // const SizedBox(height: 32),
              // Row(
              //   children: [
              //     Icon(Icons.quiz, size: 24, color: primaryBlue),
              //     const SizedBox(width: 12),
              //     Text(
              //       'QUIZZES',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.grey[700],
              //         letterSpacing: 1.2,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),
              // if (quiz.isEmpty)
              //   Center(
              //     child: Padding(
              //       padding: const EdgeInsets.all(16.0),
              //       child: Text(
              //         'No quizzes available for this module',
              //         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              //       ),
              //     ),
              //   )
              // else
              //   _buildQuizList(quiz),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizList(List<AdminQuizModel> quiz) {
    if (quiz.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.quiz, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No quiz available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: quiz.length,
      itemBuilder: (context, index) {
        final quizItem = quiz[index];
        final isPending = quizItem.status == "pending approval";

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (isPending) {
                _showApprovalDialog2(context, quizItem);
              } else {
                setState(() {
                  selectedQuizId =
                      selectedQuizId == quizItem.quizId
                          ? null
                          : quizItem.quizId;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    selectedQuizId == quizItem.quizId
                        ? lightBlue.withOpacity(0.3)
                        : Colors.white,
                border: Border.all(
                  color:
                      selectedQuizId == quizItem.quizId
                          ? primaryBlue.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quizItem.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                selectedQuizId == quizItem.quizId
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                selectedQuizId == quizItem.quizId
                                    ? primaryBlue
                                    : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isPending
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPending ? 'pending approval' : 'Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPending ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedQuizId == quizItem.quizId) ...[
                    const SizedBox(height: 12),
                    Text(
                      quizItem.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete_sweep_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Quiz'),
                                  content: const Text(
                                    'Are you sure you want to delete this quiz?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              try {
                                setState(() {
                                  isLoading = true;
                                });

                                // Call the delete API
                                await Provider.of<AdminAuthProvider>(
                                  context,
                                  listen: false,
                                ).deleteQuizProvider(
                                  widget.courseId, // Course ID
                                  selectedModule!.moduleId, // Module ID
                                  quizItem.quizId, // Quiz ID
                                );

                                // Refresh the UI state after deletion
                                await Provider.of<AdminAuthProvider>(
                                  context,
                                  listen: false,
                                ).refreshQuizzes(
                                  widget.courseId,
                                  selectedModule!.moduleId,
                                );

                                setState(() {
                                  quiz.removeWhere(
                                    (item) => item.quizId == quizItem.quizId,
                                  );

                                  // If no quizzes remain, clear selectedQuizId
                                  if (quiz.isEmpty) {
                                    selectedQuizId = null;
                                  }
                                });

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Quiz deleted successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to delete quiz: $error',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizSubmissionPage(
                                      quizId: quizItem.quizId,
                                      title: quizItem.name,
                                    ),
                              ),
                            );
                          },
                          icon: Icon(Icons.visibility, size: 20),
                          label: Text('View Submissions'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryBlue,
                            side: BorderSide(color: primaryBlue),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showApprovalDialog2(BuildContext context, AdminQuizModel quizItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Quiz Approval"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${quizItem.name}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Description: ${quizItem.description}"),
                SizedBox(height: 8),
                Text("Created At: ${quizItem.createdAt.toLocal()}"),
                SizedBox(height: 16),
                Text(
                  "Questions:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...quizItem.questions.map(
                  (q) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q: ${q.text}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        ...q.answers.map(
                          (a) => Text(
                            "- ${a.text} ${a.isCorrect == true ? "(Correct)" : ""}",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _approveQuiz(quizItem.quizId, "approved");
                Navigator.of(context).pop();
              },
              child: Text('Accept', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                await _approveQuiz(quizItem.quizId, "rejected");
                Navigator.of(context).pop();
              },
              child: Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveQuiz(int quizId, String status) async {
    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.adminApprovequizprovider(quizId: quizId, status: status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz $status successfully!'),
          backgroundColor: status == "Approved" ? Colors.green : Colors.red,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update quiz status: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show Edit Dialog for Quiz
  // void _showEditQuizDialog(BuildContext context, AdminQuizModel quiz) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => QuizCreatorScreen(
  //         courseId: quiz.courseId,
  //         moduleId: quiz.moduleId,
  //         batchId: widget.batchId,
  //         quizToEdit: quiz,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLessonsList(List<AdminLessonmodel> lessons) {
    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No lessons available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isSelected = selectedLesson?.lessonId == lesson.lessonId;
        final isPending =
            lesson.status == "pending" || lesson.status == "rejected";

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (isPending) {
                _showApprovalDialog(context, lesson);
              } else {
                setState(() {
                  selectedLesson = isSelected ? null : lesson;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? lightBlue.withOpacity(0.3) : Colors.white,
                border: Border.all(
                  color:
                      isSelected
                          ? primaryBlue.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected ? primaryBlue : Colors.black87,
                              ),
                            ),
                            if (isPending) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Pending",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_note,
                              color: isSelected ? primaryBlue : Colors.grey,
                            ),
                            onPressed:
                                () => _showEditLessonDialog(context, lesson),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_sweep_outlined,
                              color: isSelected ? primaryBlue : Colors.grey,
                            ),
                            onPressed:
                                () => _showDeleteConfirmation(context, lesson),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 12),
                    Text(
                      lesson.content,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        if (lesson.videoLink != null &&
                            lesson.videoLink.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.play_circle_outline),
                              label: Text("Watch Video"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  () => _openVideoPlayer(context, lesson),
                            ),
                          ),
                        if (lesson.videoLink != null &&
                            lesson.videoLink.isNotEmpty &&
                            lesson.pdfPath != null &&
                            lesson.pdfPath!.isNotEmpty)
                          SizedBox(width: 12),
                        if (lesson.pdfPath != null &&
                            lesson.pdfPath!.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.picture_as_pdf),
                              label: Text("View PDF"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  () => _openPdfDocument(context, lesson),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to open video player
  void _openVideoPlayer(BuildContext context, AdminLessonmodel lesson) async {
    if (lesson.videoLink.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video link is not available')));
      return;
    }

    // Check if video link is YouTube or direct URL
    if (lesson.videoLink.contains('youtube.com') ||
        lesson.videoLink.contains('youtu.be')) {
      // Launch YouTube video in browser or YouTube app
      if (await canLaunch(lesson.videoLink)) {
        await launch(lesson.videoLink);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open video link')));
      }
    } else {
      // For other video links, you might want to use a video player package
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(url: lesson.videoLink),
        ),
      );
    }
  }

  // Function to open PDF document
  void _openPdfDocument(BuildContext context, AdminLessonmodel lesson) async {
    if (lesson.pdfPath == null || lesson.pdfPath!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF is not available')));
      return;
    }

    // For Google Drive links, open in browser or appropriate app
    if (await canLaunch(lesson.pdfPath!)) {
      await launch(lesson.pdfPath!);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open PDF link')));
    }
  }

  void _showApprovalDialog(BuildContext context, AdminLessonmodel lesson) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Lesson Approval"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Title: ${lesson.title}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Content: ${lesson.content}"),
              SizedBox(height: 12),
              Text(
                "Do you want to approve or reject this lesson?",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _handleLessonApproval(
                  dialogContext,
                  lesson.lessonId,
                  "approved",
                );
              },
              child: Text("Approve", style: TextStyle(color: Colors.green)),
            ),
            // TextButton(
            //   onPressed: () {
            //     _handleLessonApproval(dialogContext, lesson.lessonId, "rejected");
            //   },
            //   child: Text("Reject", style: TextStyle(color: Colors.red)),
            // ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _handleLessonApproval(
    BuildContext context,
    int lessonId,
    String status,
  ) async {
    try {
      await Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).adminApprovelessonsprovider(lessonId: lessonId, status: status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lesson $status successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Close dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    AdminLessonmodel lesson,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Lesson'),
          content: Text('Are you sure you want to delete this lesson?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await Provider.of<AdminAuthProvider>(
          context,
          listen: false,
        ).admindeletelessonprovider(
          widget.courseId,
          selectedModule!.moduleId,
          lesson.lessonId,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lesson deleted successfully!')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete lesson: $error')),
        );
      }
    }
  }

  Widget _buildAssignmentsList(List<AssignmentModel> assignments) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No assignments available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (assignment.status.toLowerCase() == "pending approval") {
                _showApprovalDialogs(context, assignment);
              } else {
                setState(() {
                  selectedAssignmentId =
                      (selectedAssignmentId == assignment.assignmentId)
                          ? null
                          : assignment.assignmentId;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    selectedAssignmentId == assignment.assignmentId
                        ? lightBlue.withOpacity(0.3)
                        : Colors.white,
                border: Border.all(
                  color:
                      selectedAssignmentId == assignment.assignmentId
                          ? primaryBlue.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                selectedAssignmentId == assignment.assignmentId
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                selectedAssignmentId == assignment.assignmentId
                                    ? primaryBlue
                                    : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              assignment.status.toLowerCase() ==
                                      "pending approval"
                                  ? Colors.orange.withOpacity(0.1)
                                  : _getDueDateColor(
                                    assignment.dueDate,
                                  ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          assignment.status.toLowerCase() == "pending approval"
                              ? "Pending Approval"
                              : _formatDueDate(assignment.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                assignment.status.toLowerCase() ==
                                        "pending approval"
                                    ? Colors.orange
                                    : _getDueDateColor(assignment.dueDate),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedAssignmentId == assignment.assignmentId) ...[
                    const SizedBox(height: 12),
                    Text(
                      assignment.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_note, color: Colors.black),
                          onPressed:
                              () => _showEditAssignmentDialog(
                                context,
                                assignment,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_sweep_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Assignment'),
                                  content: const Text(
                                    'Are you sure you want to delete this assignment?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              try {
                                setState(() {
                                  isLoading = true;
                                });

                                await Provider.of<AdminAuthProvider>(
                                  context,
                                  listen: false,
                                ).admindeleteassignmentprovider(
                                  widget.courseId, // Course ID
                                  selectedModule!.moduleId, // Module ID
                                  assignment.assignmentId, // Assignment ID
                                );

                                // Update UI state after successful deletion
                                setState(() {
                                  assignments.removeWhere(
                                    (item) =>
                                        item.assignmentId ==
                                        assignment.assignmentId,
                                  );
                                  if (selectedAssignmentId ==
                                      assignment.assignmentId) {
                                    selectedAssignmentId = null;
                                  }
                                });

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Assignment deleted successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to delete assignment: $error',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SubmissionPage(
                                      assignmentId: assignment.assignmentId,
                                      title: assignment.title,
                                    ),
                              ),
                            );
                          },
                          icon: Icon(Icons.visibility, size: 20,
                          color: primaryBlue,),
                          label: Text('View Submissions'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryBlue,
                            side: BorderSide(color: primaryBlue),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showApprovalDialogs(BuildContext context, AssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Approve Assignment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Title: ${assignment.title}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Description: ${assignment.description}"),
              SizedBox(height: 8),
              Text("Submission Link: ${assignment.submissionLink}"),

              Text(
                "Status: ${assignment.status}",
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _updateAssignmentStatus(
                  assignment.assignmentId,
                  "approved",
                );
                Navigator.pop(context);
              },
              child: Text("Approve", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                await _updateAssignmentStatus(
                  assignment.assignmentId,
                  "rejected",
                );
                Navigator.pop(context);
              },
              child: Text("Reject", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAssignmentStatus(int assignmentId, String status) async {
    try {
      await Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).adminApproveassignmentprovider(
        assignmentId: assignmentId,
        status: status,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Assignment $status successfully!"),
          backgroundColor: status == "approved" ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays < 0) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Due Today';
    } else if (difference.inDays == 1) {
      return 'Due Tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else {
      return 'Due ${DateFormat('MMM d').format(dueDate)}';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays < 0) {
      return Colors.red;
    } else if (difference.inDays < 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        title: Text('Module Management', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side remains the same
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AdminAuthProvider>(
                          builder: (context, provider, child) {
                            final modules = provider.getModulesForCourse(
                              widget.courseId,
                            );

                            if (provider.isLoading) {
                              return Center(child: CircularProgressIndicator());
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildModuleDropdown(modules),
                                      const SizedBox(height: 10),
                                      if (selectedModule != null)
                                        _buildSelectedModuleCard(
                                          selectedModule!,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (selectedModule != null)
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child:
                                        _buildLessonsAndAssignmentsquizView(),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Vertical Divider
                // Container(
                //   width: 1,
                //   height: constraints.maxHeight,
                //   color: Colors.grey.withOpacity(0.2),
                // ),
                Expanded(
                  flex: 1,
                  child: Consumer<AdminAuthProvider>(
                    builder: (context, adminProvider, child) {
                      return SizedBox(
                        height: constraints.maxHeight - 1,
                        child: BatchStatusDisplay(
                          error: adminProvider.error,
                          isLoading: adminProvider.isLoading,
                          batchData: adminProvider.batchData,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tooltip(
                message: 'Create Module',
                child: FloatingActionButton.small(
                  heroTag: 'createModule',
                  onPressed: () {
                    _showCreateModuleDialog(context);
                    _toggleFabMenu();
                  },
                  backgroundColor: Colors.blue[700],
                  child: const Icon(
                    Icons.create_new_folder,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          if (selectedModule != null) ...[
            // Your existing FAB items for Quiz, Assignment, and Lesson
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: 'Create Quiz',
                  child: FloatingActionButton.small(
                    heroTag: 'createQuiz',
                    onPressed: () {
                      _toggleFabMenu();
                    },
                    backgroundColor: Colors.orange,
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: 'Create Assignment',
                  child: FloatingActionButton.small(
                    heroTag: 'createAssignment',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => _CreateAssignmentDialog(
                              moduleId: selectedModule!.moduleId,
                              courseId: widget.courseId,
                            ),
                      );
                      _toggleFabMenu();
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: 'Create Lesson',
                  child: FloatingActionButton.small(
                    heroTag: 'createLesson',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => _CreateLessonDialog(
                              courseId: widget.courseId,
                              moduleId: selectedModule!.moduleId,
                            ),
                      );
                      _toggleFabMenu();
                    },
                    backgroundColor: Colors.brown,
                    child: const Icon(
                      Icons.note_add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Main FAB
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: _toggleFabMenu,
            backgroundColor: Colors.green,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateLessonDialog extends StatefulWidget {
  final int courseId;
  final int moduleId;

  const _CreateLessonDialog({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  State<_CreateLessonDialog> createState() => _CreateLessonDialogState();
}

class _CreateLessonDialogState extends State<_CreateLessonDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();
  final TextEditingController pdfUrlController =
      TextEditingController(); // Added PDF URL controller
  bool isCreatingLesson = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    videoLinkController.dispose();
    pdfUrlController.dispose(); // Dispose PDF URL controller
    super.dispose();
  }

  Future<void> _createLesson() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isCreatingLesson = true);
    try {
      await Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).Admincreatelessonprovider(
        widget.courseId,
        widget.moduleId,
        contentController.text,
        titleController.text,
        videoLinkController.text,
        pdfUrlController.text, // Added PDF URL parameter
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson created successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating lesson: $e')));
    } finally {
      setState(() => isCreatingLesson = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Create New Lesson',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 600, // Set desired dialog width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Lesson Title*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Lesson Content*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: videoLinkController,
              decoration: InputDecoration(
                labelText: 'Video Link (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              // Added PDF URL field
              controller: pdfUrlController,
              decoration: InputDecoration(
                labelText: 'PDF URL (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed:
                    isCreatingLesson ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    isCreatingLesson
                        ? null
                        : () async {
                          if (titleController.text.trim().isEmpty ||
                              contentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill all required fields',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isCreatingLesson = true;
                          });

                          try {
                            // Call the create lesson logic
                            await _createLesson();

                            // Refresh lessons to show the newly created lesson
                            await Provider.of<AdminAuthProvider>(
                              context,
                              listen: false,
                            ).AdminfetchLessonsForModuleProvider(
                              widget.courseId,
                              widget.moduleId,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lesson created successfully!'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error creating lesson: ${e.toString()}',
                                ),
                              ),
                            );
                          } finally {
                            setState(() {
                              isCreatingLesson = false;
                            });
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:
                    isCreatingLesson
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CreateAssignmentDialog extends StatefulWidget {
  final int moduleId;
  final int courseId;

  const _CreateAssignmentDialog({
    super.key,
    required this.moduleId,
    required this.courseId,
  });

  @override
  State<_CreateAssignmentDialog> createState() =>
      _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<_CreateAssignmentDialog> {
  final TextEditingController assignmentTitleController =
      TextEditingController();
  final TextEditingController assignmentDescriptionController =
      TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  bool isCreatingAssignment = false;

  @override
  void dispose() {
    assignmentTitleController.dispose();
    assignmentDescriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> _createAssignment() async {
    if (assignmentTitleController.text.isEmpty ||
        assignmentDescriptionController.text.isEmpty ||
        dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isCreatingAssignment = true);
    try {
      await Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).createAssignmentProvider(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        title: assignmentTitleController.text.trim(),
        description: assignmentDescriptionController.text.trim(),
        dueDate: dueDateController.text.trim(),
      );

      Navigator.of(context).pop(); // Close the dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating assignment: $e')));
    } finally {
      setState(() => isCreatingAssignment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Create New Assignment',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 600, // Set desired dialog width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 20),
            TextFormField(
              controller: assignmentTitleController,
              decoration: InputDecoration(
                labelText: 'Assignment Title*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: assignmentDescriptionController,
              decoration: InputDecoration(
                labelText: 'Assignment Description*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: dueDateController,
              decoration: InputDecoration(
                labelText: 'Due Date*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dueDateController.text =
                      picked.toIso8601String().split('T')[0];
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed:
                    isCreatingAssignment
                        ? null
                        : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isCreatingAssignment ? null : _createAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:
                    isCreatingAssignment
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BatchStatusDisplay extends StatelessWidget {
  final String? error;
  final bool isLoading;
  final BatchStudentModel? batchData;

  const BatchStatusDisplay({
    super.key,
    required this.error,
    required this.isLoading,
    required this.batchData,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading batch details...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 48),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!.startsWith('Exception:') ? error!.substring(10) : error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.red[900]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    if (batchData == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No Batch Data Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check if the batch is assigned\nor try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.green[900]),
              ),
            ],
          ),
        ),
      );
    }

    return _buildStudentsSection(batchData!);
  }

  Widget _buildStudentsSection(BatchStudentModel batchData) {
    final primaryBlue = Color(0xFF2E7D32);
    final mediumBlue = Colors.blue.shade700;
    final lightBlue = Colors.blue.shade50;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course and Batch Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, size: 24, color: primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        batchData.courseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.group, size: 20, color: primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      batchData.batchName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Students Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 24, color: primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    'STUDENTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                '${batchData.students.length} Students',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Students List
          Expanded(
            child:
                batchData.students.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students enrolled yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Students will appear here once enrolled',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: batchData.students.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = batchData.students[index];

                        return Consumer<AdminAuthProvider>(
                          builder: (context, userProvider, child) {
                            final userData = userProvider.user;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade700.withOpacity(0.2),
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 20,
                                    child: Text(
                                      student.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          student.email,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (userData != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Submitted Assignments: ${userData.user.totalSubmittedAssignments}',
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'Submitted Quizzes: ${userData.user.totalSubmittedQuizzes}',
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          ElevatedButton(
                                            onPressed: () {
                                              userProvider.fetchUserDetails(
                                                student.studentId,
                                              );
                                            },
                                            child: const Text('Load Details'),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
