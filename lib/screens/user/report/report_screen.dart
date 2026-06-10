import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/report_model.dart';
import '../../../data/services/report_service.dart';
import '../../../providers/theme_provider.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reports = await ref.read(reportServiceProvider).getMyReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showSubmitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SubmitReportSheet(
        onSubmit: (body) async {
          Navigator.pop(ctx);
          setState(() => _isLoading = true);
          try {
            await ref.read(reportServiceProvider).submitReport(body);
            Fluttertoast.showToast(msg: 'Gui bao cao thanh cong!');
            _loadReports();
          } catch (e) {
            Fluttertoast.showToast(
              msg: e.toString().replaceFirst('Exception: ', ''),
              backgroundColor: AppColors.error,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    final pendingReports = _reports.where((r) => r.status == 'PENDING').toList();
    final resolvedReports = _reports.where((r) => r.status != 'PENDING').toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Bao cao & Ho tro'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          tabs: const [
            Tab(text: 'Dang xu ly'),
            Tab(text: 'Da giai quyet'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReports,
                        child: const Text('Thu lai'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportList(pendingReports, isDark, true),
                    _buildReportList(resolvedReports, isDark, false),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSubmitDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.report_problem),
        label: const Text('Gui bao cao'),
      ),
    );
  }

  Widget _buildReportList(List<Report> reports, bool isDark, bool isPending) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.hourglass_empty : Icons.check_circle_outline,
              size: 64,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'Khong co bao cao dang xu ly' : 'Khong co bao cao da giai quyet',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _ReportCard(report: report, isDark: isDark);
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final bool isDark;

  const _ReportCard({required this.report, required this.isDark});

  Color get _statusColor {
    switch (report.status) {
      case 'PENDING':
        return AppColors.warning;
      case 'RESOLVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.typeLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.statusLabel,
                    style: TextStyle(fontSize: 12, color: _statusColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.reason,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            if (report.description != null && report.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                report.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
                if (report.resolvedAt != null) ...[
                  const Spacer(),
                  Icon(Icons.check_circle, size: 14, color: _statusColor),
                  const SizedBox(width: 4),
                  Text(
                    'Giai quyet: ${_formatDate(report.resolvedAt!)}',
                    style: TextStyle(fontSize: 12, color: _statusColor),
                  ),
                ],
              ],
            ),
            if (report.adminNote != null && report.adminNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.adminNote!,
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SubmitReportSheet extends ConsumerStatefulWidget {
  final Function(ReportSubmitBody) onSubmit;

  const _SubmitReportSheet({required this.onSubmit});

  @override
  ConsumerState<_SubmitReportSheet> createState() => _SubmitReportSheetState();
}

class _SubmitReportSheetState extends ConsumerState<_SubmitReportSheet> {
  String _selectedType = 'ORDER';
  final _reasonController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _reportTypes = [
    ('ORDER', 'Don hang'),
    ('PRODUCT', 'San pham'),
    ('SELLER', 'Nguoi ban'),
    ('REVIEW', 'Danh gia'),
    ('OTHER', 'Khac'),
  ];

  final _reasonOptions = {
    'ORDER': ['Don hang chua nhan duoc', 'San pham sai mo ta', 'Huy don khong duoc', 'Hoan tien', 'Khac'],
    'PRODUCT': ['San pham hong', 'San pham gia ta', 'Sai thong tin', 'Khac'],
    'SELLER': ['Ban hang gia ta', 'Khong uy tin', 'Spam', 'Khac'],
    'REVIEW': ['Noi dung khong phu hop', 'Spam', 'Khac'],
    'OTHER': ['Van de khac'],
  };

  String _selectedReason = '';

  @override
  void initState() {
    super.initState();
    _updateReasons();
  }

  void _updateReasons() {
    final reasons = _reasonOptions[_selectedType] ?? [];
    _selectedReason = reasons.isNotEmpty ? reasons.first : '';
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(ReportSubmitBody(
      reportType: _selectedType,
      reason: _selectedReason.isNotEmpty ? _selectedReason : _reasonController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Gui bao cao', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('Loai bao cao', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reportTypes.map((t) {
                  final isSelected = _selectedType == t.$1;
                  return ChoiceChip(
                    label: Text(t.$2),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) {
                      setState(() {
                        _selectedType = t.$1;
                        _updateReasons();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Ly do', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_reasonOptions[_selectedType] ?? []).map((r) {
                  final isSelected = _selectedReason == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    selectedColor: AppColors.warning.withOpacity(0.2),
                    onSelected: (_) => setState(() => _selectedReason = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Mo ta chi tiet', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Mo ta van de cua ban...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Gui bao cao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}
