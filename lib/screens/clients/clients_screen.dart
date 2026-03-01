import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client_model.dart';
import '../../providers/client_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';
import 'client_form_screen.dart';

/// Lists all clients with search, filter, edit and delete capabilities.
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => provider.loadClients(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Client'),
      ),
      body: Column(
        children: [
          // ─── Search Bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.search('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ─── Count ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${provider.clients.length} clients',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ─── Client List ──────────────────────────────────────────────────
          Expanded(
            child: LoadingOverlay(
              isLoading: provider.isLoading,
              child: provider.clients.isEmpty && !provider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline,
                              size: 64, color: AppTheme.clientColor),
                          const SizedBox(height: 16),
                          const Text('No clients found',
                              style: TextStyle(
                                  fontSize: 16, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _openForm(context),
                            child: const Text('Add First Client'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: provider.clients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _ClientCard(client: provider.clients[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, [ClientModel? client]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientFormScreen(existingClient: client),
      ),
    );
  }
}

// ─── Client Card ──────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(client.type);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: typeColor.withOpacity(0.12),
              child: Text(
                client.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        client.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      client.type,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),
                  if (client.gstNumber != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'GST: ${client.gstNumber}',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
              onSelected: (val) => _handleAction(context, val),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Hostel':
        return const Color(0xFF3498DB);
      case 'Hospital':
        return const Color(0xFFE74C3C);
      case 'Function':
        return const Color(0xFF9B59B6);
      case 'Company':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF7F8C9A);
    }
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientFormScreen(existingClient: client),
        ),
      );
    } else if (action == 'delete') {
      final confirm =
          await AppHelpers.confirmDelete(context, client.name);
      if (confirm && context.mounted) {
        final success =
            await context.read<ClientProvider>().deleteClient(client.id);
        if (context.mounted) {
          if (success) {
            AppHelpers.showSuccess(context, 'Client deleted successfully');
          } else {
            AppHelpers.showError(context, 'Failed to delete client');
          }
        }
      }
    }
  }
}
