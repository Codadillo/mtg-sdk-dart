import 'package:test/test.dart';
import '../lib/mtg_sdk.dart';

void main() {
  test("set.find() should return the set of the given id.", () async {
    dynamic setFind = await sets.find("MIR");
    expect(setFind["name"], equals("Mirage"));
    expect(setFind["border"], equals("black"));
  });

  test("set.where() should return sets of the given properties.", () async {
    dynamic whereGeneral = await sets.where({"type": "un"});
    expect(whereGeneral.first["name"], equals("Unstable"));
    expect(whereGeneral.first["border"], equals("silver"));
    expect(whereGeneral.length, equals(3));
  });

  test("set.where() should be able to control the page number and size", () async {
    dynamic wherePage = await sets.where({"page": "4", "pageSize": "2"});
    expect(wherePage.first["name"], equals("Super Series"));
    expect(wherePage.first["border"], equals("black"));
    expect(wherePage.length, equals(2));
  });
}