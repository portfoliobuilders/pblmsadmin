import 'package:flutter/material.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:pblmsadmin/screens/admin/batch_management/add_teacher_batch.dart';
import 'package:pblmsadmin/screens/admin/batch_management/teachers_in_batch.dart';
import 'package:provider/provider.dart';


class AdminAddTeacher extends StatefulWidget {
  const AdminAddTeacher({super.key});

  @override
  State<AdminAddTeacher> createState() => _AdminAddTeacherState();
}

class _AdminAddTeacherState extends State<AdminAddTeacher> {
  bool isCourseExpanded = false;
  bool isBatchExpanded = false;
  dynamic selectedCourse;
  dynamic selectedBatch;

  final Color primaryBlue = const Color(0xFF1A73E8);
  final Color lightBlue = const Color(0xFFF3F8FF);
  final Color mediumBlue = const Color(0xFF82B1FF);
  final Color accentGreen = const Color(0xFF34A853);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Teacher Management',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightBlue, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildCourseSection(provider),
              if (selectedCourse != null) ...[
                const SizedBox(height: 36),
                _buildBatchSection(provider),
                if (selectedBatch != null) ...[
                  const SizedBox(height: 36),
                  _buildActionButtons(context),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school, size: 32, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a course and batch to manage teachers',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Previous code remains the same until _buildCourseSection

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
            onTap: () => setState(() => isCourseExpanded = !isCourseExpanded),
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
                        color: selectedCourse != null
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
          if (isCourseExpanded)
            _buildCourseList(provider),
        ],
      ),
    );
  }

  Widget _buildCourseList(AdminAuthProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: provider.course.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          final course = provider.course[index];
          final isSelected = selectedCourse?.courseId == course.courseId;
          return _buildCourseItem(course, isSelected, provider);
        },
      ),
    );
  }

  Widget _buildCourseItem(dynamic course, bool isSelected, AdminAuthProvider provider) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCourse = course;
          selectedBatch = null;
          isCourseExpanded = false;
          provider.AdminfetchBatchForCourseProvider(course.courseId);
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
                color: isSelected
                    ? primaryBlue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.book_outlined,
                size: 20,
                color: isSelected ? primaryBlue : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                course.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryBlue : Colors.black87,
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
                child: Icon(Icons.check, color: primaryBlue, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchSection(AdminAuthProvider provider) {
    final batches = provider.courseBatches[selectedCourse.courseId] ?? [];

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
              Icon(Icons.school, size: 24, color: primaryBlue),
              const SizedBox(width: 12),
              Text(
                'SELECT BATCH',
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
            onTap: () => setState(() => isBatchExpanded = !isBatchExpanded),
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
                      selectedBatch?.batchName ?? 'Select Batch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selectedBatch != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(
                    isBatchExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: primaryBlue,
                  ),
                ],
              ),
            ),
          ),
          if (isBatchExpanded)
            _buildBatchList(batches),
        ],
      ),
    );
  }

  Widget _buildBatchList(List<dynamic> batches) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: batches.isEmpty
          ? _buildEmptyBatchMessage()
          : ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: batches.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              itemBuilder: (_, index) => _buildBatchItem(batches[index]),
            ),
    );
  }

  Widget _buildEmptyBatchMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey[400], size: 24),
          const SizedBox(width: 12),
          Text(
            'No batches available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchItem(dynamic batch) {
    final isSelected = selectedBatch?.batchId == batch.batchId;
    return InkWell(
      onTap: () {
        setState(() {
          selectedBatch = batch;
          isBatchExpanded = false;
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
                color: isSelected
                    ? primaryBlue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.groups_outlined,
                size: 20,
                color: isSelected ? primaryBlue : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                batch.batchName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryBlue : Colors.black87,
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
                child: Icon(Icons.check, color: primaryBlue, size: 16),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildActionButtons(BuildContext context) {
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
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminTeacherPage(
                      courseId: selectedCourse.courseId,
                      batchId: selectedBatch.batchId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Add Teachers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeachersListScreen(
                      courseId: selectedCourse.courseId,
                      batchId: selectedBatch.batchId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text(
                'View Teachers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}