T getKey<T>(Map<String, dynamic> map, String key, T defaultValue) {
  var result = map;
  for (var oneKey in key.split(".")) {
    if (result is Map && result.containsKey(oneKey)) {
      if (result[oneKey] is! Map) {
        return result[oneKey] is T ? result[oneKey] : defaultValue;
      }
      result = result[oneKey];
    } else {
      return defaultValue;
    }
  }
  return defaultValue;
}
