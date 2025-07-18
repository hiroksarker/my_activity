import 'package:flutter/foundation.dart';
import '../models/travel_activity.dart';
import '../models/travel_alert.dart';
import '../models/travel_memory.dart';
import '../services/pocketbase_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class DailyExplorerProvider extends ChangeNotifier {
  final PocketBaseService _pocketbaseService = PocketBaseService();
  final LocationService _locationService = LocationService.instance;
  final WeatherService _weatherService = WeatherService.instance;

  // State
  List<TravelActivity> _todayActivities = [];
  List<TravelAlert> _activeAlerts = [];
  List<TravelMemory> _todayMemories = [];
  TravelActivity? _currentActivity;
  LocationData? _currentLocation;
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TravelActivity> get todayActivities => _todayActivities;
  List<TravelAlert> get activeAlerts => _activeAlerts;
  List<TravelMemory> get todayMemories => _todayMemories;
  TravelActivity? get currentActivity => _currentActivity;
  LocationData? get currentLocation => _currentLocation;
  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load today's activities
  Future<void> loadTodayActivities() async {
    try {
      _setLoading(true);
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final activities = await _pocketbaseService.getActivities(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      _todayActivities = activities;
      _updateCurrentActivity();
      _clearError();
    } catch (e) {
      _setError('Failed to load activities: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load active alerts
  Future<void> loadActiveAlerts() async {
    try {
      final alerts = await _pocketbaseService.getAlerts(activeOnly: true);
      _activeAlerts = alerts;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading alerts: $e');
    }
  }

  // Update current location
  Future<void> updateLocation({bool forceRefresh = false}) async {
    try {
      final location = await _locationService.getCurrentLocation(
        forceRefresh: forceRefresh,
      );
      
      if (location != null) {
        _currentLocation = location;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error updating location: $e');
    }
  }

  // Update weather information
  Future<void> updateWeather({bool forceRefresh = false}) async {
    try {
      final weather = await _weatherService.getCurrentWeather(
        forceRefresh: forceRefresh,
      );
      
      if (weather != null) {
        _currentWeather = weather;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error updating weather: $e');
    }
  }

  void _updateCurrentActivity() {
    final now = DateTime.now();
    
    try {
      _currentActivity = _todayActivities.firstWhere(
        (activity) => 
            activity.startTime.isBefore(now) && 
            activity.endTime.isAfter(now) &&
            activity.status == ActivityStatus.active,
      );
    } catch (e) {
      _currentActivity = null;
    }
    
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}