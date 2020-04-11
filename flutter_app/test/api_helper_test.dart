import 'package:flutter_app/services/api_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'dart:convert';

void main(){
  group('Testing APIHelper', () {
    test("Testing _throwProperAPIException with different status codes", (){});
    test("Testing getResponseAttribute", (){});
    test("Testing getUrl", (){});
    test("Testing requestSuccessful", (){});
  });

  group('Testing APIAuth', () {
    test("Testing signup request", (){});
    test("Testing token request", (){});
  });
}