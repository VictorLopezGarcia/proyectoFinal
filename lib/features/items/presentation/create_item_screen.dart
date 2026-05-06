import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/item_providers.dart';
import '../domain/item.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/location_picker.dart';

class CreateItemScreen extends ConsumerStatefulWidget {
  const CreateItemScreen({super.key});

  @override
  ConsumerState<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends ConsumerState<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'otros';
  bool _isSubmitting = false;
  LocationSelection? _location;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final authState = ref.read(authStateProvider);
    final userId = authState.valueOrNull?.uid;
    if (userId == null) return;

    final item = Item(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      photos: [],
      pricePerDay: double.parse(_priceController.text.trim()),
      category: _selectedCategory,
      ownerId: userId,
      status: 'available',
      createdAt: DateTime.now(),
      locationName: _location?.name,
      lat: _location?.lat,
      lng: _location?.lng,
    );

    try {
      await ref.read(itemRepositoryProvider).createItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto publicado correctamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar objeto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Card(
                      color: colorScheme.primaryContainer.withAlpha(40),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.sell_outlined, size: 36, color: colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nuevo anuncio',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rellena los datos de tu objeto para publicarlo',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Two-column on desktop, single on mobile
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLeftColumn()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildRightColumn()),
                        ],
                      )
                    else ...[
                      _buildLeftColumn(),
                      const SizedBox(height: 16),
                      _buildRightColumn(),
                    ],

                    const SizedBox(height: 32),

                    // Submit
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.publish),
                      label: const Text('Publicar objeto'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Ej: Taladro Bosch Professional',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Describe el estado y lo que incluye',
            prefixIcon: Icon(Icons.description_outlined),
            alignLabelWithHint: true,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Precio/día (€)',
                  hintText: '8.50',
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  final price = double.tryParse(v.trim());
                  if (price == null || price <= 0) return 'No válido';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                isExpanded: true,
                items: AppConstants.itemCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c[0].toUpperCase() + c.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        LocationPicker(
          onLocationSelected: (s) => setState(() => _location = s),
        ),
      ],
    );
  }
}
