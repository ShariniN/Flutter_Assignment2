import 'package:flutter/material.dart';
import '../services/specs_service.dart';
import 'package:assignment1/providers/connectivity_provider.dart';

class TechSpecsScreen extends StatefulWidget {
  const TechSpecsScreen({Key? key}) : super(key: key);

  @override
  State<TechSpecsScreen> createState() => _TechSpecsScreenState();
}

class _TechSpecsScreenState extends State<TechSpecsScreen> {
  final TechSpecsService _service = TechSpecsService();
  bool _loading = true;
  List<Map<String, dynamic>> _phones = [];

  @override
  void initState() {
    super.initState();
    _loadSpecs();
  }

  Future<void> _loadSpecs() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchTechData();
      setState(() => _phones = data);
    } catch (e) {
      print('Error loading specs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load tech specs')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showSpecsDialog(String phoneSlug) async {
    final specs = await _service.fetchPhoneSpecs(phoneSlug);
    if (specs.isEmpty) return;

    final specCategories = specs['specifications'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(specs['phone_name'] ?? 'Unknown'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (specs['brand'] != null) Text('Brand: ${specs['brand']}'),
                if (specs['release_date'] != null)
                  Text('Release: ${specs['release_date']}'),
                const SizedBox(height: 10),
                ...specCategories.map((cat) {
                  final catTitle = cat['title'] ?? '';
                  final catSpecs = cat['specs'] as List<dynamic>? ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(catTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...catSpecs.map((s) {
                        final val = s['val'];
                        // val can be List or String
                        final valText = val is List ? val.join(', ') : val ?? '';
                        return Text('${s['key']}: $valText');
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Tech Specs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSpecs,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _phones.isEmpty
              ? const Center(child: Text('No data available'))
              : RefreshIndicator(
                  onRefresh: _loadSpecs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _phones.length,
                    itemBuilder: (context, index) {
                      final item = _phones[index];
                      final slug = item['slug'] ?? item['phone_name'].toString().replaceAll(' ', '_').toLowerCase();
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: item['thumbnail'] != null
                              ? Image.network(item['thumbnail'], width: 60, height: 60, fit: BoxFit.cover)
                              : const Icon(Icons.devices_other, size: 40),
                          title: Text(item['phone_name'] ?? 'Unknown'),
                          subtitle: Text(item['brand'] ?? 'No brand'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showSpecsDialog(slug),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
