import 'package:flutter/material.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';
import '../widgets/app_bottom_nav.dart';
import '../../core/services/listening_history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _history = [];
  int _page = 1;
  int _size = 20;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = null;
    });

    try {
      final result = await ListeningHistoryService.instance.fetchHistory(
        page: _page,
        size: _size,
      );
      final data = result['data'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(data['items'] as List? ?? []);
          _total = data['total'] as int? ?? 0;
        });
      } else {
        setState(() {
          _history = [];
          _total = 0;
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
      AppToast.showError(context, _errorMessage ?? 'Lỗi khi tải lịch sử nghe');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Thoát ứng dụng?'),
            content: const Text('Bạn có chắc muốn thoát không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Lịch sử nghe'), automaticallyImplyLeading: false),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error
                ? Center(child: Text(_errorMessage ?? 'Đã có lỗi xảy ra.'))
                : _history.isEmpty
                    ? const Center(child: Text('Bạn chưa có lịch sử nghe.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          final listenedAt = item['listened_at'];
                          final duration = item['listen_duration'];
                          final stallName = item['stall_name'] ?? 'Unknown stall';
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.music_note)),
                            title: Text(stallName),
                            subtitle: Text('Nghe lúc ${DateTime.fromMillisecondsSinceEpoch((listenedAt ?? 0) * 1000)}'),
                            trailing: Text(duration != null ? '${duration}s' : '-'),
                          );
                        },
                      ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      ),
    );
  }
}
