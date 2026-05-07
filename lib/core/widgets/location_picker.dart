import 'dart:async';
import 'package:flutter/material.dart';
import '../services/compute_service.dart';
import 'map_view.dart';

class LocationPicker extends StatefulWidget {
  final String? initialLocationName;
  final double? initialLat;
  final double? initialLng;
  final ValueChanged<LocationSelection?> onLocationSelected;

  const LocationPicker({
    super.key,
    this.initialLocationName,
    this.initialLat,
    this.initialLng,
    required this.onLocationSelected,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _searchController = TextEditingController();
  List<GeocodingResult> _results = [];
  bool _isSearching = false;
  GeocodingResult? _selected;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocationName != null) {
      _selected = GeocodingResult(
        lat: widget.initialLat ?? 0,
        lng: widget.initialLng ?? 0,
        displayName: widget.initialLocationName!,
      );
      _searchController.text = widget.initialLocationName!;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final results = await OpenFreeMapService.searchAddress(query.trim());
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectResult(GeocodingResult result) {
    setState(() {
      _selected = result;
      _results = [];
      _searchController.text = result.displayName;
    });
    widget.onLocationSelected(LocationSelection(
      name: result.displayName,
      lat: result.lat,
      lng: result.lng,
    ));
  }

  void _clearLocation() {
    setState(() {
      _selected = null;
      _results = [];
      _searchController.clear();
    });
    widget.onLocationSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Ubicación (opcional)',
            hintText: 'Escribe una dirección o ciudad...',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearLocation,
                      )
                    : null,
          ),
          onChanged: (value) {
            if (_selected != null) {
              _selected = null;
              widget.onLocationSelected(null);
            }
            _onSearchChanged(value);
          },
        ),
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _results.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                final result = _results[index];
                return ListTile(
                  leading: Icon(Icons.place, size: 20, color: colorScheme.primary),
                  title: Text(
                    result.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  dense: true,
                  onTap: () => _selectResult(result),
                );
              },
            ),
          ),
        if (_selected != null && _results.isEmpty) ...[
          const SizedBox(height: 10),
          Stack(
            children: [
              MapView(
                lat: _selected!.lat,
                lng: _selected!.lng,
                height: 180,
                interactive: false,
              ),
              Positioned(
                top: 6, right: 6,
                child: Material(
                  color: colorScheme.surface.withAlpha(220),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _clearLocation,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close, size: 16, color: colorScheme.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class LocationSelection {
  final String name;
  final double lat;
  final double lng;

  LocationSelection({required this.name, required this.lat, required this.lng});
}
