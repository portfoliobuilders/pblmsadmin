import 'package:flutter/material.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionPage extends StatefulWidget {
  final int assignmentId;
  final String title;

  const SubmissionPage({
    super.key,
    required this.assignmentId,
    required this.title,
  });

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Match the color scheme
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).fetchSubmissions(widget.assignmentId),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Widget _buildStatusBadge(String status) {
    final isCompleted = status.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isCompleted ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: mediumBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submission Content:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(submission.content),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Last Updated: ${_getFormattedDate(submission.updatedAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              _buildStatusBadge(submission.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionlink(dynamic submission) {
    // Check if submission link exists
    final hasLink =
        submission.submissionLink != null &&
        submission.submissionLink.toString().isNotEmpty;

    final linkUrl = hasLink ? submission.submissionLink.toString() : '';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: mediumBlue),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Submission Link:',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          hasLink
              ? InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(linkUrl);
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      // Show a snackbar if the link can't be opened
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open link: $linkUrl'),
                            backgroundColor: Colors.red[400],
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error opening link: $e'),
                          backgroundColor: Colors.red[400],
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          linkUrl,
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.open_in_new, size: 16, color: primaryBlue),
                    ],
                  ),
                ),
              )
              : Text(
                'No submission link provided',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search, color: primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mediumBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mediumBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryBlue, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<AdminAuthProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                final submissions =
                    provider.getSubmissionsForAssignment(widget.assignmentId) ??
                    [];
                if (submissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: mediumBlue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No submissions found',
                          style: TextStyle(fontSize: 18, color: primaryBlue),
                        ),
                      ],
                    ),
                  );
                }

                final filteredSubmissions =
                    submissions.where((submission) {
                      final studentName = submission.studentName.toLowerCase();
                      final studentEmail =
                          submission.studentEmail.toLowerCase();
                      return searchQuery.isEmpty ||
                          studentName.contains(searchQuery) ||
                          studentEmail.contains(searchQuery);
                    }).toList();

                return RefreshIndicator(
                  color: primaryBlue,
                  onRefresh:
                      () => provider.fetchSubmissions(widget.assignmentId),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSubmissions.length,
                    itemBuilder: (context, index) {
                      final submission = filteredSubmissions[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: mediumBlue, width: 1),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryBlue,
                            child: Text(
                              submission.studentName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            submission.studentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                submission.studentEmail,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getFormattedDate(submission.submittedAt),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.assignment_turned_in,
                                    size: 16,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    submission.status,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 20,
                                        color: primaryBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Assignment Response',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSubmissionCard(submission),
                                  const SizedBox(height: 10),
                                  _buildSubmissionlink(submission),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
