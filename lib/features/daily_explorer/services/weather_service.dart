import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'location_service.dart';

class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String description;
  final String icon;
  final double windSpeed;
  final int visibility;
  final DateTime timestamp;
  final String location;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.visibility,
    required this.timestamp,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'feelsLike': feelsLike,
    'humidity': humidity,
    'description': description,
    'icon': icon,
    'windSpeed': windSpeed,
    'visibility': visibility,
    'timestamp': timestamp.toIso8601String(),
    'location': location,
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    temperature: json['temperature'].toDouble(),
    feelsLike: json['feelsLike'].toDouble(),
    humidity: json['humidity'],
    description: json['description'],
    icon: json['icon'],
    windSpeed: json['windSpeed'].toDouble(),
    visibility: json['visibility'],
    timestamp: DateTime.parse(json['timestamp']),
    location: json['location'],
  );

  String get temperatureDisplay => '${temperature.round()}°';
  String get feelsLikeDisplay => 'Feels like ${feelsLike.round()}°';
  String get humidityDisplay => '$humidity%';
  String get windSpeedDisplay => '${windSpeed.toStringAsFixed(1)} m/s';
  String get visibilityDisplay => '${(visibility / 1000).toStringAsFixed(1)} km';
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  const WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) => WeatherForecast(
    date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    maxTemp: json['temp']['max'].toDouble(),
    minTemp: json['temp']['min'].toDouble(),
    description: json['weather'][0]['description'],
    icon: json['weather'][0]['icon'],
    humidity: json['humidity'],
    windSpeed: json['wind_speed'].toDouble(),
  );

  String get maxTempDisplay => '${maxTemp.round()}°';
  String get minTempDisplay => '${minTemp.round()}°';
  String get tempRangeDisplay => '$minTempDisplay - $maxTempDisplay';
}

class WeatherService {
  static WeatherService? _instance;
  static WeatherService get instance => _instance ??= WeatherService._();
  
  WeatherService._();

  // OpenWeatherMap API (you'll need to get a free API key)
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  WeatherData? _cachedWeather;
  DateTime? _lastWeatherUpdate;
  List<WeatherForecast>? _cachedForecast;
  DateTime? _lastForecastUpdate;
  
  // Cache weather for 10 minutes
  static const Duration _weatherCacheTimeout = Duration(minutes: 10);

  WeatherData? get cachedWeather => _cachedWeather;
  List<WeatherForecast>? get cachedForecast => _cachedForecast;

  /// Get current weather for user's location
  Future<WeatherData?> getCurrentWeather({bool forceRefresh = false}) async {
    try {
      // Return cached weather if still valid and not forcing refresh
      if (!forceRefresh && 
          _cachedWeather != null && 
          _lastWeatherUpdate != null &&
          DateTime.now().difference(_lastWeatherUpdate!) < _weatherCacheTimeout) {
        return _cachedWeather;
      }

      // Get current location
      final location = await LocationService.instance.getCurrentLocation();
      if (location == null) {
        if (kDebugMode) {
          print('Cannot get weather: location not available');
        }
        return _cachedWeather;
      }

      return await getWeatherForLocation(
        location.latitude, 
        location.longitude,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current weather: $e');
      }
      return _cachedWeather;
    }
  }

