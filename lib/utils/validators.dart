
class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingrese un teléfono válido';
    }
    return null;
  }

  static String? validateDNI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'DNI es requerido';
    }
    final dniRegex = RegExp(r'^\d{7,8}$');
    if (!dniRegex.hasMatch(value)) {
      return 'DNI debe tener 7 u 8 dígitos';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }
    if (number < 0) {
      return '$fieldName debe ser mayor a 0';
    }
    return null;
  }

  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Año es requerido';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Año debe ser un número válido';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Año debe estar entre 1900 y ${currentYear + 1}';
    }
    return null;
  }

  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return '$fieldName debe ser una fecha válida';
    }
  }

  static String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Latitude is optional
    }
    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Latitud debe ser un número válido';
    }
    if (lat < -90 || lat > 90) {
      return 'Latitud debe estar entre -90 y 90';
    }
    return null;
  }

  static String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Longitude is optional
    }
    final lng = double.tryParse(value);
    if (lng == null) {
      return 'Longitud debe ser un número válido';
    }
    if (lng < -180 || lng > 180) {
      return 'Longitud debe estar entre -180 y 180';
    }
    return null;
  }
}
