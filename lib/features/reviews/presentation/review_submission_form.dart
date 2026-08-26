import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';

class ReviewSubmissionForm extends StatefulWidget {
  const ReviewSubmissionForm({super.key, required this.repository});

  final ReviewsRepository? repository;

  @override
  State<ReviewSubmissionForm> createState() => _ReviewSubmissionFormState();
}

class _ReviewSubmissionFormState extends State<ReviewSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _review = TextEditingController();
  var _rating = 5;
  var _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _review.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.repository == null || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.repository!.submit(
        rating: _rating,
        review: _review.text.trim(),
        displayName: _name.text.trim(),
      );
      if (!mounted) return;
      _name.clear();
      _review.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you. Your review will appear after approval.'),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your review could not be submitted.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 680),
    padding: const EdgeInsets.all(AppSpacing.large),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: .7),
      ),
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share your experience',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xSmall),
          const Text('Every review is moderated before it appears publicly.'),
          const SizedBox(height: AppSpacing.medium),
          Text('Your rating', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xSmall),
          Wrap(
            spacing: 2,
            children: List.generate(
              5,
              (index) => IconButton(
                tooltip: '${index + 1} star${index == 0 ? '' : 's'}',
                onPressed: _submitting
                    ? null
                    : () => setState(() => _rating = index + 1),
                icon: Text(
                  index < _rating ? '★' : '☆',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _name,
            enabled: !_submitting && widget.repository != null,
            decoration: const InputDecoration(labelText: 'Name (optional)'),
            maxLength: 80,
          ),
          TextFormField(
            controller: _review,
            enabled: !_submitting && widget.repository != null,
            decoration: const InputDecoration(labelText: 'Your review'),
            minLines: 3,
            maxLines: 5,
            maxLength: 1000,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Write a short review'
                : null,
          ),
          const SizedBox(height: AppSpacing.small),
          FilledButton(
            onPressed: widget.repository == null || _submitting
                ? null
                : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit review'),
          ),
        ],
      ),
    ),
  );
}
