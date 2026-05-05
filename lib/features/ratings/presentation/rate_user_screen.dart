import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/rating.dart';
import '../presentation/rating_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../core/layout/responsive_container.dart';

class RateUserScreen extends ConsumerStatefulWidget {
  final String reservationId;
  final String toUserId;
  final String fromUserId;

  const RateUserScreen({
    super.key,
    required this.reservationId,
    required this.toUserId,
    required this.fromUserId,
  });

  @override
  ConsumerState<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends ConsumerState<RateUserScreen> {
  double _score = 3;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final rating = Rating(
        id: '',
        fromUserId: widget.fromUserId,
        toUserId: widget.toUserId,
        reservationId: widget.reservationId,
        score: _score,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );
      await ref.read(ratingRepositoryProvider).addRating(rating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valoración enviada')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(currentUserProvider(widget.toUserId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valorar usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 500,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              userData.when(
                data: (user) => Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.primaryContainer,
                      child: user != null && user.photoUrl.isEmpty
                          ? Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Usuario',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              Text(
                'Puntuación',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    icon: Icon(
                      value <= _score ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () => setState(() => _score = value.toDouble()),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar valoración'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
