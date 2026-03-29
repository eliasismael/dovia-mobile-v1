import 'package:rxdart/rxdart.dart';

import 'custom_auth_manager.dart';

class DoviaAuthUser {
  DoviaAuthUser({required this.loggedIn, this.uid});

  bool loggedIn;
  String? uid;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<DoviaAuthUser> doviaAuthUserSubject =
    BehaviorSubject.seeded(DoviaAuthUser(loggedIn: false));
Stream<DoviaAuthUser> doviaAuthUserStream() =>
    doviaAuthUserSubject.asBroadcastStream().map((user) => currentUser = user);
