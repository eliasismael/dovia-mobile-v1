import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/backend/api_requests/api_notifications.dart';
import 'package:dovia/backend/api_requests/api_manager.dart';
import 'package:dovia/repositories/notifications_repository.dart';
import 'package:dovia/core/result.dart';

typedef ListHandler = Future<ApiCallResponse> Function(int page, int limit);

class FakeList extends ListNotificationsCall {
  FakeList(this.handler);
  final ListHandler handler;
  @override
  Future<ApiCallResponse> call(
          {int? page, int? limit, String? authToken = ''}) =>
      handler(page ?? 1, limit ?? 20);
}

class FakeCount extends GetUnreadNotificationCountCall {
  FakeCount([this.handler]);
  final Future<ApiCallResponse> Function()? handler;
  @override
  Future<ApiCallResponse> call({String? authToken = ''}) async =>
      handler != null
          ? await handler!()
          : const ApiCallResponse({
              'data': {'count': 3}
            }, {}, 200);
}

class FakeArchiveAll extends ArchiveAllNotificationsCall {
  FakeArchiveAll(this.handler);
  final Future<ApiCallResponse> Function() handler;
  @override
  Future<ApiCallResponse> call({String? authToken = ''}) => handler();
}

class FakeRead extends MarkNotificationAsReadCall {
  FakeRead(this.handler);
  final Future<ApiCallResponse> Function() handler;
  @override
  Future<ApiCallResponse> call(
          {String? notificationId = '', String? authToken = ''}) =>
      handler();
}

class FakeArchive extends ArchiveNotificationCall {
  FakeArchive(this.handler);
  final Future<ApiCallResponse> Function(String) handler;
  @override
  Future<ApiCallResponse> call(
          {String? notificationId = '', String? authToken = ''}) =>
      handler(notificationId!);
}

ApiCallResponse pageOf(List<String> ids,
        {int page = 1, int limit = 2, int total = 3}) =>
    ApiCallResponse({
      'data': ids
          .map((id) => {
                'id': id,
                'type': 'VISIT_UPDATED',
                'category': 'VISIT',
                'title': id,
                'body': id,
                'readAt': null,
                'createdAt': '2026-09-11T10:00:00Z'
              })
          .toList(),
      'meta': {
        'pagination': {
          'page': page,
          'limit': limit,
          'totalItems': total,
          'totalPages': (total / limit).ceil(),
          'hasNextPage': page * limit < total,
          'hasPreviousPage': page > 1
        }
      },
    }, {}, 200);

