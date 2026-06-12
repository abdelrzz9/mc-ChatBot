import 'dart:async';

class SessionManager {
  final Duration _timeoutDuration;
  Timer? _inactivityTimer;
  bool _isAuthenticated = false;
  void Function()? _onSessionExpired;
  DateTime _lastActivity = DateTime.now();
  bool _isPaused = false;

  SessionManager({
    Duration timeoutDuration = const Duration(minutes: 15),
    void Function()? onSessionExpired,
  })  : _timeoutDuration = timeoutDuration,
        _onSessionExpired = onSessionExpired;

  bool get isAuthenticated => _isAuthenticated;
  DateTime get lastActivity => _lastActivity;
  Duration get timeUntilTimeout {
    final elapsed = DateTime.now().difference(_lastActivity);
    final remaining = _timeoutDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void startSession() {
    _isAuthenticated = true;
    _lastActivity = DateTime.now();
    _resetTimer();
  }

  void endSession() {
    _isAuthenticated = false;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void recordActivity() {
    if (!_isAuthenticated || _isPaused) return;
    _lastActivity = DateTime.now();
    _resetTimer();
  }

  void pause() {
    _isPaused = true;
    _inactivityTimer?.cancel();
  }

  void resume() {
    _isPaused = false;
    if (_isAuthenticated) {
      _resetTimer();
    }
  }

  void setOnSessionExpired(void Function()? callback) {
    _onSessionExpired = callback;
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeoutDuration, () {
      if (_isAuthenticated && !_isPaused) {
        // Session expired silently
        _isAuthenticated = false;
        _onSessionExpired?.call();
      }
    });
  }

  void dispose() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _onSessionExpired = null;
  }
}
