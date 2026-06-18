import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_chat_provider.dart';

class AdminMainLayout extends ConsumerStatefulWidget {
  const AdminMainLayout({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends ConsumerState<AdminMainLayout> {
  @override
  void initState() {
    super.initState();
    // Kết nối socket admin ngay khi vào layout chính
    Future.microtask(() {
      ref.read(adminChatProvider.notifier).connect();
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        indicatorColor: const Color(0xFF2563EB).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF2563EB)),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified, color: Color(0xFF2563EB)),
            label: 'Duyệt',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFF2563EB)),
            label: 'Đơn hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent, color: Color(0xFF2563EB)),
            label: 'Hỗ trợ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF2563EB)),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
