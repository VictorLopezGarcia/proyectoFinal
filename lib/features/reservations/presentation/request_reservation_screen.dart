import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_my_stuff/features/items/presentation/item_providers.dart';
import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';
import 'package:rent_my_stuff/features/reservations/presentation/reservation_providers.dart';

class RequestReservationScreen extends ConsumerStatefulWidget {
  final String itemId;

  const RequestReservationScreen({super.key, required this.itemId});

  @override
  ConsumerState<RequestReservationScreen> createState() => _RequestReservationScreenState();
}

class _RequestReservationScreenState extends ConsumerState<RequestReservationScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isSubmitting = false;
  String? _errorMessage;
  double? _totalPrice;

  Future<void> _handleSubmit() async {
    if (_selectedDateRange == null) {
      setState(() => _errorMessage = 'Selecciona las fechas de alquiler');
      return;
    }

    final item = await ref.read(itemDetailProvider(widget.itemId).future);
    if (item == null) {
      setState(() => _errorMessage = 'Objeto no encontrado');
      return;
    }

    final days = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
    final totalPrice = days * item.pricePerDay;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _totalPrice = totalPrice;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Debes iniciar sesión para reservar';
          _isSubmitting = false;
        });
        return;
      }

      final reservation = Reservation(
        id: '',
        itemId: widget.itemId,
        itemTitle: item.title,
        ownerId: item.ownerId,
        renterId: user.uid,
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
        totalPrice: totalPrice,
        status: ReservationStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref.read(reservationRepositoryProvider).createReservation(reservation);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al crear la reserva: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _selectedDateRange != null
        ? _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fechas de alquiler',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDateRange = picked;
                            _errorMessage = null;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDateRange != null
                            ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                            : 'Seleccionar fechas',
                      ),
                    ),
                    if (_selectedDateRange != null) ...[
                      const SizedBox(height: 8),
                      Text('Duración: $days día${days == 1 ? '' : 's'}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_totalPrice != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Precio total',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_totalPrice!.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),
            const Spacer(),
            FilledButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar Reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
