import 'package:test/test.dart';
import '../lib/src/querybuilder.dart';

void main() {
  test("card.find() should return the card of the given id.", () async {
    dynamic teferis_imp = await card.find(3369);
    expect(teferis_imp["name"], equals("Teferi's Imp"));
    expect(teferis_imp["manaCost"], equals("{2}{U}"));
    expect(teferis_imp["cmc"], equals(3));
    expect(teferis_imp["colors"], equals(["Blue"]));
    expect(teferis_imp["type"], equals("Creature — Imp"));
    expect(teferis_imp["rarity"], equals("Rare"));
    expect(teferis_imp["set"], equals("MIR"));
    expect(teferis_imp["text"], contains("Whenever Teferi's Imp phases in, draw a card."));
    expect(teferis_imp["artist"], equals("Una Fricker"));
    expect(teferis_imp["flavor"], equals("Made you look."));
  });

  test("card.where() should return the cards of the given properties.", () async {
    dynamic where_general_test = await card.where({"set": "MIR", "colors": ["blue", "black"]});
    where_general_test.forEach((c) => expect(c["colors"], equals(["Blue", "Black"])));
    where_general_test.forEach((c) => expect(c["set"], equals("MIR")));
    expect(where_general_test.length, equals(5));
  });

  test("card.where() should be able to control the page number and size", () async {
    dynamic where_page_test = await card.where({"set": "MIR", "page": 2, "pageSize": 54});
    expect(where_page_test.first["name"], equals("Forbidden Crypt"));
    expect(where_page_test.last["name"], equals("Merfolk Raiders"));
    expect(where_page_test.length, equals(54));
    expect(where_page_test.runtimeType.toString(), equals("List"));
  });
}
