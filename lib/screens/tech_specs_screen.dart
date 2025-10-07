import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
  bool _usingCachedData = false;

  @override
  void initState() {
    super.initState();
    _loadSpecs();
  }

  Future<String> _getCacheFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/cached_specs.json';
  }

  Future<void> _saveCacheData(List<Map<String, dynamic>> data) async {
    try {
      final filePath = await _getCacheFilePath();
      final file = File(filePath);
      
      final cacheData = {
        'status': true,
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'phones': data,
        },
      };
      
      await file.writeAsString(json.encode(cacheData));
      print('Cache saved successfully at $filePath');
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadCacheData() async {
    try {
      final filePath = await _getCacheFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        print('Cache file does not exist');
        return await _loadFallbackData();
      }

      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      
      if (jsonData['status'] == true && jsonData['data'] != null) {
        final phones = jsonData['data']['phones'] as List;
        print('Loaded ${phones.length} phones from cache');
        return phones.cast<Map<String, dynamic>>();
      }
      return await _loadFallbackData();
    } catch (e) {
      print('Error loading cache: $e');
      return await _loadFallbackData();
    }
  }

  Future<List<Map<String, dynamic>>> _loadFallbackData() async {
    try {
      print('Loading fallback data from assets');
      final String jsonString = await rootBundle.loadString('assets/offline_specs.json');
      final jsonData = json.decode(jsonString);
      
      if (jsonData['status'] == true && jsonData['data'] != null) {
        final phones = jsonData['data']['phones'] as List;
        return phones.map((phone) => {
          'phone_name': phone['phone_name'],
          'brand': phone['brand'],
          'slug': phone['slug'],
          'thumbnail': phone['image'],
          'detail': phone['detail'],
          'released': phone['released'],
          'os': phone['os'],
          'storage': phone['storage'],
          'ram': phone['ram'],
          'display': phone['display'],
          'battery': phone['battery'],
          'camera': phone['camera'],
          'price': phone['price'],
        } as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error loading fallback data: $e');
      return [];
    }
  }

  Future<void> _loadSpecs() async {
    HapticFeedback.mediumImpact(); 
    
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    
    setState(() {
      _loading = true;
      _errorMessage = null;
      _usingCachedData = false;
    });

    if (!connectivityProvider.isOnline) {
      try {
        final cachedPhones = await _loadCacheData();
        if (mounted) {
          setState(() {
            _phones = cachedPhones;
            _loading = false;
            _usingCachedData = true;
            _errorMessage = cachedPhones.isEmpty ? 'No cached data available' : null;
          });
          if (cachedPhones.isNotEmpty) {
            HapticFeedback.lightImpact(); 
            _showMessage('Showing cached data', isError: false);
          } else {
            HapticFeedback.heavyImpact(); 
          }
        }
      } catch (e) {
        if (mounted) {
          HapticFeedback.heavyImpact(); 
          setState(() {
            _loading = false;
            _errorMessage = 'Failed to load cached data';
          });
          _showMessage('No internet connection and failed to load cached data', isError: true);
        }
      }
      return;
    }

    try {
      final data = await _service.fetchTechData();
      if (mounted) {
        HapticFeedback.lightImpact(); 
        setState(() {
          _phones = data;
          _errorMessage = null;
          _usingCachedData = false;
        });
        _saveCacheData(data);
      }
    } catch (e) {
      print('Error loading online specs: $e');
      try {
        final cachedPhones = await _loadCacheData();
        if (mounted) {
          setState(() {
            _phones = cachedPhones;
            _usingCachedData = true;
            _errorMessage = cachedPhones.isEmpty ? 'Failed to load tech specs' : null;
          });
          if (cachedPhones.isNotEmpty) {
            HapticFeedback.mediumImpact(); // Partial success haptic
            _showMessage('Failed to load online data. Showing cached data.', isError: true);
          } else {
            HapticFeedback.heavyImpact(); // Error haptic
            _showMessage('Failed to load tech specs. Please try again.', isError: true);
          }
        }
      } catch (cacheError) {
        if (mounted) {
          HapticFeedback.heavyImpact(); // Error haptic
          setState(() => _errorMessage = 'Failed to load tech specs');
          _showMessage('Failed to load tech specs. Please try again.', isError: true);
        }
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

  Future<Map<String, dynamic>> _loadCachedPhoneSpecs(String phoneSlug) async {
    try {
      final filePath = await _getCacheFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        return {};
      }

      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      
      if (jsonData['data'] != null && jsonData['data']['phones'] != null) {
        final phones = jsonData['data']['phones'] as List;
        final phone = phones.firstWhere(
          (p) => p['slug'] == phoneSlug,
          orElse: () => {},
        );
        return phone as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error loading cached phone specs: $e');
      return {};
    }
  }

  Future<void> _showSpecsDialog(String phoneSlug) async {
    HapticFeedback.lightImpact(); // Haptic for selection
    
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    
    if (_usingCachedData || !connectivityProvider.isOnline) {
      final phone = await _loadCachedPhoneSpecs(phoneSlug);
      
      if (phone.isEmpty) {
        HapticFeedback.heavyImpact(); // Error haptic
        _showMessage('Phone details not found', isError: true);
        return;
      }

      _showOfflineSpecsDialog(phone);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          color: Theme.of(context).cardColor,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final specs = await _service.fetchPhoneSpecs(phoneSlug);
      
      if (!mounted) return;
      Navigator.pop(context);

      if (specs.isEmpty) {
        HapticFeedback.heavyImpact(); // Error haptic
        _showMessage('No specifications available', isError: true);
        return;
      }

      HapticFeedback.lightImpact(); // Success haptic

      final specCategories = specs['specifications'] as List<dynamic>? ?? [];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.smartphone, size: 28, color: Theme.of(context).primaryColor),
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
                  if (specs['brand'] != null || specs['release_date'] != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                                Expanded(
                                  child: Text(
                                    'Brand: ${specs['brand']}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          if (specs['release_date'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Release: ${specs['release_date']}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
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
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    valText,
                                    style: const TextStyle(color: Colors.grey),
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
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      HapticFeedback.heavyImpact(); 
      _showMessage('Failed to load specifications', isError: true);
    }
  }

  void _showOfflineSpecsDialog(Map<String, dynamic> phone) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.smartphone, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                phone['phone_name'] ?? 'Unknown',
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cached, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing cached data',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildOfflineSpecItem('Brand', phone['brand']),
                _buildOfflineSpecItem('Released', phone['released']),
                _buildOfflineSpecItem('OS', phone['os']),
                _buildOfflineSpecItem('Storage', phone['storage']),
                _buildOfflineSpecItem('RAM', phone['ram']),
                _buildOfflineSpecItem('Display', phone['display']),
                _buildOfflineSpecItem('Battery', phone['battery']),
                if (phone['camera'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildOfflineSpecItem('Primary', phone['camera']['primary']),
                  _buildOfflineSpecItem('Secondary', phone['camera']['secondary']),
                ],
                _buildOfflineSpecItem('Price', phone['price']),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick(); 
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSpecItem(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _usingCachedData ? Colors.blue.shade100 : Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: _usingCachedData ? Colors.blue.shade300 : Colors.orange.shade300, 
            width: 2
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _usingCachedData ? Icons.cached : Icons.wifi_off,
            color: _usingCachedData ? Colors.blue.shade800 : Colors.orange.shade800,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _usingCachedData ? 'Showing cached data' : 'You are offline',
              style: TextStyle(
                color: _usingCachedData ? Colors.blue.shade900 : Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact(); 
              _loadSpecs();
            },
            child: Text(
              'Retry',
              style: TextStyle(
                color: _usingCachedData ? Colors.blue.shade900 : Colors.orange.shade900
              ),
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
            onPressed: () {
              HapticFeedback.heavyImpact();
              _loadSpecs();
            },
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
                onPressed: () {
                  HapticFeedback.mediumImpact(); 
                  _loadSpecs();
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: Column(
            children: [
              if (!connectivity.isOnline || _usingCachedData) _buildOfflineIndicator(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _phones.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              HapticFeedback.mediumImpact(); 
                              await _loadSpecs();
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
                                  color: Theme.of(context).cardColor,
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
                                        style: const TextStyle(
                                          color: Colors.grey,
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