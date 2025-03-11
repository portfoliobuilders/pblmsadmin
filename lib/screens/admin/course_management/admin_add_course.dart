import 'package:flutter/material.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:pblmsadmin/screens/admin/course_management/admin_course_batch.dart';
import 'package:pblmsadmin/screens/admin/course_management/admin_module_add.dart';
import 'package:provider/provider.dart';

class AdminAddCourse extends StatefulWidget {
  const AdminAddCourse({super.key});

  @override
  State<AdminAddCourse> createState() => _AdminAddCourseState();
}

class _AdminAddCourseState extends State<AdminAddCourse> {
  int? selectedCourseId;

  void _showAddCourseDialog(
    BuildContext context, {
    String? initialName,
    String? initialDescription,
    int? courseId,
  }) {
    final TextEditingController nameController =
        TextEditingController(text: initialName);
    final TextEditingController descriptionController =
        TextEditingController(text: initialDescription);

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            courseId == null ? 'Add Course' : 'Edit Course',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            width: 600, // Set the desired width
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectionContainer.disabled(
                      // Disable text selection highlighting
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Course Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              width: 1, // Reduced border width
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a course name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectionContainer.disabled(
                      // Disable text selection highlighting
                      child: TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              width: 1, // Reduced border width
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        String courseName = nameController.text.trim();
                        String courseDescription =
                            descriptionController.text.trim();

                        try {
                          final provider = Provider.of<AdminAuthProvider>(
                              context,
                              listen: false);

                          if (courseId == null) {
                            await provider.AdmincreateCourseprovider(
                                courseName, courseDescription);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Course added successfully!')),
                            );
                          } else {
                            await provider.AdminupdateCourse(
                                courseId, courseName, courseDescription);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Course updated successfully!')),
                            );
                          }

                          await provider.AdminfetchCoursesprovider();
                          Navigator.of(context).pop();
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to save course: $error')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue, // Sky blue color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white), // White text for contrast
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COURSES',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your courses here.',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showAddCourseDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Create Course',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  const SizedBox(height: 20),
                  Wrap(
                    
                    spacing: 10,
                    runSpacing: 10,
                    children: courseProvider.course.map((course) {
                      return GestureDetector(
                          onTap: () {
                            // Navigate to the ModuleAddScreen with the selected courseId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminModuleAddScreen(
                                  courseId: course.courseId,
                                  courseName: course.name, // Add the courseName parameter
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                              width: 225,
                              height: 225,
                              child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: Colors.blue, width: 1)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 150,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            child: Image.asset(
                                              'assets/image.jpg', // Placeholder image
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                          child: Container(
                                            height: 65,
                                            color: Colors.blue[50],
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  course.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Spacer(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit_note),
                                                      onPressed: () {
                                                        _showAddCourseDialog(
                                                          context,
                                                          initialName:
                                                              course.name,
                                                          initialDescription:
                                                              course
                                                                  .description,
                                                          courseId:
                                                              course.courseId,
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_sweep_outlined,
                                                      ),
                                                      onPressed: () async {
                                                        final confirm =
                                                            await showDialog<
                                                                bool>(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              title: const Text(
                                                                  'Delete Course'),
                                                              content: const Text(
                                                                  'Are you sure you want to delete this course?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              false),
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true),
                                                                  child: const Text(
                                                                      'Delete'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );

                                                        if (confirm == true) {
                                                          try {
                                                            await Provider.of<
                                                                        AdminAuthProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .AdmindeleteCourseprovider(
                                                                    course
                                                                        .courseId);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Course deleted successfully!')),
                                                            );
                                                          } catch (error) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Failed to delete course: $error')),
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ]))));
                    }).toList(),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
