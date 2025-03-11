import 'package:flutter/material.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:pblmsadmin/screens/admin/course_management/attandance.dart';
import 'package:provider/provider.dart';

class UsersTabView extends StatefulWidget {
  const UsersTabView({super.key});

  @override
  _UsersTabViewState createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView>
    with SingleTickerProviderStateMixin {
  int? selectedUserId;
  late TabController _tabController;
  bool isLoading = false;
  final Color primaryBlue = const Color(0xFF2E7D32);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color.fromARGB(255, 155, 246, 159);
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Use Future.microtask to fetch all users
    Future.microtask(() async {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.AdminfetchallusersProvider();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Get approved users directly from the users list based on approved flag
  List<dynamic> _getApprovedUsers(List<dynamic>? allUsers) {
    if (allUsers == null) return [];
    return allUsers.where((user) => user.approved == true).toList();
  }

  // Get unapproved users directly from the users list based on approved flag
  List<dynamic> _getUnapprovedUsers(List<dynamic>? allUsers) {
    if (allUsers == null) return [];
    return allUsers.where((user) => user.approved == false).toList();
  }

  Future<void> _handleApproval(int userId, String role, String action) async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.adminApproveUserprovider(
        userId: userId,
        role: role,
        action: action,
      );

      if (mounted) {
        // Refresh users list after approval/rejection
        await provider.AdminfetchallusersProvider();

        _showSnackBar(
          action == 'approve'
              ? 'User approved successfully'
              : 'User deleted successfully',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final query = searchQuery.toLowerCase();
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final phoneNumber = (user.phoneNumber?.toLowerCase() ?? '');
      final registrationId = (user.registrationId?.toLowerCase() ?? '');

      return name.contains(query) ||
          email.contains(query) ||
          phoneNumber.contains(query) ||
          registrationId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allUsersProvider = Provider.of<AdminAuthProvider>(context);
    final allUsers = allUsersProvider.users ?? [];

    // Get approved and unapproved users based on the approved flag
    final approvedUsers = _getApprovedUsers(allUsers);
    final unapprovedUsers = _getUnapprovedUsers(allUsers);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Users Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          labelColor: Colors.green[900],
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Approved Users'),
            Tab(text: 'Pending Approvals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, color: primaryBlue),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, color: primaryBlue),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                        : null,
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
                  borderSide: BorderSide(color: primaryBlue),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Approved Users Tab
                _buildUserList(
                  approvedUsers,
                  allUsersProvider.isLoading,
                  'approved',
                ),
                // Unapproved Users Tab
                _buildUserList(
                  unapprovedUsers,
                  allUsersProvider.isLoading,
                  'unapproved',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users, bool isLoading, String listType) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              listType == 'approved'
                  ? 'No approved users available'
                  : 'No pending approvals available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final filteredUsers = _filterUsers(users);
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(listType);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildExpandableUserCard(user, listType);
      },
    );
  }

  Widget _buildExpandableUserCard(dynamic user, String listType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to Attendance History Screen when user card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AttendanceHistoryScreen(studentId: user.userId),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (user.phoneNumber != null &&
                              user.phoneNumber.isNotEmpty) ...[
                            Icon(
                              Icons.phone,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.phoneNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Show approval badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  user.approved
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.approved ? 'APPROVED' : 'PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    user.approved
                                        ? Colors.green[700]
                                        : Colors.amber[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (listType == 'unapproved')
                      TextButton(
                        onPressed:
                            () => _handleApproval(
                              user.userId,
                              user.role,
                              'approve',
                            ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          minimumSize: const Size(80, 40),
                        ),
                        child: const Text('Approve'),
                      ),
                    TextButton(
                      onPressed:
                          () =>
                              _handleApproval(user.userId, user.role, 'reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        minimumSize: const Size(80, 40),
                      ),
                      child: Text(
                        listType == 'unapproved' ? 'Reject' : 'Delete',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String listType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: mediumBlue),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? listType == 'unapproved'
                    ? 'No pending approvals'
                    : 'No approved users found'
                : 'No matching users found',
            style: TextStyle(
              fontSize: 18,
              color: primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
