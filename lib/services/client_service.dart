import '../models/client_model.dart';
import 'storage_service.dart';

/// CRUD service for client data stored in clients.json
class ClientService {
  final StorageService _storage = StorageService.instance;

  Future<List<ClientModel>> getAll() async {
    final list = await _storage.readList(StorageFiles.clients);
    return list.map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<ClientModel?> getById(String id) async {
    final clients = await getAll();
    try {
      return clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(ClientModel client) async {
    final clients = await getAll();
    clients.add(client);
    await _save(clients);
  }

  Future<void> update(ClientModel updated) async {
    final clients = await getAll();
    final index = clients.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      clients[index] = updated;
      await _save(clients);
    }
  }

  Future<void> delete(String id) async {
    final clients = await getAll();
    clients.removeWhere((c) => c.id == id);
    await _save(clients);
  }

  Future<List<ClientModel>> search(String query) async {
    final clients = await getAll();
    final q = query.toLowerCase();
    return clients
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            c.type.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _save(List<ClientModel> clients) async {
    await _storage.writeList(
      StorageFiles.clients,
      clients.map((c) => c.toJson()).toList(),
    );
  }
}
