import 'package:test/test.dart';
import '../lib/mtg_sdk_dart.dart';

void main() {
  test("set.find() should return the set of the given id.", () async {
    dynamic mirage = await set.find("MIR");
    expect(mirage["name"], equals("Mirage"));
    expect(mirage["border"], equals("black"));
  });

  test("set.where() should return sets of the given properties.", () async {
    dynamic where_general_test = await set.where({"type": "un"});
    expect(where_general_test.first["name"], equals("Unstable"));
    expect(where_general_test.first["border"], equals("silver"));
    expect(where_general_test.length, equals(3));
  });

  test("set.where() should be able to control the page number and size", () async {
    dynamic where_general_test = await set.where({"page": "4", "pageSize": "2"});
    expect(where_general_test.first["name"], equals("Super Series"));
    expect(where_general_test.first["border"], equals("black"));
    expect(where_general_test.length, equals(2));
  });
}