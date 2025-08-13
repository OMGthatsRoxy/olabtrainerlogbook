import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../services/data_service.dart';
import '../widgets/prospect_card.dart';
import 'add_prospect_screen.dart';
import 'prospect_detail_screen.dart';

class ProspectsScreen extends StatefulWidget {
  const ProspectsScreen({super.key});

  @override
  State<ProspectsScreen> createState() => _ProspectsScreenState();
}

class _ProspectsScreenState extends State<ProspectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Prospect> _filteredProspects = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProspects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProspects() {
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
                    '潜在客户',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '管理潜在客户信息',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 主要内容区域
            Expanded(
              child: StreamBuilder<List<Prospect>>(
                stream: Provider.of<DataService>(
                  context,
                  listen: false,
                ).streamProspects(),
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
                        '加载潜在客户数据失败: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final prospects = snapshot.data ?? [];

                  // 应用搜索过滤
                  if (_searchController.text.isEmpty) {
                    _filteredProspects = prospects;
                  } else {
                    _filteredProspects = prospects
                        .where(
                          (prospect) =>
                              prospect.name.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ) ||
                              prospect.phone.contains(_searchController.text),
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
                            hintText: '搜索潜在客户姓名或电话',
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
                        child: _filteredProspects.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '暂无潜在客户',
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
                                itemCount: _filteredProspects.length,
                                itemBuilder: (context, index) {
                                  final prospect = _filteredProspects[index];
                                  return ProspectCard(
                                    prospect: prospect,
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProspectDetailScreen(
                                                prospect: prospect,
                                              ),
                                        ),
                                      );

                                      // 如果转换成功，StreamBuilder会自动更新
                                      if (result == true) {
                                        // 不需要手动刷新，StreamBuilder会处理
                                      }
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
        heroTag: 'prospects_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProspectScreen()),
          ).then((_) {
            // _loadProspects(); // This line is no longer needed as StreamBuilder handles updates
          });
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
          '筛选潜在客户',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('全部', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  // _filteredProspects = _prospects; // This line is no longer needed
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('已联系', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  // _filteredProspects = _prospects // This line is no longer needed
                  //     .where(
                  //       (prospect) =>
                  //           prospect.status == ProspectStatus.contacted,
                  //     )
                  //     .toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('感兴趣', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  // _filteredProspects = _prospects // This line is no longer needed
                  //     .where(
                  //       (prospect) =>
                  //           prospect.status == ProspectStatus.interested,
                  //     )
                  //     .toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('不感兴趣', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  // _filteredProspects = _prospects // This line is no longer needed
                  //     .where(
                  //       (prospect) =>
                  //           prospect.status == ProspectStatus.notInterested,
                  //     )
                  //     .toList();
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
