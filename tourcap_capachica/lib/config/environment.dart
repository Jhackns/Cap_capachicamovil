enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://10.80.96.179:8000';
      case Environment.staging:
        return 'https://staging-api.turismo-capachica.com';
      case Environment.production:
        return 'https://api.turismo-capachica.com';
    }
  }

  static bool get enableLogging {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static Duration get timeoutDuration {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }
} 