
import 'package:flutter_app/models/auth_user.dart';
import 'package:flutter_app/models/interaction.dart';
import 'package:flutter_app/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
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
    Map<String, dynamic> exampleJson = {
      "user": {"username": "someuser", "email": "someuser@email.com"},
      "risk": "0.1230"
    };

    test("Testing fromJson using example", () {
      Profile profile = new Profile.fromJson(exampleJson);
      expect(profile.getUsername(), "someuser");
      expect(profile.getEmail(), "someuser@email.com");
      expect(profile.getRisk(), 0.1230);
    });
  });

  group('Testing Interaction', () {
    Map<String, dynamic> profileJson = {
      "user": {"username": "someuser1", "email": "someuser1@email.com"},
      "risk": "0.1230"
    };
    Map<String, dynamic> profileJson2 = {
      "user": {"username": "someuser2", "email": "someuser2@email.com"},
      "risk": "0.4534"
    };
    Map<String, dynamic> profileJson3 = {
      "user": {"username": "someuser3", "email": "someuser3@email.com"},
      "risk": "0.9063"
    };
    Profile profile1 = Profile.fromJson(profileJson);
    Profile profile2 = Profile.fromJson(profileJson2);
    Profile profile3 = Profile.fromJson(profileJson3);

    DateTime now = DateTime.now();
    String isoDate = now.toIso8601String();

    Map<String, dynamic> interactionJson = {
      "unique_id": "ff111ef4-e2c8-446c-98e6-2c75f1d7b202",
      "meet_time": isoDate,
      "end_time": null,
      "creator": profileJson,
      "participants": [profileJson, profileJson2, profileJson3]
    };

    test("Testing fromJson", () {
      Interaction meeting = new Interaction.fromResponse(interactionJson);
      expect(meeting.getUUID(), "ff111ef4-e2c8-446c-98e6-2c75f1d7b202");
      expect(meeting.getMeetTime(), now);
      expect(meeting.getEndTime(), null);
      expect(meeting.getParticipants(), [profile1, profile2, profile3]);
    });
  });
}
