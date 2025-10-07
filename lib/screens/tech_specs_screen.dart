import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/specs_service.dart';
import '../providers/connectivity_provider.dart';

class TechSpecsScreen extends StatefulWidget {
  const TechSpecsScreen({Key? key}) : super(key: key);

  @override
  State<TechSpecsScreen> createState() => _TechSpecsScreenState();
}

class _TechSpecsScreenState extends State<TechSpecsScreen> {
  final TechSpecsService _service = TechSpecsService();
  bool _loading = true;
  List<Map<String, dynamic>> _phones = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSpecs();
  }

  Future<void> _loadSpecs() async {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    
    if (!connectivityProvider.isOnline) {
      setState(() {
        _loading = false;
        _errorMessage = 'No internet connection';
      });
      _showMessage('No internet connection. Please check your network.', isError: true);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.fetchTechData();
      if (mounted) {
        setState(() {
          _phones = data;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('Error loading specs: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Failed to load tech specs');
        _showMessage('Failed to load tech specs. Please try again.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _showSpecsDialog(String phoneSlug) async {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    
    if (!connectivityProvider.isOnline) {
      _showMessage('No internet connection available', isError: true);
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final specs = await _service.fetchPhoneSpecs(phoneSlug);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (specs.isEmpty) {
        _showMessage('No specifications available', isError: true);
        return;
      }

      final specCategories = specs['specifications'] as List<dynamic>? ?? [];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.smartphone, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  specs['phone_name'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone info header
                  if (specs['brand'] != null || specs['release_date'] != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (specs['brand'] != null)
                            Row(
                              children: [
                                const Icon(Icons.business, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Brand: ${specs['brand']}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          if (specs['release_date'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Release: ${specs['release_date']}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Specifications
                  ...specCategories.map((cat) {
                    final catTitle = cat['title'] ?? '';
                    final catSpecs = cat['specs'] as List<dynamic>? ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            catTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...catSpecs.map((s) {
                          final val = s['val'];
                          final valText = val is List ? val.join(', ') : val ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${s['key']}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    valText,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showMessage('Failed to load specifications', isError: true);
    }
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade300, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade800, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You are offline',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadSpecs,
            child: Text(
              'Retry',
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _errorMessage != null ? Icons.error_outline : Icons.devices_other,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'No data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSpecs,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Latest Tech Specs'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: connectivity.isOnline ? _loadSpecs : null,
                tooltip: connectivity.isOnline ? 'Refresh' : 'No internet connection',
              ),
            ],
          ),
          body: Column(
            children: [
              // Offline indicator
              if (!connectivity.isOnline) _buildOfflineIndicator(),
              // Main content
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _phones.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: connectivity.isOnline 
                                ? _loadSpecs 
                                : () async {
                                    _showMessage('No internet connection', isError: true);
                                  },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: _phones.length,
                              itemBuilder: (context, index) {
                                final item = _phones[index];
                                final slug = item['slug'] ?? 
                                    item['phone_name'].toString()
                                        .replaceAll(' ', '_')
                                        .toLowerCase();
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item['thumbnail'] != null
                                          ? Image.network(
                                              item['thumbnail'],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.devices_other,
                                                  size: 30,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.devices_other,
                                                size: 30,
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      item['phone_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item['brand'] ?? 'No brand',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () => _showSpecsDialog(slug),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}