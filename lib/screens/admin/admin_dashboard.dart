import 'package:flutter/material.dart';
import 'package:pblmsadmin/screens/admin/Grivenece_management.dart';
import 'package:pblmsadmin/screens/admin/batch_management/add_teachertobatch_couse.dart';
import 'package:pblmsadmin/screens/admin/batch_management/admin_addtobatch_course.dart';
import 'package:pblmsadmin/screens/admin/batch_management/admin_live_management.dart';
import 'package:pblmsadmin/screens/admin/course_management/admin_add_course.dart';
import 'package:pblmsadmin/screens/admin/course_management/admin_course_batch.dart';
import 'package:pblmsadmin/screens/admin/course_management/admin_see_all_users.dart';
import 'package:pblmsadmin/screens/admin/widgets/bottom.dart';
import 'package:pblmsadmin/screens/admin/widgets/dashboard.dart';
import 'package:pblmsadmin/screens/admin/widgets/searchfiled.dart';
import 'package:pblmsadmin/screens/admin/widgets/sidebarbutton.dart';
import 'package:pblmsadmin/screens/admin/widgets/usercard.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String currentRoute = 'CourseManagement';
  bool isCourseExpanded = false;
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void navigateTo(String route) {
    setState(() {
      currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar:
          isLargeScreen
              ? null
              : AppBar(
                title: Text(currentRoute),
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
      drawer:
          isLargeScreen
              ? null
              : Drawer(
                child: Sidebar(
                  isLargeScreen: isLargeScreen,
                  onNavigate: navigateTo,
                  searchController: searchController,
                  currentRoute: currentRoute,
                  isCourseExpanded: isCourseExpanded,
                  toggleCourseExpand: () {
                    setState(() {
                      isCourseExpanded = !isCourseExpanded;
                    });
                  },
                ),
              ),
      body: Row(
        children: [
          if (isLargeScreen)
            Sidebar(
              isLargeScreen: isLargeScreen,
              onNavigate: navigateTo,
              searchController: searchController,
              currentRoute: currentRoute,
              isCourseExpanded: isCourseExpanded,
              toggleCourseExpand: () {
                setState(() {
                  isCourseExpanded = !isCourseExpanded;
                });
              },
            ),
          Expanded(
            child: ContentArea(
              isLargeScreen: isLargeScreen,
              currentRoute: currentRoute,
              searchController: searchController,
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final Function(String) onNavigate;
  final TextEditingController searchController;
  final bool isLargeScreen;
  final String currentRoute;
  final bool isCourseExpanded;
  final VoidCallback toggleCourseExpand;

  const Sidebar({
    super.key,
    required this.onNavigate,
    required this.searchController,
    required this.isLargeScreen,
    required this.currentRoute,
    required this.isCourseExpanded,
    required this.toggleCourseExpand,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth =
        isLargeScreen ? 300.0 : MediaQuery.of(context).size.width * 0.8;

    return Card(
      elevation: 4,
      child: Container(
        color: Colors.white,
        width: sidebarWidth,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminUserCard(),
                    const SizedBox(height: 20),
                    AdminSearchField(searchController: searchController),
                    const SizedBox(height: 40),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: AdminMainMenu(
                        isLargeScreen: isLargeScreen,
                        onNavigate: onNavigate,
                        currentRoute: currentRoute,
                        isCourseExpanded: isCourseExpanded,
                        toggleCourseExpand: toggleCourseExpand,
                      ),
                    ),
                    const SizedBox(height: 25),
                    AdminBottom(
                      onMenuItemSelected: onNavigate,
                      isLargeScreen: isLargeScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentArea extends StatelessWidget {
  final String currentRoute;
  final TextEditingController searchController;
  final bool isLargeScreen;

  const ContentArea({
    super.key,
    required this.currentRoute,
    required this.searchController,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: _buildContent())],
      ),
    );
  }

  Widget _buildContent() {
    switch (currentRoute) {
      case 'CourseManagement':
        return AdminAddCourse();
      case 'BatchManagement':
        return AdminCourseBatchScreen();
      case 'User':
        return UsersTabView();
      case 'Live':
        return AdminAddLiveCourse();
      case 'Students':
        return AdminAddStudent();
      case 'Grivenece':
        return AdminLeaveRequestScreen();
      default:
        return AdminAddCourse();
    }
  }
}

class AdminMainMenu extends StatelessWidget {
  final Function(String) onNavigate;
  final bool isLargeScreen;
  final String currentRoute;
  final bool isCourseExpanded;
  final VoidCallback toggleCourseExpand;

  const AdminMainMenu({
    super.key,
    required this.onNavigate,
    required this.isLargeScreen,
    required this.currentRoute,
    required this.isCourseExpanded,
    required this.toggleCourseExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 146, 218, 228).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Management Dropdown
            InkWell(
              onTap: toggleCourseExpand,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.book, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Course Management',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      isCourseExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

            // Dropdown items
            if (isCourseExpanded) ...[
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: AdminSidebarButton(
                  icon: Icons.book_online,
                  text: 'Course Management',
                  onTap: () => onNavigate('CourseManagement'),
                  selected: currentRoute == 'CourseManagement',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: AdminSidebarButton(
                  icon: Icons.groups,
                  text: 'Batch Management',
                  onTap: () => onNavigate('BatchManagement'),
                  selected: currentRoute == 'BatchManagement',
                ),
              ),
            ],

            AdminSidebarButton(
              icon: Icons.live_tv,
              text: 'Live Management',
              onTap: () => onNavigate('Live'),
              selected: currentRoute == 'Live',
            ),
            AdminSidebarButton(
              icon: Icons.people_sharp,
              text: 'Students Management',
              onTap: () => onNavigate('Students'),
              selected: currentRoute == 'Students',
            ),
            AdminSidebarButton(
              icon: Icons.person,
              text: 'User Management',
              onTap: () => onNavigate('User'),
              selected: currentRoute == 'User',
            ),
            AdminSidebarButton(
              icon: Icons.person_pin,
              text: 'Grivenece Management',
              onTap: () => onNavigate('Grivenece'),
              selected: currentRoute == 'Grivenece',
            ),
          ],
        ),
      ),
    );
  }
}
