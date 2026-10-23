import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/core/result.dart';
import '/domain/notification_models.dart';
import '/flutter_flow/nav/nav.dart';
import '/notifications/notification_navigation.dart';
import '/notifications/notification_router.dart';
import '/notifications/notification_test_sheet.dart';
import '/repositories/notifications_repository.dart';
import '/shared_components/dovia_spinner.dart';

/// Inbox de notificaciones compartido por todos los perfiles.
///
/// Lee de [NotificationsRepository]: cada notificación se borra deslizándola
/// o con su botón, y "Borrar todas" vacía el inbox
/// (`DELETE /notifications/{id}` y `DELETE /notifications/all`).
class NotificationsInboxWidget extends StatefulWidget {
  const NotificationsInboxWidget({super.key});

  @override
  State<NotificationsInboxWidget> createState() =>
      _NotificationsInboxWidgetState();
}

class _NotificationsInboxWidgetState extends State<NotificationsInboxWidget>
    with TickerProviderStateMixin {
  static const Color aqua = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color muted = Color(0xFF888888);
  static const Color deleteRed = Color(0xFFDC2626);

  static const Duration undoWindow = Duration(seconds: 5);

  // "Borrar todas" espera [undoWindow] antes de llamar al backend, para poder
  // deshacerlo. Si se sale de la pantalla antes, se borra igual.
  late final AnimationController _undoController =
      AnimationController(vsync: this, duration: undoWindow);
  // Las tarjetas salen hacia el costado, una detrás de otra.
  late final AnimationController _slideController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  Timer? _deleteAllTimer;
  NotificationsRepository? _repo;

  bool get _pendingDeleteAll => _deleteAllTimer != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = context.read<NotificationsRepository>();
  }

  @override
  void dispose() {
    if (_pendingDeleteAll) {
      _deleteAllTimer!.cancel();
      _repo?.archiveAll();
    }
    _undoController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationsRepository>().loadInbox();
    });
  }

  void _showError(Result<void> result) {
    if (result is Failure<void> && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message),
        backgroundColor: deleteRed,
      ));
    }
  }

  /// Marca la notificación como leída y, si hay una pantalla segura para
  /// ella, la abre. Si no, se queda en la bandeja.
  void _open(AppNotification n) {
    if (n.isUnread) context.read<NotificationsRepository>().markAsRead(n.id);
    final router = GoRouter.of(context);
    final destination = resolveNotificationTap(
      role: FFAppState().UserRole,
      type: n.type,
      actionPath: n.actionPath,
      isAppRoute: (path) => isAppRoute(router, path),
    );
    if (destination == null) return;
    openNotificationDestination(router, destination);
  }

  Future<void> _delete(AppNotification n) async {
    _showError(await context.read<NotificationsRepository>().archive(n.id));
  }

  Future<void> _deleteAll() async {
    if (_slideController.isAnimating || _pendingDeleteAll) return;
    await _slideController.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _undoController.forward(from: 0);
      _deleteAllTimer = Timer(undoWindow, _commitDeleteAll);
    });
  }

  void _undoDeleteAll() {
    _deleteAllTimer?.cancel();
    _undoController.stop();
    setState(() => _deleteAllTimer = null);
    // Las tarjetas vuelven desde el costado.
    _slideController.reverse();
  }

  Future<void> _commitDeleteAll() async {
    setState(() => _deleteAllTimer = null);
    _slideController.value = 0;
    _showError(await context.read<NotificationsRepository>().archiveAll());
  }

  Widget _buildUndoPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: AnimatedBuilder(
              animation: _undoController,
              builder: (context, _) => CustomPaint(
                painter: _PieCountdownPainter(
                  progress: 1 - _undoController.value,
                  color: aqua,
                  background: aqua.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Se borraron todas las notificaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _undoDeleteAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: aqua,
              side: const BorderSide(color: aqua),
              minimumSize: const Size(160, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Deshacer'),
          ),
        ],
      ),
    );
  }

  /// Sólo en dev y staging: mandarse una notificación de prueba.
  Widget _buildTestButton() => TextButton(
        onPressed: () => showNotificationTestSheet(context),
        child: const Text(
          'Probar una notificación',
          style:
              TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: aqua),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<NotificationsRepository>();
    final items = repo.items;

    if (_pendingDeleteAll) return _buildUndoPanel();

    if (repo.isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: DoviaSpinner()),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.notifications_none, size: 48, color: muted),
            const SizedBox(height: 12),
            Text(
              repo.error ?? 'No tienes notificaciones',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Public Sans', fontSize: 14, color: muted),
            ),
            if (repo.error != null)
              TextButton(
                onPressed: () => repo.loadInbox(),
                child: const Text('Reintentar', style: TextStyle(color: aqua)),
              ),
            if (notificationTestEnabled) _buildTestButton(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notificationTestEnabled)
          Align(alignment: Alignment.centerLeft, child: _buildTestButton()),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _deleteAll,
            icon: const Icon(Icons.delete_sweep_outlined,
                size: 20, color: deleteRed),
            label: const Text(
              'Borrar todas',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: deleteRed,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        for (int i = 0; i < items.length; i++) ...[
          _slideOut(i, items.length, _buildItem(items[i])),
          const SizedBox(height: 12),
        ],
        if (repo.hasMore)
          Center(
            child: repo.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: DoviaSpinner(),
                  )
                : TextButton(
                    onPressed: () => repo.loadMore(),
                    child: const Text('Ver más', style: TextStyle(color: aqua)),
                  ),
          ),
      ],
    );
  }

  Widget _slideOut(int index, int count, Widget child) {
    // Escalonado: cada tarjeta arranca un poco después de la anterior.
    final visible = count.clamp(1, 8);
    final start = (index.clamp(0, visible - 1) / visible) * 0.5;
    final animation = CurvedAnimation(
      parent: _slideController,
      curve: Interval(start, (start + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeInCubic),
    );
    return SlideTransition(
      position: Tween(begin: Offset.zero, end: const Offset(1.3, 0))
          .animate(animation),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildItem(AppNotification n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: deleteRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _delete(n),
      child: GestureDetector(
        onTap: () => _open(n),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: n.isUnread ? aqua : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.categoryLabel,
                            style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                color: muted),
                          ),
                        ),
                        if (n.createdAt != null)
                          Text(
                            _timeAgo(n.createdAt!),
                            style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                color: muted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.title,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 15,
                        fontWeight:
                            n.isUnread ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: textColor),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _delete(n),
                icon: const Icon(Icons.delete_outline, size: 20, color: muted),
                tooltip: 'Borrar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

/// Círculo lleno que se va vaciando como una torta.
class _PieCountdownPainter extends CustomPainter {
  _PieCountdownPainter({
    required this.progress,
    required this.color,
    required this.background,
  });

  final double progress;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(rect, Paint()..color = background);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      true,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PieCountdownPainter old) => old.progress != progress;
}
