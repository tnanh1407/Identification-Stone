import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/news_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart'; // Cần để lấy currentUser
import 'package:rock_classifier/view_models/news_view_model.dart';
import 'package:rock_classifier/views/admin/news/news_detail_screen.dart';
// import 'package:rock_classifier/views/admin/news/news_detail_screen.dart';

// =======================================================================
//                           MÀN HÌNH CHÍNH
// =======================================================================
class NewsDataManagement extends StatefulWidget {
  const NewsDataManagement({super.key});

  @override
  State<NewsDataManagement> createState() => _NewsDataManagementState();
}

class _NewsDataManagementState extends State<NewsDataManagement> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsViewModel>(context, listen: false).fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NewsAppBar(),
      body: const NewsBody(),
      floatingActionButton: const NewsFloatingActionButton(),
    );
  }
}

// =======================================================================
//                           CÁC COMPONENT CỦA MÀN HÌNH
// =======================================================================

class NewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("news_management.title".tr()),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'user_management.reload_tooltip'.tr(),
          onPressed: () {
            Provider.of<NewsViewModel>(context, listen: false).fetchNews();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NewsBody extends StatefulWidget {
  const NewsBody({super.key});

  @override
  State<NewsBody> createState() => _NewsBodyState();
}

class _NewsBodyState extends State<NewsBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<NewsViewModel>();
    return Column(
      children: [
        _buildSearchAndSortBar(context, theme, viewModel),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'news_management.news_count'.tr(namedArgs: {'count': viewModel.news.length.toString()}),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.news.isEmpty
                  ? Center(child: Text('common.no_data_available'.tr()))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: viewModel.news.length,
                      itemBuilder: (context, index) {
                        return NewsItemCard(news: viewModel.news[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context, ThemeData theme, NewsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => viewModel.searchNews(value.trim()),
              decoration: InputDecoration(
                hintText: "news_management.search_hint".tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.searchNews('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Card(
            margin: EdgeInsets.zero,
            child: PopupMenuButton(
              icon: Icon(Icons.sort, color: theme.colorScheme.onSurfaceVariant),
              tooltip: "news_management.sort_tooltip".tr(),
              onSelected: (value) {
                viewModel.sortByCreateAt(ascending: value == 'oldest');
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'newest', child: Text("news_management.sort_newest".tr())),
                PopupMenuItem(value: 'oldest', child: Text("news_management.sort_oldest".tr())),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NewsItemCard extends StatelessWidget {
  final NewsModels news;
  const NewsItemCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = news.fileDinhKem != null && news.fileDinhKem!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(newsId: news.uid)));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  color: theme.colorScheme.surfaceVariant,
                  child: hasImage
                      ? Image.network(news.fileDinhKem!, fit: BoxFit.cover)
                      : Icon(Icons.article_outlined, color: theme.colorScheme.onSurfaceVariant, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.tenBaiViet,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news.tacGia ?? 'common.no_data_available'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy, HH:mm').format(news.createAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
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

class NewsFloatingActionButton extends StatelessWidget {
  const NewsFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showAddEditNewsSheet(context),
      tooltip: 'news_management.add_news_tooltip'.tr(),
      child: const Icon(Icons.add),
    );
  }
}

// =======================================================================
//                           BOTTOM SHEET THÊM/SỬA
// =======================================================================

void showAddEditNewsSheet(BuildContext context, {NewsModels? news}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<NewsViewModel>(),
      child: AddEditNewsForm(news: news),
    ),
  );
}

class AddEditNewsForm extends StatefulWidget {
  final NewsModels? news;
  const AddEditNewsForm({super.key, this.news});
  bool get isEditMode => news != null;

  @override
  State<AddEditNewsForm> createState() => _AddEditNewsFormState();
}

class _AddEditNewsFormState extends State<AddEditNewsForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _linkController;

  String? _selectedTopic;
  File? _attachment;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.tenBaiViet);
    _contentController = TextEditingController(text: widget.news?.noiDungBaiViet);
    _linkController = TextEditingController(text: widget.news?.duongDan);
    _selectedTopic = widget.news?.chuDe;
  }

  // ... (dispose controllers)

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<NewsViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final currentUser = authViewModel.currentUser;
    if (currentUser == null) return; // Không có user, không thể thêm/sửa

    final newsData = NewsModels(
      uid: widget.isEditMode ? widget.news!.uid : '',
      tenBaiViet: _titleController.text.trim(),
      noiDungBaiViet: _contentController.text.trim(),
      duongDan: _linkController.text.trim(),
      chuDe: _selectedTopic,
      createAt: widget.isEditMode ? widget.news!.createAt : DateTime.now(),
      // tacGia sẽ được ViewModel điền
    );

    try {
      if (widget.isEditMode) {
        await viewModel.updateNews(newsData, newAttachment: _attachment);
      } else {
        await viewModel.addNews(newsData, currentUser, attachment: _attachment);
      }
      if (navigator.canPop()) navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  Future<void> _pickImage() async {
    final viewModel = context.read<NewsViewModel>();
    final pickedFile = await viewModel.pickImageFromGallery();
    if (pickedFile != null) {
      setState(() {
        _attachment = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<NewsViewModel>();

    final topics = {
      'Knowledge': 'news_management.topics.knowledge'.tr(),
      'Study': 'news_management.topics.study'.tr(),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEditMode ? 'news_management.edit_news_title'.tr() : 'news_management.add_news_title'.tr(),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'news_management.title_label'.tr()),
                validator: (v) => (v == null || v.isEmpty) ? 'news_management.error.title_required'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'news_management.content_label'.tr()),
                validator: (v) => (v == null || v.isEmpty) ? 'news_management.error.content_required'.tr() : null,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(labelText: 'news_management.link_label'.tr()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTopic,
                decoration: InputDecoration(labelText: 'news_management.topic_label'.tr()),
                items: topics.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (value) => setState(() => _selectedTopic = value),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(_attachment == null ? Icons.attach_file : Icons.check_circle_outline),
                label: Text(_attachment == null ? 'news_management.attachment_select_button'.tr() : 'news_management.attachment_selected_button'.tr()),
              ),
              // Hiển thị ảnh đã chọn (nếu có)
              if (_attachment != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('File: ${_attachment!.path.split('/').last}', style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: viewModel.isUpdating ? null : _handleSave,
                child: viewModel.isUpdating
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    : Text(widget.isEditMode ? 'common.update'.tr() : 'common.add'.tr()),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
