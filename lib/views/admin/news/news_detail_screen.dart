import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/news_models.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/view_models/news_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

// =======================================================================
//                    MÀN HÌNH CHÍNH: CHI TIẾT BÀI VIẾT
// =======================================================================
class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<NewsViewModel>(
      builder: (context, viewModel, child) {
        final news = viewModel.news.firstWhere(
          (n) => n.uid == newsId,
          orElse: () => NewsModels.empty,
        );

        if (news.isEmpty) {
          Future.microtask(() => Navigator.of(context).pop());
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            title: Text("news_detail.title".tr()),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, news),
                const Divider(height: 32),
                if (news.fileDinhKem != null && news.fileDinhKem!.isNotEmpty) _buildAttachmentSection(context, news),
                _buildSection(context, 'news_detail.content'.tr(), news.noiDungBaiViet),
                if (news.duongDan != null && news.duongDan!.isNotEmpty) _buildLinkSection(context, news.duongDan!),
                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: () => _showAddEditNewsSheet(context, news: news),
                label: Text('news_detail.edit_button'.tr()),
                icon: const Icon(Icons.edit_outlined),
                heroTag: 'edit_news_fab',
              ),
              const SizedBox(width: 12),
              FloatingActionButton.extended(
                onPressed: () => _showDeleteNewsConfirmationDialog(context, news: news),
                label: Text('news_detail.delete_button'.tr()),
                icon: const Icon(Icons.delete_outline),
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                heroTag: 'delete_news_fab',
              ),
            ],
          ),
        );
      },
    );
  }

  // ... (Các hàm _build... giữ nguyên)
  Widget _buildHeader(BuildContext context, NewsModels news) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(news.tenBaiViet, style: theme.textTheme.displaySmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _InfoChip(
              icon: Icons.person_outline,
              label: 'news_detail.author'.tr(),
              value: news.tacGia ?? 'N/A',
            ),
            _InfoChip(
              icon: Icons.topic_outlined,
              label: 'news_detail.topic'.tr(),
              value: news.chuDe ?? 'N/A',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.access_time_outlined, size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              DateFormat('dd/MM/yyyy, HH:mm').format(news.createAt),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentSection(BuildContext context, NewsModels news) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('news_detail.attachment'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              color: theme.colorScheme.surfaceVariant,
              child: Image.network(
                news.fileDinhKem!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkSection(BuildContext context, String url) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('news_detail.link'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              url,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const Divider(height: 16),
          Text(content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

// =======================================================================
//                      WIDGETS & DIALOGS ĐƯỢC GỘP VÀO
// =======================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.onSecondaryContainer),
      label: Text('$label: $value'),
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer),
    );
  }
}

void _showDeleteNewsConfirmationDialog(BuildContext context, {required NewsModels news}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('user_management.delete_confirmation_title'.tr()),
      content: Text('news_detail.delete_confirmation_content'.tr(namedArgs: {'title': news.tenBaiViet})),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('common.cancel'.tr())),
        TextButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final viewModel = Provider.of<NewsViewModel>(context, listen: false);
            try {
              await viewModel.deleteNews(news);
              Navigator.pop(dialogContext);
            } catch (e) {
              Navigator.pop(dialogContext);
              messenger.showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: Text('common.delete'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    ),
  );
}

void _showAddEditNewsSheet(BuildContext context, {NewsModels? news}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: context.read<NewsViewModel>()),
        ChangeNotifierProvider.value(value: context.read<AuthViewModel>()),
      ],
      child: _AddEditNewsForm(news: news),
    ),
  );
}

class _AddEditNewsForm extends StatefulWidget {
  final NewsModels? news;
  const _AddEditNewsForm({this.news});
  bool get isEditMode => news != null;

  @override
  State<_AddEditNewsForm> createState() => _AddEditNewsFormState();
}

class _AddEditNewsFormState extends State<_AddEditNewsForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _linkController;

  String? _selectedTopic;
  File? _attachment;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.tenBaiViet);
    _contentController = TextEditingController(text: widget.news?.noiDungBaiViet);
    _linkController = TextEditingController(text: widget.news?.duongDan);
    _selectedTopic = widget.news?.chuDe ?? 'Knowledge';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<NewsViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final UserModels? currentUser = authViewModel.currentUser;
    if (currentUser == null) {
      messenger.showSnackBar(SnackBar(content: Text('auth.errors.user_not_found'.tr()), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }

    final newsData = NewsModels(
      uid: widget.isEditMode ? widget.news!.uid : '',
      tenBaiViet: _titleController.text.trim(),
      noiDungBaiViet: _contentController.text.trim(),
      duongDan: _linkController.text.trim(),
      chuDe: _selectedTopic,
      createAt: widget.isEditMode ? widget.news!.createAt : DateTime.now(),
      tacGia: widget.isEditMode ? widget.news!.tacGia : (currentUser.fullName ?? currentUser.email),
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
