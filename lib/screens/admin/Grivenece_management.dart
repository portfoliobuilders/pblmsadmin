import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pblmsadmin/models/admin_model.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';

class AdminLeaveRequestScreen extends StatefulWidget {
  const AdminLeaveRequestScreen({super.key});

  @override
  _AdminLeaveRequestScreenState createState() => _AdminLeaveRequestScreenState();
}

class _AdminLeaveRequestScreenState extends State<AdminLeaveRequestScreen> {
  int? expandedLeaveId; // Tracks which leave request is expanded

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<AdminAuthProvider>(context, listen: false).Adminfetchleaveprovider();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaveProvider = Provider.of<AdminAuthProvider>(context);
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Leave Request Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Requests",
            onPressed: () {
              leaveProvider.Adminfetchleaveprovider();
              setState(() {
                expandedLeaveId = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Requests refreshed"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Leave Requests",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${leaveProvider.leave.length} Requests",
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildLeaveRequestList(leaveProvider),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeaveRequestList(AdminAuthProvider leaveProvider) {
    if (leaveProvider.leave.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.indigo.shade200,
            ),
            const SizedBox(height: 16),
            const Text(
              "No leave requests available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                leaveProvider.Adminfetchleaveprovider();
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: leaveProvider.leave.length,
      itemBuilder: (context, index) {
        final leave = leaveProvider.leave[index];
        final bool isExpanded = expandedLeaveId == leave.leaveId;

        return ExpandableLeaveCard(
          leave: leave,
          isExpanded: isExpanded,
          onToggleExpand: () {
            setState(() {
              if (expandedLeaveId == leave.leaveId) {
                expandedLeaveId = null; 
              } else {
                expandedLeaveId = leave.leaveId; 
              }
            });
          },
          onStatusUpdate: () {
            leaveProvider.Adminfetchleaveprovider();
            setState(() {
              expandedLeaveId = null;
            });
          },
        );
      },
    );
  }
}

class ExpandableLeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onStatusUpdate;

  const ExpandableLeaveCard({
    required this.leave,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onStatusUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isExpanded ? 4 : 1,
      color: isExpanded ? Colors.indigo.shade50 : Colors.white,
      child: Column(
        children: [
          // Card Header (always visible) - Simplified to only show name and status
          InkWell(
            borderRadius: isExpanded 
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12), 
                    topRight: Radius.circular(12)
                  ) 
                : BorderRadius.circular(12),
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Student Name
                  Text(
                    leave.student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  // Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: leave.status == "pending"
                              ? Colors.amber.shade100
                              : leave.status == "approved"
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          leave.status.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: leave.status == "pending"
                                ? Colors.amber.shade900
                                : leave.status == "approved"
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.indigo,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Details Section (only visible when expanded)
          if (isExpanded) _buildExpandedDetails(context),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 8, thickness: 1),
          const SizedBox(height: 12),
          
          // Student Information
          Text(
            "Student Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
          const SizedBox(height: 8),
          Text("Name: ${leave.student.name}"),
          Text("Email: ${leave.student.email}"),
          
          const SizedBox(height: 16),
          
          // Leave Information
          Text(
            "Leave Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
          const SizedBox(height: 8),
          Text("Leave Date: ${DateFormat.yMMMMd().format(leave.leaveDate)}"),
          
          const SizedBox(height: 16),
          
          // Reason
          Text(
            "Reason for Leave",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(leave.reason),
          ),
          
          // Action Buttons (only for pending requests)
          if (leave.status == "pending") ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
                      await provider.adminApproveleaveprovider(
                        leaveId: leave.leaveId,
                        status: "approved",
                      );
                      onStatusUpdate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Leave request approved"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text("APPROVE"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
                      await provider.adminApproveleaveprovider(
                        leaveId: leave.leaveId,
                        status: "rejected",
                      );
                      onStatusUpdate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Leave request rejected"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: const Text("REJECT"),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}