import 'dart:math';

/// Geo utilities: Haversine distance calculation and geohash encoding.
class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusKm = 6371.0;

  /// Calculates the distance in km between two lat/lng points using the
  /// Haversine formula.
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Formats a distance value into a human-readable string.
  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    }
    return '${km.round()} km';
  }

  /// Encodes lat/lng to a geohash string at the given precision.
  /// Precision 6 → ~1.2km cell, good for job search queries.
  static String encode(double lat, double lng, {int precision = 6}) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;

    var bit = 0, ch = 0;
    var isEven = true;
    final result = StringBuffer();

    while (result.length < precision) {
      if (isEven) {
        final mid = (minLng + maxLng) / 2;
        if (lng > mid) {
          ch |= (1 << (4 - bit));
          minLng = mid;
        } else {
          maxLng = mid;
        }
      } else {
        final mid = (minLat + maxLat) / 2;
        if (lat > mid) {
          ch |= (1 << (4 - bit));
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }
      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        result.write(base32[ch]);
        bit = 0;
        ch = 0;
      }
    }
    return result.toString();
  }

  /// Returns the [lower, upper] prefix bounds for a geohash query
  /// covering approximately the given radius in km around (lat, lng).
  ///
  /// This is a simplified single-cell prefix query suitable for
  /// first-pass filtering; exact distance filtering must follow.
  static (String, String) queryBounds(
    double lat,
    double lng, {
    int precision = 4, // precision 4 → ~40km cell; adjust per use-case
  }) {
    final hash = encode(lat, lng, precision: precision);
    // Geohash range: same prefix prefix, append min/max chars
    return ('${hash}\u0000', '${hash}\uFFFF');
  }
}
