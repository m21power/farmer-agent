import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maize_guard/dependency_injection.dart';
import 'package:maize_guard/features/auth/domain/entities/entity.dart';
import 'package:maize_guard/features/auth/presentation/pages/login_page.dart';
import 'package:maize_guard/features/community/presentation/bloc/community_bloc.dart';
import 'package:maize_guard/features/help/presentation/pages/help_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Resource/presentation/pages/resource_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../community/presentation/pages/community_page.dart';
import '../../../help/presentation/pages/history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

  late List<Widget> _pages = [
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        setState(() {
          userData = User(
            firstName: userMap['firstName'] ?? '',
            lastName: userMap['lastName'] ?? '',
            phone: userMap['phone'] ?? '',
            email: userMap['email'] ?? '',
            password: userMap['password'] ?? '',
            role: userMap['role'] ?? '',
          );

          _pages = [
            ProfilePage(user: userData),
            HelpPage(),
            CommunityPage(),
            HistoryPage(),
            ResourcePage(),
          ];
        });
      } else {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginPage()));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    }
  }

  User? userData;

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Maize Guard',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 23, 165, 28),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 23, 165, 28),
                  ),
                  accountName:
                      Text("${userData!.firstName} ${userData!.lastName}"),
                  accountEmail: Text(userData!.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/${jsonDecode(sl<SharedPreferences>().getString("user") ?? "{\"role\":\"farmer\"}")["role"].toLowerCase()}.png",
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: const Text('Profile'),
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.green),
                  title: const Text('Ask'),
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.forum,
                    color: state.notifications.isNotEmpty
                        ? Colors.red
                        : Colors.green,
                  ),
                  title: const Text('Community'),
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.green),
                  title: const Text('History'),
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.school, color: Colors.green),
                  title: const Text('Educational Resources'),
                  onTap: () {
                    setState(() => _currentIndex = 4);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.green),
                  title: const Text('Logout'),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Logout"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(AuthLogoutEvent());
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 23, 165, 28),
                            ),
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
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
          body: _pages[_currentIndex],
        );
      },
    );
  }
}
