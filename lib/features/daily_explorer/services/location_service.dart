// import 'package:geolocator/geolocator.dart';  // Temporarily disabled
// import 'package:permission_handler/permission_handler.dart';  // Temporarily disabled
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
    'address': address,
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    latitude: json['latitude'],
    longitude: json['longitude'],
    accuracy: json['accuracy'],
    timestamp: DateTime.parse(json['timestamp']),
    address: json['address'],
  );
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  
  LocationService._();

  LocationData? _lastKnownLocation;
  DateTime? _lastLocationUpdate;
  
  // Cache location for 5 minutes
  static const Duration _locationCacheTimeout = Duration(minutes: 5);

  LocationData? get lastKnownLocation => _lastKnownLocation;

  /// Check if location services are enabled and permissions are granted
  Future<bool> checkLocationPermissions() async {
    try {
      // Mock implementation - always return true for development
      if (kDebugMode) {
        print('Mock location permissions: granted');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location permissions: $e');
      }
      return false;
    }
  }

  /// Get current location with caching
  Future<LocationData?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // Return cached location if still valid and not forcing refresh
      if (!forceRefresh && 
          _lastKnownLocation != null && 
          _lastLocationUpdate != null &&
          DateTime.now().difference(_lastLocationUpdate!) < _locationCacheTimeout) {
        return _lastKnownLocation;
      }

      // Check permissions
      bool hasPermission = await checkLocationPermissions();
      if (!hasPermission) {
        return _lastKnownLocation; // Return cached location if available
      }

      // Mock location data for development (San Francisco coordinates)
      final locationData = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        timestamp: DateTime.now(),
        address: 'San Francisco, CA',
      );

      // Update cache
      _lastKnownLocation = locationData;
      _lastLocationUpdate = DateTime.now();

      if (kDebugMode) {
        print('Mock location updated: ${locationData.latitude}, ${locationData.longitude}');
      }

      return locationData;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      return _lastKnownLocation; // Return cached location if available
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    // Haversine formula implementation for distance calculation
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Check if user is within a certain radius of a location (geofencing)
  Future<bool> isWithinRadius({
    required double targetLat,
    required double targetLon,
    required double radiusInKm,
  }) async {
    try {
      final currentLocation = await getCurrentLocation();
      if (currentLocation == null) return false;

      final distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        targetLat,
        targetLon,
      );

      return distance <= radiusInKm;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking radius: $e');
      }
      return false;
    }
  }

  /// Get location updates stream
  Stream<LocationData> getLocationStream() async* {
    bool hasPermission = await checkLocationPermissions();
    if (!hasPermission) return;

    // Mock location stream - yields the same location every 30 seconds
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      
      final locationData = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        timestamp: DateTime.now(),
        address: 'San Francisco, CA',
      );

      _lastKnownLocation = locationData;
      _lastLocationUpdate = DateTime.now();

      yield locationData;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    // Mock implementation - would open location settings in a real app
    if (kDebugMode) {
      print('Mock: Opening location settings');
    }
  }

  /// Open app settings for location permissions
  Future<void> openAppSettings() async {
    // Mock implementation - would open app settings in a real app
    if (kDebugMode) {
      print('Mock: Opening app settings');
    }
  }

  /// Format location for display
  String formatLocation(LocationData location) {
    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  /// Get location accuracy description
  String getAccuracyDescription(double accuracy) {
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 10) return 'Good';
    if (accuracy <= 20) return 'Fair';
    return 'Poor';
  }

  /// Clear cached location data
  void clearCache() {
    _lastKnownLocation = null;
    _lastLocationUpdate = null;
  }
}