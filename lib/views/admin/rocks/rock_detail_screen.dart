import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rock_classifier/data/models/rock_models.dart';
import 'package:rock_classifier/view_models/auth_view_model.dart';
import 'package:rock_classifier/view_models/rock_view_model.dart';
import 'package:rock_classifier/views/admin/rocks/add_edit_rock_sheet.dart';
import 'package:rock_classifier/views/admin/rocks/rock_management_dialogs.dart';

class RockDetailScreen extends StatelessWidget {
  final String rockId;

  const RockDetailScreen({super.key, required this.rockId});

// trong file RockDetailScreen.dart

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();

    return Consumer<RockViewModel>(
      builder: (context, viewModel, child) {
        final rock = viewModel.rocks.firstWhere(
          (r) => r.uid == rockId,
          orElse: () => RockModels.empty,
        );

        if (rock.isEmpty) {
          Future.microtask(() => Navigator.of(context).pop());
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, rock),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, rock),
                      const SizedBox(height: 24),
                      _buildPropertyBox(context, rock),
                      const SizedBox(height: 24),
                      _buildSection(context, 'rock_detail.description_title', rock.mieuTa),
                      _buildSection(context, 'rock_detail.basic_features_title', rock.dacDiem),
                      _buildFaqSection(context, rock),
                      _buildSection(context, 'rock_detail.structure', rock.kienTruc),
                      _buildSection(context, 'rock_detail.texture', rock.cauTao),
                      _buildSection(context, 'rock_detail.mineral_composition', rock.thanhPhanKhoangSan),
                      _buildSection(context, 'rock_detail.uses', rock.congDung),
                      _buildSection(context, 'rock_detail.distribution', rock.noiPhanBo),
                      _buildSection(context, 'rock_detail.related_minerals', rock.motSoKhoangSanLienQuan),
                      const SizedBox(height: 80), // Khoảng trống cho FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: authViewModel.isAdmin() // Chỉ Admin mới thấy các nút này
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: () => showAddEditRockSheet(context, rock: rock),
                      label: Text('rock_detail.edit_button'.tr()),
                      icon: const Icon(Icons.edit_outlined),
                      heroTag: 'edit_fab',
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton.extended(
                      onPressed: () {
                        showDeleteRockConfirmationDialog(context, rock: rock);
                      },
                      label: Text('rock_detail.delete_button'.tr()),
                      icon: const Icon(Icons.delete_outline),
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      heroTag: 'delete_fab',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, RockModels rock) {
    final theme = Theme.of(context);
    final hasImages = rock.hinhAnh.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      title: Text(rock.tenDa ?? 'rock_detail.unnamed_rock'.tr()),
      flexibleSpace: FlexibleSpaceBar(
        background: hasImages
            ? CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: rock.hinhAnh.map((imageUrl) {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(color: theme.colorScheme.surfaceVariant),
                  );
                }).toList(),
              )
            : Container(
                color: theme.colorScheme.surfaceVariant,
                child: Icon(Icons.terrain_outlined, size: 80, color: theme.colorScheme.onSurfaceVariant),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RockModels rock) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rock.tenDa ?? 'rock_detail.unnamed_rock'.tr(),
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${'rock_detail.type_label'.tr()}: ${rock.loaiDa ?? 'rock_management.unknown'.tr()}',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // trong file rock_detail_screen.dart

  Widget _buildPropertyBox(BuildContext context, RockModels rock) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withOpacity(0.5), // Làm màu nền nhạt hơn một chút
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('rock_detail.property_box_title'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            // SỬA: Hiển thị các thuộc tính theo từng hàng
            _PropertyItem(icon: Icons.science_outlined, label: 'rock_detail.chemical_composition'.tr(), value: rock.thanhPhanHoaHoc),
            const SizedBox(height: 16),
            _PropertyItem(icon: Icons.fitness_center_outlined, label: 'rock_detail.hardness'.tr(), value: rock.doCung),
            const SizedBox(height: 16),
            _PropertyItem(icon: Icons.color_lens_outlined, label: 'rock_detail.color'.tr(), value: rock.mauSac),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String titleKey, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleKey.tr(), style: theme.textTheme.titleLarge),
          const Divider(height: 16),
          Text(content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context, RockModels rock) {
    if (rock.cauHoi.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('rock_detail.faq_title'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(rock.cauHoi.length, (index) {
                return ExpansionTile(
                  title: Text(rock.cauHoi[index], style: theme.textTheme.titleSmall),
                  children: [
                    Container(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: Text(rock.traLoi[index], style: theme.textTheme.bodyMedium),
                    )
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// trong file rock_detail_screen.dart

class _PropertyItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _PropertyItem({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // SỬA: Bố cục theo hàng ngang
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên nếu value có nhiều dòng
      children: [
        Icon(icon, color: theme.colorScheme.onSecondaryContainer, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                value ?? 'N/A',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
