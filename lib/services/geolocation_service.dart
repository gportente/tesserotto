import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../database/database_helper.dart';
import '../models/card_location.dart';

class GeolocationService {
  GeolocationService._();
  static final instance = GeolocationService._();

  static final _notifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<Position>? _positionSub;

  // Per card: don't re-notify within 30 minutes
  final Map<String, DateTime> _lastNotified = {};
  static const _cooldown = Duration(minutes: 30);

  static const _channelId = 'nearby_stores';
  static const _channelName = 'Notifiche negozi vicini';
  static const _channelDesc =
      'Avvisi quando sei vicino a un negozio con la tua tessera';

  static Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<bool> requestPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return false;

    // Request notification permission (Android 13+ / iOS)
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Future<void> startMonitoring() async {
    final granted = await requestPermissions();
    if (!granted) return;

    _positionSub?.cancel();

    final LocationSettings settings;
    if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Tesserotto',
          notificationText: 'Monitoraggio negozi vicini attivo',
          enableWakeLock: false,
        ),
      );
    } else if (Platform.isIOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
        activityType: ActivityType.other,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
      );
    }

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPositionUpdate);
  }

  void stopMonitoring() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  Future<void> _onPositionUpdate(Position position) async {
    try {
      final allLocations = await DatabaseHelper.instance.getAllCardLocations();
      for (final loc in allLocations) {
        final dist =
            _haversine(position.latitude, position.longitude, loc.lat, loc.lng);
        if (dist <= loc.radius) {
          await _maybeNotify(loc);
        }
      }
    } catch (_) {
      // Silently ignore errors to keep the stream alive
    }
  }

  Future<void> _maybeNotify(CardLocation location) async {
    final last = _lastNotified[location.cardId];
    if (last != null && DateTime.now().difference(last) < _cooldown) return;

    final card = await DatabaseHelper.instance.getCardById(location.cardId);
    if (card == null) return;

    _lastNotified[location.cardId] = DateTime.now();

    await _notifications.show(
      location.cardId.hashCode & 0x7FFFFFFF,
      card.name,
      'Sei vicino a: ${location.address}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: location.cardId,
    );
  }

  /// Haversine distance in meters between two coordinates.
  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;
}
