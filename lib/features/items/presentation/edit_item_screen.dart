import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/item_providers.dart';
import '../domain/item.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/location_picker.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final String itemId;
  const EditItemScreen({super.key, required this.itemId});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'otros';
  bool _isSubmitting = false;
  bool _loaded = false;
  LocationSelection? _location;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _loadItem(Item item) {
    if (_loaded) return;
    _loaded = true;
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _priceController.text = item.pricePerDay.toString();
    _selectedCategory = item.category;
    if (item.locationName != null && item.lat != null && item.lng != null) {
      _location = LocationSelection(
        name: item.locationName!,
        lat: item.lat!,
        lng: item.lng!,
      );
    }
  }

  Future<void> _handleSubmit(Item original) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final updated = original.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      pricePerDay: double.parse(_priceController.text.trim()),
      category: _selectedCategory,
      locationName: _location?.name,
      lat: _location?.lat,
      lng: _location?.lng,
    );

    try {
      await ref.read(itemRepositoryProvider).updateItem(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objeto actualizado')),
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
    final itemAsync = ref.watch(itemDetailProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Objeto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Objeto no encontrado'));
          }
          _loadItem(item);
          return _buildForm(item);
        },
      ),
    );
  }

  Widget _buildForm(Item item) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Título',
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
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Precio por día (€)',
                      prefixIcon: Icon(Icons.euro),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                      final price = double.tryParse(v.trim());
                      if (price == null || price <= 0) return 'Precio no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
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
                  const SizedBox(height: 16),
                  LocationPicker(
                    initialLocationName: _location?.name,
                    initialLat: _location?.lat,
                    initialLng: _location?.lng,
                    onLocationSelected: (s) => setState(() => _location = s),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : () => _handleSubmit(item),
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar cambios'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
