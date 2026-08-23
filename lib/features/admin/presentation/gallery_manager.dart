import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/gallery/data/gallery_repository.dart';
import 'package:hossy_barbers/features/gallery/domain/gallery_item.dart';
import 'package:hossy_barbers/features/gallery/services/cloudinary_upload_service.dart';
import 'package:hossy_barbers/features/admin/services/admin_image_picker.dart';

class GalleryManager extends StatelessWidget {
  const GalleryManager({
    super.key,
    required this.repository,
    required this.uploadService,
  });

  final GalleryRepository repository;
  final CloudinaryUploadService uploadService;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<GalleryItem>>(
    stream: repository.watchAll(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(child: Text('Gallery items could not be loaded.'));
      }
      final items = snapshot.data ?? const [];
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VISUAL LIBRARY',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Gallery',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showEditor(context),
                      icon: const Icon(Icons.upload_outlined),
                      label: const Text('Add gallery image'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                const Text('Images are uploaded securely to Cloudinary.'),
                const SizedBox(height: AppSpacing.large),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
                    child: Text('No gallery items have been added yet.'),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.medium,
                            vertical: AppSpacing.xSmall,
                          ),
                          leading: _GalleryThumbnail(imageUrl: item.imageUrl),
                          title: Text(
                            item.caption.isEmpty
                                ? 'Untitled image'
                                : item.caption,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            'Order ${item.sortOrder} · ${item.isPublished ? 'Published' : 'Hidden'}',
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: 'Edit gallery item',
                                onPressed: () => _showEditor(context, item),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Delete gallery item',
                                onPressed: () => _delete(context, item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Future<void> _showEditor(
    BuildContext context, [
    GalleryItem? existing,
  ]) async {
    final result = await showDialog<_GallerySaveResult>(
      context: context,
      builder: (_) =>
          _GalleryDialog(existing: existing, uploadService: uploadService),
    );
    if (result == null) {
      return;
    }
    try {
      await repository.save(result.item);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.uploaded
                  ? 'Image uploaded and gallery item saved.'
                  : 'Gallery item saved.',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery item could not be saved.')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, GalleryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete gallery item?'),
        content: const Text(
          'This removes the gallery record, not the Cloudinary image.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await repository.delete(item.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery item could not be deleted.')),
        );
      }
    }
  }
}

class _GalleryDialog extends StatefulWidget {
  const _GalleryDialog({required this.existing, required this.uploadService});

  final GalleryItem? existing;
  final CloudinaryUploadService uploadService;

  @override
  State<_GalleryDialog> createState() => _GalleryDialogState();
}

class _GalleryDialogState extends State<_GalleryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _caption = TextEditingController(
    text: widget.existing?.caption ?? '',
  );
  late final _sortOrder = TextEditingController(
    text: widget.existing?.sortOrder.toString() ?? '0',
  );
  late var _published = widget.existing?.isPublished ?? true;
  AdminImageFile? _selectedFile;
  Uint8List? _selectedBytes;
  var _isUploading = false;
  String? _uploadError;

  @override
  void dispose() {
    _caption.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await const AdminImagePicker().pick();
      if (file == null || !mounted) return;
      setState(() {
        _selectedFile = file;
        _selectedBytes = file.bytes;
        _uploadError = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _uploadError =
              'The image could not be selected. Please try again.',
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final selectedFile = _selectedFile;
    if (selectedFile == null && widget.existing == null) {
      setState(() => _uploadError = 'Select an image to upload.');
      return;
    }
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });
    try {
      final imageUrl = selectedFile == null
          ? widget.existing!.imageUrl
          : await widget.uploadService.uploadImage(
              bytes: _selectedBytes!,
              filename: selectedFile.name,
            );
      if (!mounted) {
        return;
      }
      Navigator.pop(
        context,
        _GallerySaveResult(
          item: GalleryItem(
            id: widget.existing?.id ?? '',
            imageUrl: imageUrl,
            caption: _caption.text.trim(),
            isPublished: _published,
            sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
          ),
          uploaded: selectedFile != null,
        ),
      );
    } on CloudinaryUploadException catch (error) {
      if (mounted) {
        setState(() => _uploadError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.existing == null ? 'Upload gallery image' : 'Edit gallery image',
    ),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagePreview(
                selectedBytes: _selectedBytes,
                existingImageUrl: widget.existing?.imageUrl,
              ),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _selectedFile == null
                      ? 'Choose image'
                      : 'Choose a different image',
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                _selectedFile == null
                    ? 'PNG, JPG, or WebP. The image uploads when you save this gallery item.'
                    : '${_selectedFile!.name} is ready to upload.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_uploadError != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  _uploadError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              _field(_caption, 'Caption'),
              _field(_sortOrder, 'Display order', numeric: true),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Published'),
                value: _published,
                onChanged: _isUploading
                    ? null
                    : (value) => setState(() => _published = value),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isUploading ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _isUploading ? null : _save,
        icon: _isUploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload_outlined),
        label: Text(_isUploading ? 'Uploading…' : 'Save gallery image'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _GallerySaveResult {
  const _GallerySaveResult({required this.item, required this.uploaded});

  final GalleryItem item;
  final bool uploaded;
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.selectedBytes,
    required this.existingImageUrl,
  });

  final Uint8List? selectedBytes;
  final String? existingImageUrl;

  @override
  Widget build(BuildContext context) {
    if (selectedBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          selectedBytes!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    if (existingImageUrl?.isNotEmpty == true) {
      return _NetworkImagePreview(imageUrl: existingImageUrl!);
    }
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('No image selected'),
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    width: 48,
    child: imageUrl.isEmpty
        ? const Icon(Icons.image_outlined)
        : _NetworkImagePreview(imageUrl: imageUrl),
  );
}

class _NetworkImagePreview extends StatelessWidget {
  const _NetworkImagePreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFE9E5DD),
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    ),
  );
}
