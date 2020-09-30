import 'user.dart';

/// Used to avoid to serialize properties to json
Null readonly(_) => null;

/// Helper class for serialization to and from json
class Serialization {
  /// Used to avoid to serialize properties to json
  static const Function readOnly = readonly;

  /// List of users to list of userIds
  static List<String> userIds(List<User> users) {
    return users?.map((u) => u.id)?.toList();
  }

  /// Takes unknown json keys and puts them in the `extra_data` key
  static Map<String, dynamic> moveToExtraDataFromRoot(
    Map<String, dynamic> json,
    List<String> topLevelFields,
  ) {
    if (json == null) return null;

    final extraDataMap = Map<String, dynamic>.from(json)
      ..removeWhere(
        (key, value) => topLevelFields.contains(key),
      );
    final rootFields = json
      ..removeWhere((key, value) => extraDataMap.keys.contains(key));
    return rootFields
      ..addAll({
        'extra_data': extraDataMap,
      });
  }

  /// Takes values in `extra_data` key and puts them on the root level of the json map
  static Map<String, dynamic> moveFromExtraDataToRoot(
    Map<String, dynamic> json,
    List<String> topLevelFields,
  ) {
    return json
      ..addAll({
        if (json['extra_data'] != null) ...json['extra_data'],
      })
      ..remove('extra_data');
  }
}
