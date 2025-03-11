import 'package:flutter/material.dart';
import 'package:pblmsadmin/models/admin_model.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:pblmsadmin/screens/admin/course_management/admin_module_add.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminCourseBatchScreen extends StatefulWidget {
  const AdminCourseBatchScreen({super.key});

  @override
  State<AdminCourseBatchScreen> createState() => _AdminCourseBatchScreenState();
}

class _AdminCourseBatchScreenState extends State<AdminCourseBatchScreen> {
  final TextEditingController _batchNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Course and batch selection
  bool isCourseExpanded = false;
  dynamic selectedCourse;

  // Enhanced color palette
  final Color primaryBlue = const Color(0xFF1A73E8);
  final Color lightBlue = const Color(0xFFF3F8FF);
  final Color mediumBlue = const Color(0xFF82B1FF);

  @override
  void initState() {
    super.initState();
    // Fetch courses when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminAuthProvider>(context, listen: false).AdminfetchCoursesprovider();
    });
  }

  void _showCreateBatchDialog(BuildContext context) {
    _batchNameController.clear();
    _startDate = null;
    _endDate = null;
    bool isCreating = false;

    if (selectedCourse == null) {
      _showError(context, 'Please select a course first');
      return;
    }

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
                'Create New Batch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _batchNameController,
                        decoration: InputDecoration(
                          labelText: 'Batch Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.group),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text:
                                    _startDate != null
                                        ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_startDate!)
                                        : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text:
                                    _endDate != null
                                        ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_endDate!)
                                        : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: _startDate ?? DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      isCreating
                          ? null
                          : () async {
                            if (_batchNameController.text.trim().isEmpty) {
                              _showError(context, 'Please enter a batch name');
                              return;
                            }
                            if (_startDate == null) {
                              _showError(context, 'Please select a start date');
                              return;
                            }
                            if (_endDate == null) {
                              _showError(context, 'Please select an end date');
                              return;
                            }
                            if (_endDate!.isBefore(_startDate!)) {
                              _showError(
                                context,
                                'End date cannot be before start date',
                              );
                              return;
                            }

                            setState(() => isCreating = true);

                            try {
                              final provider = Provider.of<AdminAuthProvider>(
                                context,
                                listen: false,
                              );

                              await provider.AdminCreateBatchProvider(
                                _batchNameController.text.trim(),
                                selectedCourse.courseId,
                                _startDate!,
                                _endDate!,
                              );

                              Navigator.pop(context);
                              await provider.AdminfetchBatchForCourseProvider(
                                selectedCourse.courseId,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Batch created successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              _showError(
                                context,
                                'Failed to create batch: ${e.toString()}',
                              );
                            } finally {
                              setState(() => isCreating = false);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBatchDialog(BuildContext context, AdminCourseBatch batch) {
    final TextEditingController editNameController = TextEditingController(
      text: batch.batchName,
    );
    DateTime? editStartDate = batch.startTime;
    DateTime? editEndDate = batch.endTime;
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
                'Edit Batch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: editNameController,
                        decoration: InputDecoration(
                          labelText: 'Batch Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.group),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text:
                                    editStartDate != null
                                        ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(editStartDate!)
                                        : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: editStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blue,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    editStartDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text:
                                    editEndDate != null
                                        ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(editEndDate!)
                                        : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: editEndDate ?? DateTime.now(),
                                  firstDate: editStartDate ?? DateTime.now(),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blue,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    editEndDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      isUpdating
                          ? null
                          : () async {
                            if (editNameController.text.trim().isEmpty) {
                              _showError(context, 'Please enter a batch name');
                              return;
                            }
                            if (editStartDate == null) {
                              _showError(context, 'Please select a start date');
                              return;
                            }

                            if (editEndDate == null) {
                              _showError(context, 'Please select an end date');
                              return;
                            }
                            if (editEndDate!.isBefore(editStartDate!)) {
                              _showError(
                                context,
                                'End date cannot be before start date',
                              );
                              return;
                            }

                            setState(() => isUpdating = true);

                            try {
                              final provider = Provider.of<AdminAuthProvider>(
                                context,
                                listen: false,
                              );

                              await provider.AdminUpdatebatchprovider(
                                selectedCourse.courseId,
                                batch.batchId,
                                editNameController.text.trim(),
                                '', // Empty medium
                                editStartDate!,
                                editEndDate!,
                              );

                              Navigator.pop(context);
                              await provider.AdminfetchBatchForCourseProvider(
                                selectedCourse.courseId,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Batch updated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              _showError(
                                context,
                                'Failed to update batch: ${e.toString()}',
                              );
                            } finally {
                              setState(() => isUpdating = false);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteBatch(AdminAuthProvider provider, int batchId) async {
    try {
      await provider.AdmindeleteBatchprovider(
        selectedCourse.courseId,
        batchId,
        '', // Empty medium
        DateTime.now(), // Provide current date as default
        DateTime.now().add(const Duration(days: 365)), // Default end date
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Batch deleted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await provider.AdminfetchBatchForCourseProvider(selectedCourse.courseId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete batch: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Batch'),
              content: const Text(
                'Are you sure you want to delete this batch?',
              ),
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
            );
          },
        ) ??
        false;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          'Course Batches',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightBlue, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseSection(provider),
              const SizedBox(height: 20),
              if (selectedCourse != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BATCHES',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Create Batch',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showCreateBatchDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildBatchList(provider)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSection(AdminAuthProvider provider) {
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
              Icon(Icons.book, size: 24, color: primaryBlue),
              const SizedBox(width: 12),
              Text(
                'SELECT COURSE',
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
            onTap: () {
              setState(() {
                isCourseExpanded = !isCourseExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: mediumBlue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: lightBlue.withOpacity(0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCourse?.name ?? 'Select Course',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            selectedCourse != null
                                ? Colors.black87
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(
                    isCourseExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: primaryBlue,
                  ),
                ],
              ),
            ),
          ),
          if (isCourseExpanded) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: provider.course.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                  itemBuilder: (context, index) {
                    final course = provider.course[index];
                    final isSelected =
                        selectedCourse?.courseId == course.courseId;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedCourse = course;
                          isCourseExpanded = false;
                          provider.AdminfetchBatchForCourseProvider(
                            course.courseId,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? lightBlue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? primaryBlue.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                size: 20,
                                color:
                                    isSelected ? primaryBlue : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                course.name,
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
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: primaryBlue,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchList(AdminAuthProvider provider) {
    final batches = provider.courseBatches[selectedCourse.courseId] ?? [];

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No batches available for this course',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

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
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final batch = batches[index];
          return Container(
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              top: index == 0 ? 16 : 8,
              bottom: index == batches.length - 1 ? 16 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.groups_rounded,
                        color: Colors.blue[700],
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.batchName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (batch.startTime != null && batch.endTime != null)
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('MMM d, y').format(batch.startTime!)} - ${DateFormat('MMM d, y').format(batch.endTime!)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: Colors.blue[700]),
                        onPressed: () => _showEditBatchDialog(context, batch),
                        tooltip: 'Edit Batch',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          if (await _confirmDelete(context)) {
                            await _deleteBatch(provider, batch.batchId);
                          }
                        },
                        tooltip: 'Delete Batch',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
