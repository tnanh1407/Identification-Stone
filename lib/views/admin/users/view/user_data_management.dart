import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/user_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/view_models/user_list_view_model.dart';
import 'package:rock_classifier/views/admin/users/view/user_detail_screen.dart';
import 'package:rock_classifier/views/admin/users/view/utils_management.dart';
import 'package:rock_classifier/views/admin/users/widget/user_card.dart';

enum SortOption { createdAt, role, name }

class UserDataManagement extends StatefulWidget {
  const UserDataManagement({super.key});

  @override
  State<UserDataManagement> createState() => _UserDataManagementState();
}

class _UserDataManagementState extends State<UserDataManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchText = _searchController.text.trim();
      final viewModel = Provider.of<UserListViewModel>(context, listen: false);
      if (_searchText.isNotEmpty) {
        viewModel.searchUsers(_searchText);
      } else {
        viewModel.fetchUser();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserListViewModel>(context, listen: false).fetchUser();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _canCurrentUserModify(UserModels targetUser, AuthViewModel authViewModel) {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null) {
      return false;
    }

    // Quy tắc 1 (Ưu tiên cao nhất): Không ai được thao tác với chính mình.
    if (currentUser.uid == targetUser.uid) {
      return false;
    }

    // Quy tắc 2: Phân quyền dựa trên vai trò
    switch (currentUser.role) {
      case 'Admin':
        // Admin có thể thao tác với Super-User và User.
        return targetUser.role == 'Super-User' || targetUser.role == 'User';
      case 'Super-User':
        // Super-User chỉ có thể thao tác với User.
        return targetUser.role == 'User';
      default:
        // Các vai trò khác (như User) không có quyền thao tác.
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserRole = authViewModel.currentUserRole;
    if (currentUserRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        backgroundColor: Color(0xFFF7F7F7),
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
          "Quản lí người dùng",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Provider.of<UserListViewModel>(context, listen: false).fetchUser();
            },
          ),
        ],
      ),
      body: Consumer<UserListViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                              ],
                            ),
                            child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                    hintText: 'Tìm kiếm người dùng',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14))))),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade100]),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: PopupMenuButton<SortOption>(
                        icon: const Icon(Icons.sort, color: Colors.grey),
                        onSelected: (SortOption selected) {
                          Provider.of<UserListViewModel>(context, listen: false).sortUsers(selected);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: SortOption.createdAt, child: Text("Theo thời gian tạo")),
                          PopupMenuItem(value: SortOption.role, child: Text("Theo vai trò")),
                          PopupMenuItem(value: SortOption.name, child: Text("Theo email")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Số lượng người dùng: ${viewModel.users.length}", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 80, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  "Không tìm thấy người dùng",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Hãy thử tìm kiếm với từ khóa khác",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: viewModel.users.length,
                            itemBuilder: (context, index) {
                              final user = viewModel.users[index];
                              return UserCard(
                                user: user,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailScreen(user: user))),
                                onMorePressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                              leading: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                                              title: Text("Chỉnh sửa"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                // 2. Kiểm tra quyền bằng hàm helper
                                                final bool canModify = _canCurrentUserModify(user, authViewModel);

                                                // 3. Thực hiện hành động hoặc báo lỗi
                                                if (canModify) {
                                                  showEditUserSheet(context, user);
                                                } else {
                                                  String errorMessage = "Bạn không có quyền chỉnh sửa người dùng này.";
                                                  if (user.uid == authViewModel.currentUser?.uid) {
                                                    errorMessage = "Bạn không thể tự chỉnh sửa chính mình.";
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(errorMessage),
                                                      backgroundColor: Colors.redAccent,
                                                    ),
                                                  );
                                                }
                                              }),
                                          ListTile(
                                            leading: const Icon(Icons.delete, color: Colors.redAccent),
                                            title: Text("Xóa"),
                                            onTap: () {
                                              // 1. Luôn đóng bottom sheet trước
                                              Navigator.pop(context);
                                              // 2. Kiểm tra quyền bằng hàm helper
                                              final bool canModify = _canCurrentUserModify(user, authViewModel);
                                              // 3. Thực hiện hành động hoặc báo lỗi
                                              if (canModify) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text("Xác nhận xóa"),
                                                    content: Text("Bạn có chắc muốn xóa ${user.email}?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text("Hủy"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          final navigator = Navigator.of(context);
                                                          final messenger = ScaffoldMessenger.of(context);
                                                          try {
                                                            await Provider.of<UserListViewModel>(context, listen: false).deleteUser(user);
                                                            navigator.pop();
                                                            messenger.showSnackBar(SnackBar(content: Text("Đã xóa người dùng")));
                                                          } catch (e) {
                                                            navigator.pop();
                                                            messenger.showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                                                          }
                                                        },
                                                        child: Text("Xóa"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                String errorMessage = "Bạn không có quyền xóa người dùng này.";
                                                if (user.uid == authViewModel.currentUser?.uid) {
                                                  errorMessage = "Bạn không thể tự xóa chính mình.";
                                                }
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(errorMessage),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () => showAddUserBottomSheet(context),
          backgroundColor: const Color(0xFF3B82F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}

void showAddUserBottomSheet(BuildContext context) {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  String? emailError;
  String selectedRole = 'User';
  File? tempImage;
  bool isPressed = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Thêm người dùng",
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
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: "Họ và tên",
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
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
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
                      errorText: emailError,
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
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setModalState(() {
                        emailError = isValidEmail(value) ? null : 'Email không hợp lệ';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Địa chỉ",
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
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
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: "Vai trò",
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
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
                    items: ['Admin', 'User', 'Super-User'].map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedRole = newValue ?? 'User';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(
                      tempImage == null ? Icons.image : Icons.check_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      tempImage == null ? "Chọn ảnh đại diện" : "Đã chọn ảnh",
                      style: TextStyle(color: Colors.white),
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
                        final viewModel = Provider.of<UserListViewModel>(context, listen: false);
                        final pickedImage = await viewModel.pickImageFromGallery();
                        if (pickedImage != null) {
                          setModalState(() {
                            tempImage = pickedImage;
                          });
                        }
                      }
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
                  GestureDetector(
                    onTapDown: (_) => setModalState(() => isPressed = true),
                    onTapUp: (_) async {
                      setModalState(() => isPressed = false);
                      if (emailController.text.isEmpty || !isValidEmail(emailController.text)) {
                        setModalState(() {
                          emailError = 'Vui lòng nhập email hợp lệ';
                        });
                        return;
                      }
                      if (fullNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Vui lòng nhập họ và tên"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Vui lòng nhập địa chỉ"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      try {
                        final docRef = FirebaseFirestore.instance.collection('users').doc();
                        final generatedUid = docRef.id;
                        final viewModel = Provider.of<UserListViewModel>(context, listen: false);
                        final user = UserModels(
                          uid: generatedUid, // UID sẽ được Firebase tự tạo
                          email: emailController.text,
                          fullName: fullNameController.text,
                          address: addressController.text,
                          role: selectedRole,
                          createdAt: DateTime.now(),
                          avatar: '', // Avatar sẽ được cập nhật sau khi upload
                        );
                        if (tempImage != null) {
                          await viewModel.addUserWithAvatar(user, tempImage!);
                        } else {
                          await viewModel.addUserWithoutAvatar(user);
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Thêm người dùng thành công!"),
                            backgroundColor: const Color(0xFF3B82F6),
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
                    onTapCancel: () => setModalState(() => isPressed = false),
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
                      child: Center(
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

void showEditUserSheet(BuildContext context, UserModels user) {
  final TextEditingController emailController = TextEditingController(text: user.email);
  final TextEditingController fullNameController = TextEditingController(text: user.fullName ?? '');
  final TextEditingController addressController = TextEditingController(text: user.address ?? '');
  String? avatarUrl = user.avatar;
  String? emailError;
  String? selectedRole = user.role;
  bool isPressed = false;
  File? tempImage;

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
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chỉnh sửa người dùng",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 28), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: "Họ và tên",
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF3B82F6)),
                        labelStyle: TextStyle(color: Colors.grey),
                        errorText: emailError,
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2))),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setModalState(() {
                        emailError = isValidEmail(value) ? null : 'Email không hợp lệ';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Địa chỉ",
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
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
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: "Vai trò",
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF3B82F6)),
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
                    ),
                    items: ['Admin', 'User', 'Super-User'].map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedRole = newValue ?? user.role;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(
                      tempImage == null ? Icons.image : Icons.check_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      tempImage == null ? "Chọn ảnh đại diện" : "Đã chọn ảnh",
                      style: TextStyle(color: Colors.white),
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
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setModalState(() {
                            tempImage = File(pickedFile.path);
                          });
                        }
                      }
                    },
                  ),
                  if (tempImage != null || avatarUrl != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: tempImage != null
                            ? Image.file(
                                tempImage!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                avatarUrl!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    //onTapDown hạ tay xuống
                    onTapDown: (_) => setModalState(() => isPressed = true),
                    // onTapUp nhấc tay lên
                    onTapUp: (_) async {
                      setModalState(() => isPressed = false);
                      if (emailController.text.isEmpty || !isValidEmail(emailController.text)) {
                        setModalState(() {
                          emailError = 'Vui lòng nhập email hợp lệ';
                        });
                        return;
                      }
                      if (fullNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Vui lòng nhập họ và tên"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Vui lòng nhập địa chỉ"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      try {
                        final updatedUser = UserModels(
                          uid: user.uid,
                          fullName: fullNameController.text,
                          address: addressController.text,
                          email: emailController.text,
                          avatar: avatarUrl,
                          role: selectedRole as String,
                          createdAt: user.createdAt,
                        );
                        final viewModel = Provider.of<UserListViewModel>(context, listen: false);
                        if (tempImage != null) {
                          await viewModel.updateUserWithImage(updatedUser, tempImage!);
                        } else {
                          await viewModel.updateUser(updatedUser);
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Cập nhật người dùng thành công!"),
                            backgroundColor: const Color(0xFF3B82F6),
                          ),
                        );
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Lỗi: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    onTapCancel: () => setModalState(() => isPressed = false),
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
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(isPressed ? 0.1 : 0.3),
                            blurRadius: 10,
                            offset: Offset(0, isPressed ? 2 : 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Cập nhật",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
