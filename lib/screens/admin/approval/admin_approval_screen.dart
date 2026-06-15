import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/admin_provider.dart';
class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Duyệt'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Seller mới'),
              Tab(text: 'Shop đã duyệt'),
              Tab(text: 'Sản phẩm mới'),
              Tab(text: 'Flash Sale'),
            ],
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: const TabBarView(
          children: [
            _SellerApprovalTab(),
            _ApprovedShopsTab(),
            _ProductApprovalTab(),
            _FlashSaleApprovalTab(),
          ],
        ),
      ),
    );
  }
}

class _SellerApprovalTab extends ConsumerWidget {
  const _SellerApprovalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsState = ref.watch(adminRequestsNotifierProvider);
    
    return requestsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('Không có yêu cầu nào chờ duyệt.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final displayId = req.requestId.length > 8 ? req.requestId.substring(0, 8) : req.requestId;
            final daysAgo = req.createdAt != null 
              ? DateTime.now().difference(req.createdAt!).inDays 
              : 0;
            final dateStr = daysAgo == 0 ? 'Hôm nay' : '$daysAgo ngày trước';

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
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.storefront, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Yêu cầu mở shop: #$displayId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Đăng ký: $dateStr', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Chờ duyệt', style: TextStyle(color: Colors.orange, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showRejectDialog(context, ref, req.requestId),
                          child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final success = await ref.read(adminRequestsNotifierProvider.notifier).approveRequest(req.requestId, "Approved");
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt thành công')));
                            }
                          },
                          child: const Text('Phê duyệt'),
                        ),
                      ],
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

  void _showRejectDialog(BuildContext context, WidgetRef ref, String requestId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối yêu cầu'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Nhập lý do từ chối...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final reason = textController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(ctx);
              final success = await ref.read(adminRequestsNotifierProvider.notifier).rejectRequest(requestId, reason);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối thành công')));
              }
            },
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }
}

class _ApprovedShopsTab extends ConsumerWidget {
  const _ApprovedShopsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final approvedState = ref.watch(adminApprovedRequestsProvider);

    return approvedState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('Chưa có shop nào được duyệt.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final displayId = req.requestId.length > 8 ? req.requestId.substring(0, 8) : req.requestId;

            return Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                title: Text('Shop #${displayId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Ngày duyệt: ${req.createdAt != null ? "${req.createdAt!.day}/${req.createdAt!.month}/${req.createdAt!.year}" : "N/A"}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Đã duyệt', style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductApprovalTab extends StatelessWidget {
  const _ProductApprovalTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Danh sách Sản phẩm đang chờ duyệt hiển thị lên trang chủ'));
  }
}

class _FlashSaleApprovalTab extends StatelessWidget {
  const _FlashSaleApprovalTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Giao diện quản lý Flash Sale & Duyệt sản phẩm tham gia'));
  }
}
