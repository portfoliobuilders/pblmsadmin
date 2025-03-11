import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pblmsadmin/provider/authprovider.dart';

class StudentsListScreen extends StatefulWidget {
  final int courseId;
  final int batchId;

  const StudentsListScreen({
    super.key,
    required this.courseId,
    required this.batchId,
  });

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  bool isLoading = true;
  String? error;
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      await Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).AdminfetchallusersBatchProvider(widget.courseId, widget.batchId);
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _fetchStudentTransactions(dynamic student) {
    Provider.of<AdminAuthProvider>(
      context,
      listen: false,
    ).fetchStudentTransactions(studentId: student.studentId);
  }

  void _showRemoveConfirmation(BuildContext context, dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove ${student.name} from this batch?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<AdminAuthProvider>(
                  context,
                  listen: false,
                );
                await provider.AdmindeleteUserFromBatchprovider(
                  courseId: widget.courseId,
                  batchId: widget.batchId,
                  userId: student.studentId,
                );
                _loadStudents(); // Reload the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${student.name} removed from batch'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove student: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAccessManagementOptions(BuildContext context, dynamic student) {
    final bool isActive = student.status == 'active';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(isActive ? 'Pause Access' : 'Resume Access'),
        content: Text(
          isActive
              ? 'Are you sure you want to pause ${student.name}\'s access to this batch?'
              : 'Are you sure you want to resume ${student.name}\'s access to this batch?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.orange : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<AdminAuthProvider>(
                  context,
                  listen: false,
                );
                await provider.manageStudentAccess(
                  studentId: student.studentId,
                  batchId: widget.batchId,
                  action: isActive ? 'pause' : 'resume',
                );
                _loadStudents(); // Reload the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isActive
                          ? '${student.name}\'s access has been paused'
                          : '${student.name}\'s access has been resumed',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update student access: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(isActive ? 'Pause' : 'Resume'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(dynamic student) {
    return Consumer<AdminAuthProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              'Error: ${provider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (provider.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No transactions found for ${student.name}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                title: Text(
                  'Transaction ID: ${transaction.transactionId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount: \$${transaction.amountPaid.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(transaction.paymentDate)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Consumer<AdminAuthProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.batchData?.batchName ?? 'Students List',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudents),
        ],
      ),
      body: Container(
        color: lightBlue.withOpacity(0.3),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : error != null
            ? _buildErrorWidget()
            : Consumer<AdminAuthProvider>(
          builder: (context, provider, child) {
            final students = provider.students;

            if (students.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: mediumBlue, width: 1),
                  ),
                  child: CustomExpansionTile(
                    key: Key('student_${student.studentId}'),
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded) {
                        _fetchStudentTransactions(student);
                      }
                    },
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: primaryBlue,
                          child: Text(
                            student.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                student.email,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (student.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: student.status == 'active'
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              student.status == 'active' ? 'Active' : 'Paused',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showAccessManagementOptions(
                                      context,
                                      student,
                                    ),
                                    icon: Icon(
                                      student.status == 'active'
                                          ? Icons.pause_circle_outline
                                          : Icons.play_circle_outline,
                                      color: student.status == 'active'
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    label: Text(
                                      student.status == 'active'
                                          ? 'Pause'
                                          : 'Resume',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                      student.status == 'active'
                                          ? Colors.orange
                                          : Colors.green,
                                      side: BorderSide(
                                        color: student.status == 'active'
                                            ? Colors.orange
                                            : Colors.green,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showRemoveConfirmation(
                                      context,
                                      student,
                                    ),
                                    icon: const Icon(
                                      Icons.person_remove,
                                      color: Colors.red,
                                    ),
                                    label: const Text('Remove'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(
                                        color: Colors.red,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            _buildTransactionsList(student),
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
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


   

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: mediumBlue),
          const SizedBox(height: 16),
          Text(
            'No students in this batch',
            style: TextStyle(
              fontSize: 18,
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add students to see them here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final ValueChanged<bool>? onExpansionChanged;
  final Key? key;

  const CustomExpansionTile({
    this.key,
    required this.title,
    this.children = const [],
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    // Collapse other expanded tiles
    _collapseOtherTiles();

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    widget.onExpansionChanged?.call(_isExpanded);
  }

  void _collapseOtherTiles() {
    // Find the nearest ListView and collapse other tiles
    final listViewContext = context.findAncestorWidgetOfExactType<ListView>();
    if (listViewContext != null) {
      final listViewState = context.findAncestorStateOfType<State>();
      if (listViewState != null) {
        listViewState.setState(() {
          // You might need to implement a mechanism to track and collapse other tiles
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleExpansion,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: widget.title),
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(_heightAnimation),
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _heightAnimation,
          child: Column(
            children: widget.children,
          ),
        ),
      ],
    );
  }
}