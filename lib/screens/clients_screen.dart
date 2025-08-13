import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../services/data_service.dart';
import '../widgets/client_card.dart';
import 'client_detail_screen.dart';
import 'add_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClients() {
    setState(() {
      // 触发重建以应用搜索过滤
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20), // 增加顶部间距
            // 标题区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    '客户管理',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '管理您的客户信息',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 主要内容区域
            Expanded(
              child: StreamBuilder<List<Client>>(
                stream: Provider.of<DataService>(
                  context,
                  listen: false,
                ).streamClients(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF667eea),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '加载客户数据失败: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final clients = snapshot.data ?? [];

                  // 应用搜索过滤
                  if (_searchController.text.isEmpty) {
                    _filteredClients = clients;
                  } else {
                    _filteredClients = clients
                        .where(
                          (client) =>
                              client.name.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ) ||
                              client.phone.contains(_searchController.text),
                        )
                        .toList();
                  }

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '搜索客户姓名或电话',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF667eea),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _filteredClients.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '暂无客户',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _filteredClients.length,
                                itemBuilder: (context, index) {
                                  final client = _filteredClients[index];
                                  return ClientCard(
                                    client: client,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ClientDetailScreen(
                                                client: client,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'clients_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
        },
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '筛选客户',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('全部客户', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final dataService = Provider.of<DataService>(
                  context,
                  listen: false,
                );
                final clients = await dataService.getClients();
                setState(() {
                  _filteredClients = clients;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('活跃客户', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final dataService = Provider.of<DataService>(
                  context,
                  listen: false,
                );
                final clients = await dataService.getClients();
                setState(() {
                  _filteredClients = clients
                      .where((client) => client.status == ClientStatus.active)
                      .toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('非活跃客户', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final dataService = Provider.of<DataService>(
                  context,
                  listen: false,
                );
                final clients = await dataService.getClients();
                setState(() {
                  _filteredClients = clients
                      .where((client) => client.status == ClientStatus.inactive)
                      .toList();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
