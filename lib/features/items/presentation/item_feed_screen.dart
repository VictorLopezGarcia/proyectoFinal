import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../presentation/item_providers.dart';
import '../domain/item.dart';
import '../../auth/presentation/auth_providers.dart';

class ItemFeedScreen extends ConsumerStatefulWidget {
  const ItemFeedScreen({super.key});

  @override
  ConsumerState<ItemFeedScreen> createState() => _ItemFeedScreenState();
}

class _ItemFeedScreenState extends ConsumerState<ItemFeedScreen> {
  String? _selectedCategory;
  bool _filterByLocation = false;
  Position? _currentPosition;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      // Location permissions might be denied
    }
  }

  static const _categories = [
    'herramientas',
    'deporte',
    'electrónica',
    'hogar',
    'vehículos',
    'otros',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(
      itemsStreamProvider(ItemFilter(category: _selectedCategory)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('RentMyStuff'),
        actions: [
          IconButton(
            icon: Icon(
              _filterByLocation ? Icons.location_on : Icons.location_on_outlined,
              color: _filterByLocation ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() => _filterByLocation = !_filterByLocation);
            },
            tooltip: 'Filtrar por ubicación',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/items/create'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => context.push('/reservations'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push('/chats'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ..._categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat[0].toUpperCase() + cat.substring(1)),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filteredItems = _filterByLocation && _currentPosition != null
                    ? items.where((item) {
                        final distance = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          item.approximateLat,
                          item.approximateLng,
                        );
                        return distance <= 10000;
                      }).toList()
                    : items;

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay objetos disponibles'),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return _ItemCard(item: filteredItems[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/items/create'),
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/items/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                child: item.photos.isNotEmpty
                    ? Image.network(item.photos.first, fit: BoxFit.cover)
                    : Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category[0].toUpperCase() + item.category.substring(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.pricePerDay.toStringAsFixed(2)} €/día',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
