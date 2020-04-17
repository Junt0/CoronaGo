import 'package:flutter_app/models/auth_user.dart';
import 'package:flutter_app/services/api_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:mockito/mockito.dart';

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
  MockBox mockBox = setupMockBox();
  group('Testing APIHelper', () {
    test("Testing _throwProperAPIException with null response", () {});
    test("Testing _throwProperAPIException with 200 status code", () {
      APIHelper api = new APIHelper();
      Response response = Response(json.encode({}), 200);
      api.throwProperAPIException(response);
    });
    test("Testing _throwProperAPIException with 400 status code", () {
      APIHelper api = new APIHelper();
      Response response = Response(json.encode({}), 400);
      try {
        api.throwProperAPIException(response);
        fail("Auth exception not thrown");
      } catch (e) {
        expect(true, e is APIAuthError);
      }
    });
    test("Testing _throwProperAPIException with 500 status code", () {
      APIHelper api = new APIHelper();
      Response response = Response(json.encode({}), 500);
      try {
        api.throwProperAPIException(response);
        fail("Auth exception not thrown");
      } catch (e) {
        expect(true, e is APIServerError);
      }
    });

    test("Testing getResponseAttribute", () {
      APIHelper api = new APIHelper();
      Map testMap = {
        'value1': 10,
        'value2': [1, 2, 3],
        'value3': {
          '1': 'a',
          '2': 'b',
        },
      };
      Response response = Response(json.encode(testMap), 200);
      expect(api.getResponseAttribute(response, 'value1'), testMap['value1']);
      expect(api.getResponseAttribute(response, 'value2'), testMap['value2']);
      expect(api.getResponseAttribute(response, 'value3'), testMap['value3']);
    });
    test("Testing getUrl", () {
      APIHelper api = new APIHelper();
      String expectedURL = "${APIHelper.scheme}://${APIHelper.address}:${APIHelper.port}/api/auth/signup/";
      expect(api.getURL("signup"), expectedURL);
    });
    test("Testing requestSuccessful bad request", () {
      APIHelper api = new APIHelper();
      Response response = Response(json.encode({}), 400);
      bool succeeded = api.requestSuccessful(response);
      expect(succeeded, false);
    });
    test("Testing requestSuccessful good request", () {
      APIHelper api = new APIHelper();
      Response response = Response(json.encode({}), 200);
      bool succeeded = api.requestSuccessful(response);
      expect(succeeded, true);
    });
  });

  group('Testing APIAuth', () {
    AuthUser user;
    setUp(() {
      user = new AuthUser.testing(mockBox);
      user.setPassword(userMap['password']);
      user.loadFromHive();
    });

    test("Testing signup request valid token", () async {
      final api = APIAuth(user);
      api.helper.client = MockClient((request) async {
        final mapJson = {
          'detail': 'Please check your email for a verification link'
        };
        return Response(json.encode(mapJson), 200);
      });
      bool successful = await api.signup();
      expect(successful, true);
    });

    test("Testing signup request invalid token", () async {
      final api = APIAuth(user);
      api.helper.client = MockClient((request) async {
        final mapJson = {'detail': 'Invalid info was sent'};
        return Response(json.encode(mapJson), 403);
      });
      bool successful = await api.signup();
      expect(successful, false);
    });
    test("Testing login valid", () async {
      final api = APIAuth(user);
      api.helper.client = MockClient((request) async {
        final mapJson = {'token': userMap['API_KEY']};
        return Response(json.encode(mapJson), 200);
      });
      bool successful = await api.login();
      expect(successful, true);
    });

    test("Testing login invalid server error", () async {
      when(mockBox.get("API_KEY")).thenReturn(null);

      final api = APIAuth(user);
      api.helper.client = MockClient((request) async {
        final mapJson = {'detail': 'A server error occurred'};
        return Response(json.encode(mapJson), 500);
      });
      bool successful = await api.login();
      expect(successful, false);
    });

    test("Testing login null attribute", () async {
      when(mockBox.get("API_KEY")).thenReturn(null);
      user.setPassword(null);

      final api = APIAuth(user);
      bool successful = await api.login();
      expect(successful, false);
    });

    test("Testing already logged in", () async {
      when(mockBox.get("API_KEY")).thenReturn("somekey");

      final api = APIAuth(user);
      bool successful = await api.login();
      expect(successful, true);
    });
  });
}
