import 'dart:io';

import 'package:flutter_app/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';

class MockBox extends Mock implements Box {}

Map userMap = {
  'username': "someuser",
  'email': "email@email.com",
  'password': "password",
  'API_KEY': "abcd1234",
};

MockBox setupMockBox() {
  var box = MockBox();

  when(box.get("username")).thenReturn(userMap['username']);
  when(box.get("email")).thenReturn(userMap['email']);
  when(box.get("API_KEY")).thenReturn(userMap['API_KEY']);

  return box;
}

void main() {
  MockBox mockedHive = setupMockBox();
  setUpAll(() {});
  tearDownAll(() {});
  setUp(() {});

  group('Testing AuthUser', () {
    test("Testing setAPIKey", () {
      AuthUser user = new AuthUser.testing(mockedHive);
      user.setAPIKey(userMap['key']);
      verify(mockedHive.put("API_KEY", userMap['key']));
    });

    test("Testing getAPIKey", () {
      AuthUser user = new AuthUser.testing(mockedHive);
      user.getAPIKey(load: true);
      verify(mockedHive.get("API_KEY"));
    });

    test("Testing loadFromHive", () {
      AuthUser user = AuthUser.testing(mockedHive);
      user.loadFromHive();
      expect(user.getUsername(), userMap['username']);
      expect(user.getEmail(), userMap['email']);
      expect(user.getAPIKey(load: true), userMap['API_KEY']);
    });
    test("Testing attributesToMap", () {
      AuthUser user = AuthUser.testing(mockedHive);
      user.setPassword(userMap['password']);
      user.loadFromHive();
      List<String> attributes = ['username', 'password', 'email'];
      Map<String, dynamic> smallerDict = {
        'username': userMap['username'],
        'email': userMap['email'],
        'password': userMap['password'],
      };

      Map result = user.attributesToMap(attributes);
      expect(result, smallerDict);
    });
    test("Testing isNull", () {
      AuthUser user = AuthUser.testing(mockedHive);
      user.setPassword(null);
      user.setEmail(userMap['email']);

      expect(user.isNull(['password']), true);
      expect(user.isNull(['email']), false);
    });

    test("Testing saveToHive", () {
      AuthUser user = AuthUser.testing(mockedHive);
      user.setPassword(userMap['password']);
      user.loadFromHive();
      user.saveToHive(field: 'password');
      verifyNever(mockedHive.put("password", userMap['password']));

      user.saveToHive(field: 'API_KEY');
      verify(mockedHive.put("API_KEY", userMap['API_KEY']));
    });
  });

  group('Testing Profile', () {
    test("Testing fromJson using example", () {});
  });

  group('Testing Interaction', () {
    test("Testing fromJson", () {});
    test("Testing _loadParticipants from example", () {});
    test("Testing _loadDateTime from string or null", () {});
  });
}
