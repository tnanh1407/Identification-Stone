import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/news_models.dart';
import 'package:rock_classifier/view_models/news_view_model.dart';
import 'package:rock_classifier/views/admin/news/news_detail_screen.dart';
import 'package:rock_classifier/views/admin/users/view/utils_management.dart';

// Main Widget: NewsDataManagement
class NewsDataManagement extends StatefulWidget {
  const NewsDataManagement({super.key});

  @override
  State<NewsDataManagement> createState() => _NewsDataManagementState();
}

class _NewsDataManagementState extends State<NewsDataManagement> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<NewsViewModel>(context, listen: false).fetchNews(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const NewsAppBar(),
      body: NewsBody(searchController: _searchController),
      floatingActionButton: const NewsFloatingActionButton(),
    );
  }
}

// Component: AppBar
class NewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: const BackButton(color: Colors.white),
      backgroundColor: const Color(0xFFF7F7F7),
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        "textManagementNews1".tr(), // Sửa tiêu đề cho phù hợp
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
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

// Component: Body
class NewsBody extends StatelessWidget {
  final TextEditingController searchController;

  const NewsBody({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NewsViewModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'textManagementNews2'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          NewsSearchSortRow(searchController: searchController),
          const SizedBox(height: 16),
          Text(
            'textManagementNews7 ${viewModel.news.length}'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Expanded(child: NewsList()),
        ],
      ),
    );
  }
}

