import 'package:hive/hive.dart';

abstract class CachedClass {
  String key;
  DateTime lastUpdated;
  Map<String, Function> validators;
  Box cache;

  // Should probably not include the key
  Map<String, dynamic> toCacheFormat();
  CachedClass fromCacheFormat(Map<String, dynamic> fromCache);

  Future<void> initCache(String cacheName) async {
    if (Hive.isBoxOpen(cacheName)) {
      this.cache = Hive.box(cacheName);
    } else {
      this.cache = await Hive.openBox(cacheName);
    }

  }

  void throwIfCacheMissing() {
    if (cache == null) throw CacheStorageMissing();

    if (!cache.isOpen) throw CacheStorageMissing();
  }

  void validateFields({bool enforceSameLength = false}) {
    Map<String, dynamic> fields = this.toCacheFormat();

    if ((validators.keys.length != fields.keys.length) && enforceSameLength) {
      throw ValidatorFieldMismatch();
    }

    for (String field in validators.keys) {
      Function func = validators[field];
      if (!func(fields[field])) {
        throw InvalidField(field);
      }
    }
  }

  CachedClass getWithKey(String key) {
    this.throwIfCacheMissing();

    Map<String, dynamic> fromDB = cache.get(key);
    return fromCacheFormat(fromDB);
  }

  List<CachedClass> getAll() {
    this.throwIfCacheMissing();

    List<CachedClass> objects = new List<CachedClass>();
    for (String key in cache.keys) {
      objects.add(this.getWithKey(key));
    }
    return objects;
  }

  bool canUpdate(DateTime updatedTime) {
    return lastUpdated.difference(updatedTime).inSeconds != 0;
  }

  void updateEntry(CachedClass updatedObject) {
    this.throwIfCacheMissing();

    Map<String, dynamic> toDB = this.toCacheFormat();
    cache.put(updatedObject.key, toDB);
  }
  
  // Updates all entries that have a difference in last modified
  void updateModified(List<CachedClass> objectsInCache) {
    this.throwIfCacheMissing();

    List<CachedClass> objsToUpdate = new List<CachedClass>();

    for (CachedClass entry in objectsInCache) {
      CachedClass fromStorage = this.getWithKey(entry.key);
      if (fromStorage == null) {
        throw NotInCache();
      }

      if (fromStorage.canUpdate(entry.lastUpdated)) {
        objsToUpdate.add(entry);
      }
    }
    this.addManyEntries(objsToUpdate);
  }

  void addEntry(CachedClass object) {
    this.throwIfCacheMissing();

    object.validateFields();
    cache.put(object.key, this.toCacheFormat());
  }

  void addManyEntries(List<CachedClass> objects) {
    this.throwIfCacheMissing();
    
    Map<String, Map<String, dynamic>> allEntries = new Map();
    for (CachedClass obj in objects) {
      obj.validateFields();
      allEntries[obj.key] = this.toCacheFormat();
    }

    cache.putAll(allEntries);
  }



  static bool isDouble(dynamic field) {
    return field is double;
  }

  static bool isInt(dynamic field) {
    return field is int;
  }

  static bool isString(dynamic field) {
    return field is String;
  }

  static bool isBoolean(dynamic field) {
    return field is bool;
  }

  // TODO test various cases where there is junk before and after the uuid
  // TODO test how the regex matching works
  static bool isUUID(dynamic field) {
    if (isString(field)) {
      final regExp = new RegExp(
          r"[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$");
      RegExpMatch match = regExp.firstMatch(field);

      if (match != null) {
        String actualUUID = field.substring(match.start, match.end);
        return actualUUID.length == field.length;
      }
    }
    return false;
  }
}

class ValidatorFieldMismatch implements Exception {
  String message;

  String errorMessage() {
    return 'The number of validators does not match the number of fields in length';
  }
}

class InvalidField implements Exception {
  String message;

  InvalidField([this.message]);

  String errorMessage() {
    return 'Field is invalid: $message';
  }
}

class CacheStorageMissing implements Exception {
  String message;

  String errorMessage() {
    return 'The cache storage was not initialized';
  }
}

class NotInCache implements Exception {
  String message;

  String errorMessage() {
    return 'Tried to retrieve an object that was not stored in the cache';
  }
}
