import 'package:test/test.dart';
import '../lib/mtg_sdk.dart';

void main() {
  test("set.find() should return the set of the given id.", () async {
    var setFind = await sets.find("MIR");
    expect(setFind["name"], equals("Mirage"));
    expect(setFind["border"], equals("black"));
  });

  test("set.where() should return sets of the given properties.", () async {
    var whereGeneral = await sets.where({"type": "un"});
    expect(whereGeneral.first["name"], equals("Unstable"));
    expect(whereGeneral.first["border"], equals("silver"));
    expect(whereGeneral.length, equals(3));
  });
}