  /// Get weather for specific location
  Future<WeatherData?> getWeatherForLocation(
    double lat, 
    double lon, {
    bool forceRefresh = false,
  }) async {
    try {
      if (_apiKey == 'YOUR_OPENWEATHER_API_KEY') {
        // Return mock data for development
        return _getMockWeatherData();
      }

      final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final weather = WeatherData(
          temperature: data['main']['temp'].toDouble(),
          feelsLike: data['main']['feels_like'].toDouble(),
          humidity: data['main']['humidity'],
          description: data['weather'][0]['description'],
          icon: data['weather'][0]['icon'],
          windSpeed: data['wind']['speed'].toDouble(),
          visibility: data['visibility'],
          timestamp: DateTime.now(),
          location: data['name'],
        );

        _cachedWeather = weather;
        _lastWeatherUpdate = DateTime.now();

        if (kDebugMode) {
          print('Weather updated for ${weather.location}: ${weather.temperatureDisplay}');
        }

        return weather;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting weather for location: $e');
      }
      return _cachedWeather;
    }
  }

  /// Get weather forecast for next 7 days
  Future<List<WeatherForecast>?> getWeatherForecast({bool forceRefresh = false}) async {
    try {
      // Return cached forecast if still valid and not forcing refresh
      if (!forceRefresh && 
          _cachedForecast != null && 
          _lastForecastUpdate != null &&
          DateTime.now().difference(_lastForecastUpdate!) < _weatherCacheTimeout) {
        return _cachedForecast;
      }

      // Get current location
      final location = await LocationService.instance.getCurrentLocation();
      if (location == null) {
        if (kDebugMode) {
          print('Cannot get forecast: location not available');
        }
        return _cachedForecast;
      }

      if (_apiKey == 'YOUR_OPENWEATHER_API_KEY') {
        // Return mock data for development
        return _getMockForecastData();
      }

      final url = '$_baseUrl/onecall?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric&exclude=minutely,hourly,alerts';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dailyData = data['daily'] as List;
        
        final forecast = dailyData
            .take(7) // Next 7 days
            .map((day) => WeatherForecast.fromJson(day))
            .toList();

        _cachedForecast = forecast;
        _lastForecastUpdate = DateTime.now();

        if (kDebugMode) {
          print('Weather forecast updated: ${forecast.length} days');
        }

        return forecast;
      } else {
        throw Exception('Failed to load weather forecast: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting weather forecast: $e');
      }
      return _cachedForecast;
    }
  }

  /// Check if weather conditions might affect travel
  bool isWeatherAffectingTravel(WeatherData weather) {
    final description = weather.description.toLowerCase();
    
    // Check for conditions that might affect travel
    return description.contains('rain') ||
           description.contains('snow') ||
           description.contains('storm') ||
           description.contains('fog') ||
           weather.windSpeed > 10 || // Strong wind
           weather.visibility < 1000; // Poor visibility
  }

  /// Get weather-based activity recommendations
  List<String> getActivityRecommendations(WeatherData weather) {
    final recommendations = <String>[];
    final temp = weather.temperature;
    final description = weather.description.toLowerCase();

    if (description.contains('rain')) {
      recommendations.addAll([
        'Visit museums or galleries',
        'Explore shopping centers',
        'Try indoor activities',
        'Visit cafes or restaurants',
      ]);
    } else if (temp > 25) {
      recommendations.addAll([
        'Visit parks or gardens',
        'Outdoor dining',
        'Walking tours',
        'Beach or waterfront activities',
      ]);
    } else if (temp < 10) {
      recommendations.addAll([
        'Visit heated attractions',
        'Indoor entertainment',
        'Hot drinks at cafes',
        'Museums and galleries',
      ]);
    } else {
      recommendations.addAll([
        'City walking tours',
        'Outdoor sightseeing',
        'Park visits',
        'Outdoor markets',
      ]);
    }

    return recommendations;
  }

  /// Get weather icon URL
  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  /// Clear cached weather data
  void clearCache() {
    _cachedWeather = null;
    _lastWeatherUpdate = null;
    _cachedForecast = null;
    _lastForecastUpdate = null;
  }

  /// Mock weather data for development
  WeatherData _getMockWeatherData() {
    return WeatherData(
      temperature: 22.5,
      feelsLike: 24.0,
      humidity: 65,
      description: 'Partly cloudy',
      icon: '02d',
      windSpeed: 3.2,
      visibility: 10000,
      timestamp: DateTime.now(),
      location: 'Current Location',
    );
  }

  /// Mock forecast data for development
  List<WeatherForecast> _getMockForecastData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return WeatherForecast(
        date: now.add(Duration(days: index)),
        maxTemp: 25.0 + (index % 3),
        minTemp: 15.0 + (index % 2),
        description: index % 2 == 0 ? 'Sunny' : 'Partly cloudy',
        icon: index % 2 == 0 ? '01d' : '02d',
        humidity: 60 + (index * 5),
        windSpeed: 2.0 + (index * 0.5),
      );
    });
  }
}