import 'package:flutter_app/services/api_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:mockito/mockito.dart';


void main() {
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
      String expectedURL = "${APIHelper.domain}api/auth/signup/";
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
    test("Testing signup request", () {

    });
    test("Testing token request", () {});
  });
}
