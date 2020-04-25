
import 'package:flutter_app/models/interaction.dart';
import 'package:flutter_app/services/caching.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

class FakeBox extends Fake implements Box {
  get isOpen => true;

}

class FakeCachedClass extends CachedClass {
  int intTest;
  String stringTest;
  String uuidTest;
  bool boolTest;
  double doubleTest;
  dynamic tossupTest;
  Function tossupValidator;

  FakeCachedClass() {
    this.intTest = 1;
    this.stringTest = "testString";
    this.uuidTest = "f6c48913-028e-44ae-b7b7-843c4e2dc23a";
    this.boolTest = false;
    this.doubleTest = 3.1415;
    this._loadValidators();
  }

  Map<String, dynamic> toCacheFormat() {
    Map<String, dynamic> attributes = {
      'intTest': this.intTest,
      'stringTest': this.stringTest,
      'uuidTest': this.uuidTest,
      'boolTest': this.boolTest,
      'doubleTest': this.doubleTest,
      'tossupTest': this.tossupTest,
    };
    
    return attributes; 
  }
  CachedClass fromCacheFormat(Map<String, dynamic> fromCache) {
    this.intTest = fromCache['intTest'];
    this.stringTest = fromCache['stringTest'];
    this.uuidTest = fromCache['uuidTest'];
    this.boolTest = fromCache['boolTest'];
    this.doubleTest = fromCache['doubleTest'];
    this.tossupTest = fromCache['tossupTest'];
  }

  void _loadValidators() {
    Map<String, Function> validators = {
      'intTest': CachedClass.isInt,
      'stringTest': CachedClass.isString,
      'uuidTest': CachedClass.isUUID,
      'boolTest': CachedClass.isBoolean,
      'doubleTest': CachedClass.isDouble,
      'tossupTest': this.tossupValidator,
    };

    this.validators = validators;
  }
}

class InvalidFakeCachedClass extends FakeCachedClass{
  // This is to test that if there is not the same number of field, if enforce=true exception is raised
  @override
  void _loadValidators() {
    Map<String, Function> validators = {
      'intTest': CachedClass.isInt,
    };

    this.validators = validators;
  }
}

void main() {
  FakeCachedClass implementation = new FakeCachedClass();
  
  group('Testing attribute validator CachedClass', () {
    test('Testing ValidatorFieldMismatch when enforce=true', () {
      InvalidFakeCachedClass invalid = new InvalidFakeCachedClass();
      invalid._loadValidators();

      // No error when enforce is false
      invalid.validateFields(enforceSameLength: false);

      try {
        invalid.validateFields(enforceSameLength: true);
        fail("String in int attribute in class but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is ValidatorFieldMismatch);
      }
    });
    
    // Tests that all the fields are valid so then you only need to test if the invalid part works
    test('Testing validateFields (all attributes valid)', () {
      implementation.tossupTest = 1;
      implementation.tossupValidator = CachedClass.isInt;
      implementation._loadValidators();

      // No assertion because it should throw exception if invalid
      implementation.validateFields();      
    });

    test('Testing CachedClass.isInt invalid', () {
      implementation.tossupTest = "A value that should be an int";
      implementation.tossupValidator = CachedClass.isInt;
      implementation._loadValidators();

      try {
        implementation.validateFields();
        fail("String in int attribute in class but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is InvalidField);
      }
    });

    test('Testing CachedClass.isString invalid', () {
      implementation.tossupTest = 123;
      implementation.tossupValidator = CachedClass.isString;
      implementation._loadValidators();

      try {
        implementation.validateFields();
        fail("Int in string field in class but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is InvalidField);
      }
    });

    test('Testing CachedClass.isUUID is invalid', () {
      implementation.tossupTest = 1;
      implementation.tossupValidator = CachedClass.isUUID;
      implementation._loadValidators();

      try {
        implementation.validateFields();
        fail("Int in UUID field in class but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is InvalidField);
      }

      implementation.tossupTest = "A string that is not a uuid";
      implementation._loadValidators();

      try {
        implementation.validateFields();
        fail("String that is not UUID in UUID field but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is InvalidField);
      }
    });

    test('Testing CachedClass.isBool is invalid', () {
      implementation.tossupTest = "Not a boolean";
      implementation.tossupValidator = CachedClass.isBoolean;
      implementation._loadValidators();

      try {
        implementation.validateFields();
        fail("String in boolean field in class but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is InvalidField);
      }
    });

    test('Testing CachedClass.isDouble is invalid', () {
      implementation.tossupTest = "Not a double";
      implementation.tossupValidator = CachedClass.isDouble;
      implementation._loadValidators();

      try {
        implementation.validateFields();
        fail("String in double field but did not cause InvalidField exception");
      } catch (e) {
        expect(true, e is InvalidField);
      }
    });


  });
  
}