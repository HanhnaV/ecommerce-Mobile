import 'package:flutter/material.dart';

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hỗ trợ & Chat'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          bottom: TabBar(
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Xử lý Báo cáo'),
              Tab(text: 'Trung tâm Chat'),
            ],
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: const TabBarView(
          children: [
            _ReportsTab(),
            _ChatCenterTab(),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ticket #${2040 + index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Khẩn cấp', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Khách hàng báo cáo sản phẩm không đúng mô tả. Yêu cầu hoàn tiền gấp.'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Đóng Ticket', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text('Xử lý ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatCenterTab extends StatelessWidget {
  const _ChatCenterTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF2563EB),
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text('Khách hàng ${index + 1}', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          subtitle: const Text('Cho mình hỏi về quy trình hoàn tiền ạ?'),
          trailing: const Text('10:45 AM'),
          onTap: () {},
        );
      },
    );
  }
}
