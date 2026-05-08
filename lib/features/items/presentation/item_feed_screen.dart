import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/item_providers.dart';
import '../domain/item.dart';
import '../../../core/layout/responsive_container.dart';

class ItemFeedScreen extends ConsumerStatefulWidget {
  const ItemFeedScreen({super.key});

  @override
  ConsumerState<ItemFeedScreen> createState() => _ItemFeedScreenState();
}

class _ItemFeedScreenState extends ConsumerState<ItemFeedScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _fabVisible = true;

  static const _categories = [
    'herramientas',
    'deporte',
    'electrónica',
    'hogar',
    'vehículos',
    'moda',
    'jardín',
    'música',
    'fotografía',
    'cocina',
    'viaje',
    'infantil',
    'otros',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollingDown = _scrollController.position.userScrollDirection.name == 'reverse';
    final scrollingUp = _scrollController.position.userScrollDirection.name == 'forward';
    if (scrollingDown && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (scrollingUp && !_fabVisible) {
      setState(() => _fabVisible = true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final itemsAsync = ref.watch(
      itemsStreamProvider(ItemFilter(
        category: _selectedCategory,
        searchQuery: _searchQuery,
      )),
    );

    return Scaffold(
      body: ResponsiveContainer(
        maxWidth: 1200,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar objetos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            // Category chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final selected = _selectedCategory == null;
                    return FilterChip(
                      label: const Text('Todos'),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                      avatar: selected ? null : const Icon(Icons.apps, size: 16),
                    );
                  }
                  final cat = _categories[index - 1];
                  final selected = _selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat[0].toUpperCase() + cat.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = selected ? null : cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Grid
            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          const Text('No hay objetos disponibles'),
                          if (_selectedCategory != null || _searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () => setState(() {
                                _selectedCategory = null;
                                _searchQuery = '';
                                _searchController.clear();
                              }),
                              child: const Text('Limpiar filtros'),
                            ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 600
                              ? 3
                              : 2;
                      final aspectRatio = crossAxisCount == 2 ? 0.68 : 0.75;
                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _ItemCard(item: items[index]);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        offset: (!isDesktop && !_fabVisible) ? const Offset(0, 2) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: (!isDesktop && !_fabVisible) ? 0.0 : 1.0,
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/items/create'),
            icon: const Icon(Icons.add),
            label: const Text('Publicar'),
          ),
        ),
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
    final hasPhoto = item.photos.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/items/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    Image.network(
                      item.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, trace) => _PhotoPlaceholder(colorScheme: colorScheme),
                    )
                  else
                    _PhotoPlaceholder(colorScheme: colorScheme),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category[0].toUpperCase() + item.category.substring(1),
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${item.pricePerDay.toStringAsFixed(2)} €/día',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.locationName != null) ...[
                        const Spacer(),
                        Icon(Icons.location_on, size: 12, color: colorScheme.onSurfaceVariant),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  const _PhotoPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.inventory_2_outlined, size: 48, color: colorScheme.onSurfaceVariant.withAlpha(120)),
      ),
    );
  }
}

