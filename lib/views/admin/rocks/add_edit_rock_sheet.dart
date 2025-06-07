// lib/views/admin/rocks/add_edit_rock_sheet.dart

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';

// --- HÀM HELPER ĐỂ GỌI BOTTOM SHEET ---

void showAddEditRockSheet(BuildContext context, {RockModels? rock}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Cho phép bottom sheet cao hơn nửa màn hình
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<RockViewModel>(context, listen: false),
      child: AddEditRockForm(rock: rock),
    ),
  );
}

// --- WIDGET FORM CHÍNH ---

class AddEditRockForm extends StatefulWidget {
  final RockModels? rock;
  const AddEditRockForm({super.key, this.rock});

  // Helper để biết đang ở chế độ thêm hay sửa
  bool get isEditMode => rock != null;

  @override
  State<AddEditRockForm> createState() => _AddEditRockFormState();
}

class _AddEditRockFormState extends State<AddEditRockForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường text
  late final TextEditingController _tenDaController;
  late final TextEditingController _loaiDaController;
  late final TextEditingController _nhomDaController;
  late final TextEditingController _mieuTaController;
  // ... thêm các controller khác nếu cần

  // State cho hình ảnh
  List<File> _newImages = []; // Ảnh mới người dùng chọn
  List<String> _existingImageUrls = []; // Ảnh cũ khi ở chế độ sửa

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu cũ (nếu là chế độ sửa)
    _tenDaController = TextEditingController(text: widget.rock?.tenDa ?? '');
    _loaiDaController = TextEditingController(text: widget.rock?.loaiDa ?? '');
    _nhomDaController = TextEditingController(text: widget.rock?.nhomDa ?? '');
    _mieuTaController = TextEditingController(text: widget.rock?.mieuTa ?? '');

    if (widget.isEditMode) {
      _existingImageUrls = List.from(widget.rock!.hinhAnh);
    }
  }

  @override
  void dispose() {
    _tenDaController.dispose();
    _loaiDaController.dispose();
    _nhomDaController.dispose();
    _mieuTaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<RockViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Tạo đối tượng RockModels từ form
    final rockData = RockModels(
      uid: widget.isEditMode ? widget.rock!.uid : '', // Sẽ được service gán nếu là thêm mới
      tenDa: _tenDaController.text.trim(),
      loaiDa: _loaiDaController.text.trim(),
      nhomDa: _nhomDaController.text.trim(),
      mieuTa: _mieuTaController.text.trim(),
      hinhAnh: _existingImageUrls, // Gán ảnh cũ vào trước
      // ... gán các trường khác từ controller
    );

    try {
      if (widget.isEditMode) {
        await viewModel.updateRock(rockData, _newImages);
        messenger.showSnackBar(SnackBar(content: Text('rock_management.update_success'.tr()), backgroundColor: Colors.green));
      } else {
        await viewModel.addRock(rockData, _newImages);
        messenger.showSnackBar(SnackBar(content: Text('rock_management.add_success'.tr()), backgroundColor: Colors.green));
      }
      if (navigator.canPop()) navigator.pop(); // Đóng bottom sheet
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  Future<void> _pickImages() async {
    final viewModel = context.read<RockViewModel>();
    final pickedImages = await viewModel.pickImages();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedImages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<RockViewModel>();

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
                widget.isEditMode ? 'rock_management.edit_rock_title'.tr() : 'rock_management.add_rock_title'.tr(),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tenDaController,
                decoration: InputDecoration(labelText: 'Tên đá'),
                validator: (value) => (value == null || value.isEmpty) ? 'rock_management.error.name_required'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loaiDaController,
                decoration: InputDecoration(labelText: 'Loại đá'),
                validator: (value) => (value == null || value.isEmpty) ? 'rock_management.error.type_required'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nhomDaController,
                decoration: InputDecoration(labelText: 'Nhóm đá'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mieuTaController,
                decoration: InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Phần hình ảnh
              _buildImagePicker(),

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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hình ảnh', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Hiển thị các ảnh cũ (nếu có)
              ..._existingImageUrls.map((url) => _buildImageThumbnail(url: url)),
              // Hiển thị các ảnh mới đã chọn
              ..._newImages.map((file) => _buildImageThumbnail(file: file)),
              // Nút thêm ảnh
              InkWell(
                onTap: _pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_a_photo_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail({String? url, File? file}) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url != null ? Image.network(url, fit: BoxFit.cover) : Image.file(file!, fit: BoxFit.cover),
      ),
    );
  }
}
