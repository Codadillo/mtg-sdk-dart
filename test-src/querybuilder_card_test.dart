import 'package:test/test.dart';
import '../lib/mtg_sdk_dart.dart';

void main() {
  test("card.find() should return the card of the given id.", () async {
    dynamic card_find = await card.find(3369);
    expect(card_find["name"], equals("Teferi's Imp"));
    expect(card_find["manaCost"], equals("{2}{U}"));
    expect(card_find["cmc"], equals(3));
    expect(card_find["colors"], equals(["Blue"]));
    expect(card_find["type"], equals("Creature — Imp"));
    expect(card_find["rarity"], equals("Rare"));
    expect(card_find["set"], equals("MIR"));
    expect(card_find["text"], contains("Whenever Teferi's Imp phases in, draw a card."));
    expect(card_find["artist"], equals("Una Fricker"));
    expect(card_find["flavor"], equals("Made you look."));
  });

  test("card.where() should return the cards of the given properties.", () async {
    dynamic where_general = await card.where({"set": "MIR", "colors": ["blue", "black"]});
    where_general.forEach((c) => expect(c["colors"], equals(["Blue", "Black"])));
    where_general.forEach((c) => expect(c["set"], equals("MIR")));
    expect(where_general.length, equals(5));
  });

  test("card.where() should be able to control the page number and size", () async {
    dynamic where_page = await card.where({"set": "MIR", "page": 2, "pageSize": 54});
    expect(where_page.first["name"], equals("Forbidden Crypt"));
    expect(where_page.last["name"], equals("Merfolk Raiders"));
    expect(where_page.length, equals(54));
    expect(where_page.runtimeType.toString(), equals("List"));
  });
}
