import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/services/data/services_repository.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

class ServicesManager extends StatelessWidget {
  const ServicesManager({super.key, required this.repository});
  final ServicesRepository repository;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Service>>(
    stream: repository.watchAll(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(child: Text('Services could not be loaded.'));
      }
      final services = snapshot.data ?? const [];
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
                            'SERVICE MENU',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Services',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showEditor(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add service'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                const Text(
                  'Only active services are available to the public website.',
                ),
                const SizedBox(height: AppSpacing.large),
                if (services.isEmpty)
                  const _EmptyState(message: 'No services have been added yet.')
                else
                  ...services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.medium,
                            vertical: AppSpacing.small,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.content_cut_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      [
                                            service.description,
                                            if (service.price?.isNotEmpty ??
                                                false)
                                              service.price!,
                                            if (service.duration?.isNotEmpty ??
                                                false)
                                              service.duration!,
                                          ]
                                          .where((text) => text.isNotEmpty)
                                          .join(' · '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.small),
                              _ServiceStatus(active: service.isActive),
                              IconButton(
                                tooltip: 'Edit service',
                                onPressed: () => _showEditor(context, service),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Delete service',
                                onPressed: () => _delete(context, service),
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

  Future<void> _showEditor(BuildContext context, [Service? existing]) async {
    final result = await showDialog<Service>(
      context: context,
      builder: (_) => _ServiceDialog(existing: existing),
    );
    if (result == null) {
      return;
    }
    try {
      await repository.save(result);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service could not be saved.')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Remove ${service.name}?'),
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
      await repository.delete(service.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service could not be deleted.')),
        );
      }
    }
  }
}

class _ServiceStatus extends StatelessWidget {
  const _ServiceStatus({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => Chip(
    visualDensity: VisualDensity.compact,
    label: Text(active ? 'Live' : 'Hidden'),
    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
    side: BorderSide(color: Theme.of(context).colorScheme.outline),
  );
}

class _ServiceDialog extends StatefulWidget {
  const _ServiceDialog({this.existing});
  final Service? existing;
  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final _price = TextEditingController(text: widget.existing?.price ?? '');
  late final _duration = TextEditingController(
    text: widget.existing?.duration ?? '',
  );
  late final _sortOrder = TextEditingController(
    text: widget.existing?.sortOrder.toString() ?? '0',
  );
  late var _active = widget.existing?.isActive ?? true;
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _duration.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'Add service' : 'Edit service'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_name, 'Name', required: true),
              _field(_description, 'Description', lines: 3),
              _field(_price, 'Price'),
              _field(_duration, 'Duration'),
              _field(_sortOrder, 'Display order', numeric: true),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Published'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Save')),
    ],
  );
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Service(
        id: widget.existing?.id ?? '',
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: _price.text.trim().isEmpty ? null : _price.text.trim(),
        duration: _duration.text.trim().isEmpty ? null : _duration.text.trim(),
        isActive: _active,
        sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int lines = 1,
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      minLines: lines,
      maxLines: lines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Enter a service name'
                : null
          : null,
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
    child: Text(message),
  );
}