void main() {
  final originalList = DOVIAAPINotificationContextGroup.listNotificationsCall;
  final originalCount =
      DOVIAAPINotificationContextGroup.getUnreadNotificationCountCall;
  final originalArchive =
      DOVIAAPINotificationContextGroup.archiveNotificationCall;
  final originalArchiveAll =
      DOVIAAPINotificationContextGroup.archiveAllNotificationsCall;
  final originalRead =
      DOVIAAPINotificationContextGroup.markNotificationAsReadCall;
  final originalToken = authManager.authenticationToken;
  final originalUid = authManager.uid;
  setUp(() {
    authManager.authenticationToken = 'review-fake-token-A';
    authManager.uid = 'account-A';
    DOVIAAPINotificationContextGroup.getUnreadNotificationCountCall =
        FakeCount();
  });
  tearDown(() {
    DOVIAAPINotificationContextGroup.listNotificationsCall = originalList;
    DOVIAAPINotificationContextGroup.getUnreadNotificationCountCall =
        originalCount;
    DOVIAAPINotificationContextGroup.archiveNotificationCall = originalArchive;
    DOVIAAPINotificationContextGroup.archiveAllNotificationsCall =
        originalArchiveAll;
    DOVIAAPINotificationContextGroup.markNotificationAsReadCall = originalRead;
    authManager.authenticationToken = originalToken;
    authManager.uid = originalUid;
  });
  test('late inbox response must not restore previous account after clear',
      () async {
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) => pending.future);
    final repo = NotificationsRepository();
    final loading = repo.loadInbox();
    authManager.authenticationToken = null;
    repo.clear();
    expect(repo.isLoading, isFalse);
    authManager.authenticationToken = 'review-fake-token-B';
    pending.complete(pageOf(['private-account-A']));
    await loading;
    expect(repo.items, isEmpty,
        reason: 'Account B must not see account A notifications');
  });
  test('archiving page 1 must not skip an unread item on page 2', () async {
    final server = ['n1', 'n2', 'n3'];
    DOVIAAPINotificationContextGroup.listNotificationsCall = FakeList(
        (page, limit) async => pageOf(
            server.skip((page - 1) * limit).take(limit).toList(),
            page: page,
            limit: limit,
            total: server.length));
    DOVIAAPINotificationContextGroup.archiveNotificationCall =
        FakeArchive((id) async {
      server.remove(id);
      return const ApiCallResponse(null, {}, 204);
    });
    final repo = NotificationsRepository();
    await repo.loadInbox(limit: 2);
    await repo.archive('n1');
    await repo.loadMore();
    expect(repo.items.map((n) => n.id), ['n2', 'n3']);
  });
  test(
      'failed archive after refresh must not duplicate notification or unread count',
      () async {
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) async => pageOf(['n1', 'n2']));
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.archiveNotificationCall =
        FakeArchive((_) => pending.future);
    final repo = NotificationsRepository();
    await repo.loadInbox();
    final archiving = repo.archive('n1');
    await repo.loadInbox();
    pending.complete(const ApiCallResponse(null, {}, 500));
    await archiving;
    expect(repo.items.map((n) => n.id), ['n1', 'n2']);
    expect(repo.unreadCount, 3);
  });

  test('late unread count is ignored even when clear had an empty inbox',
      () async {
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.getUnreadNotificationCountCall =
        FakeCount(() => pending.future);
    final repo = NotificationsRepository();
    final counting = repo.refreshUnreadCount();
    repo.clear();
    pending.complete(const ApiCallResponse({
      'data': {'count': 17}
    }, {}, 200));
    await counting;
    expect(repo.unreadCount, 0);
  });

  test('account identity change discards a pending response without clear',
      () async {
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) => pending.future);
    final repo = NotificationsRepository();
    final loading = repo.loadInbox();
    authManager.uid = 'account-B';
    pending.complete(pageOf(['account-A-secret']));
    expect(await loading, isA<Failure<List<dynamic>>>());
    expect(repo.items, isEmpty);
  });

  for (final fail in [false, true]) {
    test('archive completion after logout cannot restore data (failure=$fail)',
        () async {
      DOVIAAPINotificationContextGroup.listNotificationsCall =
          FakeList((_, __) async => pageOf(['n1']));
      final pending = Completer<ApiCallResponse>();
      DOVIAAPINotificationContextGroup.archiveNotificationCall =
          FakeArchive((_) => pending.future);
      final repo = NotificationsRepository();
      await repo.loadInbox();
      final archiving = repo.archive('n1');
      repo.clear();
      pending.complete(ApiCallResponse(null, {}, fail ? 500 : 204));
      await archiving;
      expect(repo.items, isEmpty);
      expect(repo.unreadCount, 0);
      expect(repo.meta, isNull);
    });
  }

  test('archiveAll rollback does not restore the previous account', () async {
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) async => pageOf(['n1']));
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.archiveAllNotificationsCall =
        FakeArchiveAll(() => pending.future);
    final repo = NotificationsRepository();
    await repo.loadInbox();
    final archiving = repo.archiveAll();
    repo.clear();
    pending.complete(const ApiCallResponse(null, {}, 500));
    await archiving;
    expect(repo.items, isEmpty);
    expect(repo.unreadCount, 0);
  });

  test('latest refresh wins when responses arrive out of order', () async {
    final old = Completer<ApiCallResponse>();
    var calls = 0;
    DOVIAAPINotificationContextGroup.listNotificationsCall = FakeList(
        (_, __) => calls++ == 0 ? old.future : Future.value(pageOf(['new'])));
    final repo = NotificationsRepository();
    final first = repo.loadInbox();
    await repo.loadInbox();
    old.complete(pageOf(['old']));
    await first;
    expect(repo.items.single.id, 'new');
    expect(repo.isLoading, isFalse);
  });

  test('loadMore from before a refresh cannot append an old page', () async {
    final pending = Completer<ApiCallResponse>();
    var firstPageCalls = 0;
    DOVIAAPINotificationContextGroup.listNotificationsCall = FakeList(
        (page, _) => page == 2
            ? pending.future
            : Future.value(pageOf([firstPageCalls++ == 0 ? 'old' : 'new'])));
    final repo = NotificationsRepository();
    await repo.loadInbox();
    final more = repo.loadMore();
    await repo.loadInbox();
    pending.complete(pageOf(['stale-page'], page: 2));
    await more;
    expect(repo.items.map((n) => n.id), ['new']);
    expect(repo.isLoadingMore, isFalse);
  });

  test('failed reload after archive retries page 1 before advancing', () async {
    final server = ['n1', 'n2', 'n3', 'n4'];
    var failNext = false;
    final pages = <int>[];
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((page, limit) async {
      pages.add(page);
      if (failNext) {
        failNext = false;
        return const ApiCallResponse(null, {}, 500);
      }
      return pageOf(server.skip((page - 1) * limit).take(limit).toList(),
          page: page, limit: limit, total: server.length);
    });
    DOVIAAPINotificationContextGroup.archiveNotificationCall =
        FakeArchive((id) async {
      server.remove(id);
      failNext = true;
      return const ApiCallResponse(null, {}, 204);
    });
    final repo = NotificationsRepository();
    await repo.loadInbox(limit: 2);
    expect(await repo.archive('n1'), isA<Success<void>>());
    expect(repo.error, isNotNull);
    await repo.loadMore();
    await repo.loadMore();
    expect(pages, [1, 1, 1, 2]);
    expect(repo.items.map((n) => n.id), ['n2', 'n3', 'n4']);
    expect(repo.error, isNull);
  });

  test('failed archive without intervening changes restores its snapshot',
      () async {
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) async => pageOf(['n1', 'n2']));
    DOVIAAPINotificationContextGroup.archiveNotificationCall =
        FakeArchive((_) async => const ApiCallResponse(null, {}, 500));
    final repo = NotificationsRepository();
    await repo.loadInbox();
    final before = repo.meta;
    expect(await repo.archive('n1'), isA<Failure<void>>());
    expect(repo.items.map((n) => n.id), ['n1', 'n2']);
    expect(repo.unreadCount, 3);
    expect(repo.meta, same(before));
  });

  test('read rollback after refresh does not increment the refreshed count',
      () async {
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) async => pageOf(['n1']));
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.markNotificationAsReadCall =
        FakeRead(() => pending.future);
    final repo = NotificationsRepository();
    await repo.loadInbox();
    final reading = repo.markAsRead('n1');
    expect(repo.items.single.isRead, isTrue);
    await repo.loadInbox();
    pending.complete(const ApiCallResponse(null, {}, 500));
    await reading;
    expect(repo.items.single.isUnread, isTrue);
    expect(repo.unreadCount, 3);
  });

  test('marking read retains loaded pages and uses the server readAt',
      () async {
    DOVIAAPINotificationContextGroup.listNotificationsCall = FakeList(
        (page, _) async =>
            pageOf(page == 1 ? ['n1', 'n2'] : ['n3'], page: page));
    DOVIAAPINotificationContextGroup.markNotificationAsReadCall =
        FakeRead(() async => const ApiCallResponse({
              'data': {'id': 'n3', 'readAt': '2026-09-11T15:00:00Z'}
            }, {}, 200));
    final repo = NotificationsRepository();
    await repo.loadInbox();
    await repo.loadMore();
    await repo.markAsRead('n3');
    expect(repo.items.map((n) => n.id), ['n1', 'n2', 'n3']);
    expect(repo.items.last.readAt?.toUtc(), DateTime.utc(2026, 9, 11, 15));
    expect(repo.meta?.page, 2);
  });

  test('count-only refresh invalidates rollback even if the value is unchanged',
      () async {
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) async => pageOf(['n1']));
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.markNotificationAsReadCall =
        FakeRead(() => pending.future);
    final repo = NotificationsRepository();
    await repo.loadInbox();
    final reading = repo.markAsRead('n1');
    expect(repo.unreadCount, 2);
    DOVIAAPINotificationContextGroup.getUnreadNotificationCountCall =
        FakeCount(() async => const ApiCallResponse({
              'data': {'count': 2}
            }, {}, 200));
    await repo.refreshUnreadCount();
    pending.complete(const ApiCallResponse(null, {}, 500));
    await reading;
    expect(repo.unreadCount, 2);
    expect(repo.items.single.isUnread, isTrue);
  });

  test('disposing the repository discards pending requests', () async {
    final pending = Completer<ApiCallResponse>();
    DOVIAAPINotificationContextGroup.listNotificationsCall =
        FakeList((_, __) => pending.future);
    final repo = NotificationsRepository();
    final loading = repo.loadInbox();
    repo.dispose();
    pending.complete(pageOf(['n1']));
    await loading;
    expect(repo.items, isEmpty);
  });
}
