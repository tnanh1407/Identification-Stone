import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<UserListViewModel>(context, listen: false);
      viewModel.fetchUser();
      _searchController.addListener(() {
        final searchText = _searchController.text.trim();
        viewModel.searchUsers(searchText); // Sửa: searchUsers đã được tối ưu
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _canCurrentUserModify(UserModels targetUser, AuthViewModel authViewModel) {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null || currentUser.uid == targetUser.uid) return false;
    switch (currentUser.role) {
      case 'Admin':
        return targetUser.role == 'Super-User' || targetUser.role == 'User';
      case 'Super-User':
        return targetUser.role == 'User';
      default:
        return false;
    }
  }

  void _showPermissionDeniedSnackBar(BuildContext context, UserModels targetUser, String actionKey, AuthViewModel authViewModel) {
    final theme = Theme.of(context);
    String errorMessage;
    if (targetUser.uid == authViewModel.currentUser?.uid) {
      errorMessage = 'user_management.cannot_self_action'.tr(namedArgs: {'action': actionKey});
    } else {
      errorMessage = 'user_management.permission_denied_action'.tr(namedArgs: {'action': actionKey});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: theme.colorScheme.error),
    );
  }

  // SỬA: Chuyển hàm này vào trong State
  Future<bool> _showDeleteConfirmationDialog(BuildContext context, UserModels user) async {
    final bool? deleted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('user_management.delete_confirmation_title'.tr()),
        content: Text('user_management.delete_confirmation_content'.tr(namedArgs: {'email': user.email})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('common.cancel'.tr())),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              final viewModel = Provider.of<UserListViewModel>(context, listen: false);
              try {
                await viewModel.deleteUser(user);
                navigator.pop(true);
                messenger.showSnackBar(SnackBar(content: Text('user_management.delete_success'.tr()), backgroundColor: Colors.green));
              } catch (e) {
                navigator.pop(false);
                messenger.showSnackBar(SnackBar(content: Text('user_management.delete_failed'.tr(namedArgs: {'error': e.toString()}))));
              }
            },
            child: Text('user_management.delete'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    return deleted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('user_management.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'user_management.reload_tooltip'.tr(),
            onPressed: () => Provider.of<UserListViewModel>(context, listen: false).fetchUser(),
          ),
        ],
      ),
      body: Consumer<UserListViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildSearchAndSortBar(context, theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'user_management.user_count'.tr(namedArgs: {'count': viewModel.users.length.toString()}),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.users.isEmpty
                        ? _buildEmptyState(theme)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: viewModel.users.length,
                            itemBuilder: (context, index) {
                              final user = viewModel.users[index];
                              return UserCard(
                                user: user,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailScreen(
                                      userId: user.uid,
                                      onEditPressed: () {
                                        if (_canCurrentUserModify(user, authViewModel)) {
                                          showEditUserSheet(context, user);
                                        } else {
                                          _showPermissionDeniedSnackBar(context, user, 'user_management.edit'.tr(), authViewModel);
                                        }
                                      },
                                      onDeletePressed: () {
                                        if (_canCurrentUserModify(user, authViewModel)) {
                                          return _showDeleteConfirmationDialog(context, user);
                                        } else {
                                          _showPermissionDeniedSnackBar(context, user, 'user_management.delete'.tr(), authViewModel);
                                          return Future.value(false);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                onMorePressed: () => _showUserActions(context, user, authViewModel),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddUserBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'user_management.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Card(
            margin: EdgeInsets.zero,
            child: PopupMenuButton<SortOption>(
              icon: Icon(Icons.sort, color: theme.colorScheme.onSurfaceVariant),
              tooltip: 'user_management.sort_by'.tr(),
              onSelected: (option) => Provider.of<UserListViewModel>(context, listen: false).sortUsers(option),
              itemBuilder: (context) => [
                PopupMenuItem(value: SortOption.createdAt, child: Text('user_management.sort_created_at'.tr())),
                PopupMenuItem(value: SortOption.role, child: Text('user_management.sort_role'.tr())),
                PopupMenuItem(value: SortOption.name, child: Text('user_management.sort_name'.tr())),
              ],
            ),
          ),
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
          Text('user_management.no_user_found_title'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('user_management.no_user_found_subtitle'.tr(), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _showUserActions(BuildContext context, UserModels user, AuthViewModel authViewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
              title: Text('user_management.edit'.tr()),
              onTap: () {
                Navigator.pop(context);
                if (_canCurrentUserModify(user, authViewModel)) {
                  showEditUserSheet(context, user);
                } else {
                  _showPermissionDeniedSnackBar(context, user, 'user_management.edit'.tr(), authViewModel);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('user_management.delete'.tr()),
              onTap: () {
                Navigator.pop(context);
                if (_canCurrentUserModify(user, authViewModel)) {
                  _showDeleteConfirmationDialog(context, user);
                } else {
                  _showPermissionDeniedSnackBar(context, user, 'user_management.delete'.tr(), authViewModel);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
//                           BOTTOM SHEETS (Đã tách ra)
// =======================================================================

bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

void showAddUserBottomSheet(BuildContext context) {
  _showUserFormBottomSheet(context, titleKey: 'user_management.add_user_title');
}

void showEditUserSheet(BuildContext context, UserModels user) {
  _showUserFormBottomSheet(context, titleKey: 'user_management.edit_user_title', user: user);
}

void _showUserFormBottomSheet(BuildContext context, {required String titleKey, UserModels? user}) {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController(text: user?.fullName ?? '');
  final emailController = TextEditingController(text: user?.email ?? '');
  final addressController = TextEditingController(text: user?.address ?? '');

  final List<String> availableRoles = ['User', 'Super-User', 'Admin'];
  String selectedRole = (user?.role != null && availableRoles.contains(user!.role)) ? user.role : 'User';

  File? tempImage;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ChangeNotifierProvider.value(
        value: Provider.of<UserListViewModel>(context, listen: false),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final viewModel = context.watch<UserListViewModel>();
            final theme = Theme.of(context);

            Future<void> handleSave() async {
              if (!formKey.currentState!.validate()) return;

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                if (user == null) {
                  final newUser = UserModels(
                    uid: FirebaseFirestore.instance.collection('users').doc().id,
                    email: emailController.text.trim(),
                    fullName: fullNameController.text.trim(),
                    address: addressController.text.trim(),
                    role: selectedRole,
                    createdAt: DateTime.now(),
                  );
                  await viewModel.addUser(newUser, tempImage);
                  if (navigator.canPop()) navigator.pop();
                  messenger.showSnackBar(SnackBar(content: Text('user_management.add_success'.tr()), backgroundColor: Colors.green));
                } else {
                  final updatedUser = user.copyWith(
                    fullName: fullNameController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    role: selectedRole,
                  );
                  await viewModel.updateUserWithOptionalImage(updatedUser, tempImage);
                  if (navigator.canPop()) navigator.pop();
                  messenger.showSnackBar(SnackBar(content: Text('user_management.update_success'.tr()), backgroundColor: Colors.green));
                }
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: theme.colorScheme.error));
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(titleKey.tr(), style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: fullNameController,
                        decoration: InputDecoration(labelText: 'user_management.fullname_label'.tr()),
                        validator: (value) => value == null || value.isEmpty ? 'user_management.error.fullname_required'.tr() : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'user_management.email_label'.tr()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || !_isValidEmail(value) ? 'auth.errors.email_invalid'.tr() : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: 'user_management.address_label'.tr()),
                        validator: (value) => value == null || value.isEmpty ? 'user_management.error.address_required'.tr() : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(labelText: 'user_management.role_label'.tr()),
                        items: availableRoles.map((String role) {
                          String roleDisplayName = 'user_management.roles.user'.tr();
                          if (role == 'Admin') {
                            roleDisplayName = 'user_management.roles.admin'.tr();
                          } else if (role == 'Super-User') {
                            roleDisplayName = 'user_management.roles.super_user'.tr();
                          }
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(roleDisplayName),
                          );
                        }).toList(),
                        onChanged: (value) => setModalState(() => selectedRole = value ?? 'User'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: Icon(tempImage == null ? Icons.image_outlined : Icons.check_circle_outline),
                        label: Text(tempImage == null ? 'user_management.avatar_select_button'.tr() : 'user_management.avatar_selected_button'.tr()),
                        onPressed: () async {
                          final granted = await requestPermissionDialog(context);
                          if (granted) {
                            final pickedImage = await viewModel.pickImageFromGallery();
                            if (pickedImage != null) setModalState(() => tempImage = pickedImage);
                          }
                        },
                      ),
                      if (tempImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(child: CircleAvatar(radius: 40, backgroundImage: FileImage(tempImage!))),
                        ),
                      if (tempImage == null && user?.avatar != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(user!.avatar!))),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: viewModel.isUpdating ? null : handleSave,
                        child: viewModel.isUpdating
                            ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            : Text(user == null ? 'common.add'.tr() : 'common.update'.tr()),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
