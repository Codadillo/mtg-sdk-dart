import 'package:test/test.dart';
import '../lib/mtg_sdk_dart.dart';

void main() {
  test("set.find() should return the set of the given id.", () async {
    dynamic set_find = await set.find("MIR");
    expect(set_find["name"], equals("Mirage"));
    expect(set_find["border"], equals("black"));
  });

  test("set.where() should return sets of the given properties.", () async {
    dynamic where_general = await set.where({"type": "un"});
    expect(where_general.first["name"], equals("Unstable"));
    expect(where_general.first["border"], equals("silver"));
    expect(where_general.length, equals(3));
  });

  test("set.where() should be able to control the page number and size", () async {
    dynamic where_page = await set.where({"page": "4", "pageSize": "2"});
    expect(where_page.first["name"], equals("Super Series"));
    expect(where_page.first["border"], equals("black"));
    expect(where_page.length, equals(2));
  });
}