import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pblmsadmin/models/admin_model.dart';
import 'package:provider/provider.dart';
import 'package:pblmsadmin/provider/authprovider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final int studentId;

  const AttendanceHistoryScreen({Key? key, required this.studentId})
    : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendanceHistory();
    });
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      await Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).fetchAttendanceHistoryProvider(widget.studentId);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _updateAttendanceStatus(AttendanceHistory attendance) {
    final List<String> statusOptions = ['Present', 'Absent'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus = statusOptions.firstWhere(
          (status) => status.toLowerCase() == attendance.status.toLowerCase(),
          orElse: () => 'Present',
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Update Attendance Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Attendance Status',
                    prefixIcon: Icon(
                      _getStatusIcon(selectedStatus),
                      color: _getStatusColor(selectedStatus),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF2E7D32)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2,
                      ),
                    ),
                  ),
                  items:
                      statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(status),
                                    color: _getStatusColor(status),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(status),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      setState(() {
                        selectedStatus = newStatus;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<AdminAuthProvider>(
                    context,
                    listen: false,
                  ).updateStudentAttendance(
                    attendanceId: attendance.id,
                    status: selectedStatus.toLowerCase(),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  _showErrorSnackBar('Failed to update attendance');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Consumer<AdminAuthProvider>(
        builder: (context, attendanceProvider, child) {
          final attendanceHistory = attendanceProvider.attendanceHistory;

          if (attendanceHistory.isEmpty) {
            return const Center(
              child: Text(
                'No attendance records found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchAttendanceHistory,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 211, 233, 212),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Action',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendanceHistory.length,
                        separatorBuilder:
                            (context, index) =>
                                Divider(height: 1, color: Colors.grey[300]),
                        itemBuilder: (context, index) {
                          final attendance = attendanceHistory[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Date Column
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(attendance.date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status Column
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        attendance.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getStatusIcon(attendance.status),
                                          color: _getStatusColor(
                                            attendance.status,
                                          ),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          attendance.status,
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              attendance.status,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Action Column
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      onPressed:
                                          () => _updateAttendanceStatus(
                                            attendance,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      case 'excused':
        return Icons.event_available;
      default:
        return Icons.help;
    }
  }
}
