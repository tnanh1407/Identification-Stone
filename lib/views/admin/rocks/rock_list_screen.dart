import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/admin/rocks/add_edit_rock_sheet.dart';
import 'package:rock_classifier/views/admin/rocks/rock_detail_screen.dart';
// import 'package:rock_classifier/views/admin/rocks/add_edit_rock_sheet.dart'; // Sẽ cần khi hoàn thiện

class RockListScreen extends StatefulWidget {
  const RockListScreen({super.key});

  @override
  State<RockListScreen> createState() => _RockListScreenState();
}

class _RockListScreenState extends State<RockListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Chỉ cần fetch dữ liệu một lần khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RockViewModel>(context, listen: false).fetchRocks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<RockViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('rock_management.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'user_management.reload_tooltip'.tr(), // Tái sử dụng key
            onPressed: () {
              _searchController.clear();
              // Gọi search với chuỗi rỗng để reset danh sách về ban đầu
              Provider.of<RockViewModel>(context, listen: false).searchRocks('');
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSortBar(context, theme, viewModel),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'rock_management.rock_count'.tr(namedArgs: {'count': viewModel.rocks.length.toString()}),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.rocks.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: viewModel.rocks.length,
                        itemBuilder: (context, index) {
                          final rock = viewModel.rocks[index];
                          return _RockItemCard(rock: rock);
                        },
                      ),
          ),
        ],
      ),
// trong file rock_list_screen.dart

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // SỬA: Gọi hàm hiển thị bottom sheet để thêm đá mới
          showAddEditRockSheet(context);
        },
        tooltip: 'rock_management.add_rock_tooltip'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context, ThemeData theme, RockViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              // SỬA: Dùng onChanged là cách đúng và đơn giản nhất
              onChanged: (value) {
                viewModel.searchRocks(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'rock_management.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                // THÊM: Nút xóa nhanh text trong ô tìm kiếm
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.searchRocks('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Card(
            margin: EdgeInsets.zero,
            child: PopupMenuButton<RockSortOption>(
              icon: Icon(Icons.sort, color: theme.colorScheme.onSurfaceVariant),
              tooltip: 'rock_management.sort_tooltip'.tr(),
              onSelected: (option) => viewModel.sortRocks(option),
              itemBuilder: (context) => [
                _buildSortMenuItem(context, icon: Icons.sort_by_alpha, textKey: 'rock_management.sort_by_name', option: RockSortOption.tenDa),
                _buildSortMenuItem(context, icon: Icons.category_outlined, textKey: 'rock_management.sort_by_type', option: RockSortOption.loaiDa),
                _buildSortMenuItem(context, icon: Icons.account_tree_outlined, textKey: 'rock_management.sort_by_group', option: RockSortOption.nhomDa),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<RockSortOption> _buildSortMenuItem(BuildContext context, {required IconData icon, required String textKey, required RockSortOption option}) {
    final theme = Theme.of(context);
    return PopupMenuItem<RockSortOption>(
      value: option,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(textKey.tr()),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: theme.colorScheme.secondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('rock_management.no_rock_found_title'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('rock_management.no_rock_found_subtitle'.tr(), style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// --- WIDGET CON CHO MỘT ITEM ĐÁ ---
class _RockItemCard extends StatelessWidget {
  final rock;
  const _RockItemCard({required this.rock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = rock.hinhAnh.isNotEmpty;
    final firstImage = hasImage ? rock.hinhAnh.first : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: Provider.of<RockViewModel>(context, listen: false),
                child: RockDetailScreen(rockId: rock.uid),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: theme.colorScheme.surfaceVariant,
                  child: hasImage
                      ? Image.network(
                          firstImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported_outlined, color: theme.colorScheme.secondary),
                        )
                      : Icon(Icons.terrain_outlined, color: theme.colorScheme.secondary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rock.tenDa ?? 'rock_management.unnamed_rock'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'rock_management.type_label'.tr()}: ${rock.loaiDa ?? 'rock_management.unknown'.tr()}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${'rock_management.group_label'.tr()}: ${rock.nhomDa ?? 'rock_management.unknown'.tr()}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