class NewsSearchSortRow extends StatelessWidget {
  final TextEditingController searchController;
  const NewsSearchSortRow({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NewsViewModel>(context, listen: false);
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) => viewModel.searchNews(value.trim()),
            controller: searchController,
            decoration: InputDecoration(
              hintText: "textManagementNews3".tr(),
              hintStyle: Theme.of(context).textTheme.labelMedium,
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.tertiaryFixed),
              filled: true,
              fillColor: Theme.of(context).colorScheme.tertiaryFixedDim,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton(
          icon: Icon(
            Icons.sort,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
          tooltip: "textManagementNews4".tr(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 8,
          onSelected: (value) {
            if (value == "somNhat") {
              viewModel.sortByCreatAtUp();
            }
            if (value == "muonNhat") {
              viewModel.sortByCreatAtDown();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'somNhat',
              child: Row(
                children: [
                  Icon(
                    Icons.switch_access_shortcut_sharp,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text("textManagementNews5".tr(), style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
            ),
            PopupMenuItem(
              value: 'muonNhat',
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text("textManagementNews6".tr(), style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NewsViewModel>(context);
    return viewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : viewModel.error != null
            ? Center(child: Text(viewModel.error!))
            : ListView.builder(
                itemCount: viewModel.news.length,
                itemBuilder: (context, index) {
                  final baiBao = viewModel.news[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(news: baiBao)));
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                          child: (baiBao.fileDinhKem != null && baiBao.fileDinhKem!.isNotEmpty)
                              ? Image.network(
                                  baiBao.fileDinhKem!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 30,
                                  color: Colors.black54,
                                ),
                        ),
                      ),
                      title: Text(baiBao.tenBaiViet, style: Theme.of(context).textTheme.displaySmall),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy - HH:mm').format(baiBao.createAt),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                  );
                },
              );
  }
}

// Component: Floating Action Button
class NewsFloatingActionButton extends StatelessWidget {
  const NewsFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          showAddNewsBottomSheet(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'textManagementNews8'.tr(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Component: Add News Bottom Sheet
void showAddNewsBottomSheet(BuildContext context) {
  final tenBaiVietController = TextEditingController();
  final noiDungController = TextEditingController();
  final duongDanController = TextEditingController();

  String selectedTopic = 'Kiến Thức';
  File? tempImage;
  bool isPressed = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AddNewsHeader(),
                  const SizedBox(height: 20),
                  AddNewsTextField(
                    controller: tenBaiVietController,
                    label: "textManagementNews10".tr(),
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  AddNewsTextField(
                    controller: noiDungController,
                    label: "textManagementNews12".tr(),
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 16),
                  AddNewsTextField(
                    controller: duongDanController,
                    label: "textManagementNews11".tr(),
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  AddNewsDropdown(
                    selectedTopic: selectedTopic,
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedTopic = newValue ?? 'Kiến Thức';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  AddNewsImagePicker(
                    tempImage: tempImage,
                    onImagePicked: (File? image) {
                      setModalState(() {
                        tempImage = image;
                      });
                    },
                  ),
                  if (tempImage != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          tempImage!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AddNewsSubmitButton(
                    tenBaiVietController: tenBaiVietController,
                    noiDungController: noiDungController,
                    duongDanController: duongDanController,
                    selectedTopic: selectedTopic,
                    tempImage: tempImage,
                    isPressed: isPressed,
                    onPressedStateChanged: (bool value) {
                      setModalState(() {
                        isPressed = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Component: Add News Header
class AddNewsHeader extends StatelessWidget {
  const AddNewsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "textManagementNews9",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// Component: Text Field for Add News
class AddNewsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const AddNewsTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
    );
  }
}

// Component: Dropdown for Add News
class AddNewsDropdown extends StatelessWidget {
  final String selectedTopic;
  final ValueChanged<String?> onChanged;

  const AddNewsDropdown({
    super.key,
    required this.selectedTopic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedTopic,
      decoration: InputDecoration(
        labelText: "textManagementNews13".tr(),
        prefixIcon: const Icon(Icons.person, color: Color(0xFF3B82F6)),
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
      items: ['Kiến Thức', 'Học Tập'].map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// Component: Image Picker for Add News
class AddNewsImagePicker extends StatelessWidget {
  final File? tempImage;
  final ValueChanged<File?> onImagePicked;

  const AddNewsImagePicker({
    super.key,
    required this.tempImage,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        tempImage == null ? Icons.image : Icons.check_circle,
        color: Colors.white,
      ),
      label: Text(
        tempImage == null ? "textManagementNews16".tr() : "textManagementNews17".tr(),
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF60A5FA),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      onPressed: () async {
        final granted = await requestPermissionDialog(context);
        if (granted) {
          final viewModel = Provider.of<NewsViewModel>(context, listen: false);
          await viewModel.pickImage(ImageSource.gallery);
          if (viewModel.selectedImage != null) {
            onImagePicked(viewModel.selectedImage);
          }
        }
      },
    );
  }
}

// Component: Submit Button for Add News
class AddNewsSubmitButton extends StatelessWidget {
  final TextEditingController tenBaiVietController;
  final TextEditingController noiDungController;
  final TextEditingController duongDanController;
  final String selectedTopic;
  final File? tempImage;
  final bool isPressed;
  final ValueChanged<bool> onPressedStateChanged;

  const AddNewsSubmitButton({
    super.key,
    required this.tenBaiVietController,
    required this.noiDungController,
    required this.duongDanController,
    required this.selectedTopic,
    required this.tempImage,
    required this.isPressed,
    required this.onPressedStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressedStateChanged(true),
      onTapUp: (_) async {
        onPressedStateChanged(false);
        if (tenBaiVietController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vui lòng nhập tên bài báo"),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
        if (noiDungController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vui lòng nhập nội dung"),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
        try {
          final docRef = FirebaseFirestore.instance.collection('_news').doc();
          final generatedUid = docRef.id;
          final viewModel = Provider.of<NewsViewModel>(context, listen: false);
          final newBaiBao = NewsModels(
              uid: generatedUid,
              tenBaiViet: tenBaiVietController.text,
              noiDungBaiViet: noiDungController.text,
              fileDinhKem: '',
              duongDan: duongDanController.text,
              chuDe: selectedTopic,
              createAt: DateTime.now());
          if (tempImage != null) {
            await viewModel.addNewsWithImage(newBaiBao);
          } else {
            await viewModel.addNews(newBaiBao);
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Thêm bài báo thành công!"),
              backgroundColor: Color(0xFF3B82F6),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      onTapCancel: () => onPressedStateChanged(false),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isPressed ? 12 : 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPressed ? 0.1 : 0.3),
              blurRadius: 10,
              offset: Offset(0, isPressed ? 2 : 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Lưu",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 5,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
