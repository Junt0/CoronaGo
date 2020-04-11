import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() {
  });
  tearDownAll(() {
  });
  setUp(() {
  });

  group('Testing AuthUser', () {
    test("Testing storeAPIKey", (){
    });
    test("Testing attributesToMap", (){});
    test("Testing loadAPIKey", (){});
    test("Testing isNull", (){});

    test("Testing saveToHive", (){});

  });

  group('Testing Profile', () {
    test("Testing fromJson using example", (){});
  });

  group('Testing Interaction', () {
    test("Testing fromJson", (){});
    test("Testing _loadParticipants from example", (){});
    test("Testing _loadDateTime from string or null", (){});
  });
}
