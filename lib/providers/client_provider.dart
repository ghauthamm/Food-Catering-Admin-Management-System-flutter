import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';

/// Manages client list state and CRUD operations.
class ClientProvider extends ChangeNotifier {
  final ClientService _service = ClientService();
  final _uuid = const Uuid();

  List<ClientModel> _clients = [];
  List<ClientModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<ClientModel> get clients => _filtered;
  List<ClientModel> get allClients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();
    try {
      _clients = await _service.getAll();
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_clients);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _clients
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.contains(q) ||
              c.type.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<bool> addClient({
    required String name,
    required String phone,
    required String type,
    String? email,
    String? address,
    String? gstNumber,
  }) async {
    try {
      final client = ClientModel(
        id: 'C${_uuid.v4().substring(0, 8).toUpperCase()}',
        name: name,
        phone: phone,
        type: type,
        email: email,
        address: address,
        gstNumber: gstNumber,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _service.add(client);
      await loadClients();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateClient(ClientModel updated) async {
    try {
      await _service.update(updated);
      await loadClients();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    try {
      await _service.delete(id);
      await loadClients();
      return true;
    } catch (_) {
      return false;
    }
  }
}
