import 'package:test/test.dart';
import '../lib/mtg_sdk.dart';

void main() {
  test("cards.find() should return the card of the given id.", () async {
    dynamic cardFind = await cards.find(3369);
    expect(cardFind["name"], equals("Teferi's Imp"));
    expect(cardFind["manaCost"], equals("{2}{U}"));
    expect(cardFind["cmc"], equals(3));
    expect(cardFind["colors"], equals(["Blue"]));
    expect(cardFind["type"], equals("Creature — Imp"));
    expect(cardFind["rarity"], equals("Rare"));
    expect(cardFind["set"], equals("MIR"));
    expect(cardFind["text"], contains("Whenever Teferi's Imp phases in, draw a card."));
    expect(cardFind["artist"], equals("Una Fricker"));
    expect(cardFind["flavor"], equals("Made you look."));
  });

  test("cards.where() should return the cards of the given properties.", () async {
    dynamic whereGeneral = await cards.where({"set": "MIR", "colors": ["blue", "black"]});
    whereGeneral.forEach((c) => expect(c["colors"], equals(["Blue", "Black"])));
    whereGeneral.forEach((c) => expect(c["set"], equals("MIR")));
    expect(whereGeneral.length, equals(5));
  });

  test("cards.where() should be able to control the page number and size", () async {
    dynamic wherePage = await cards.where({"set": "MIR", "page": 2, "pageSize": 54});
    expect(wherePage.first["name"], equals("Forbidden Crypt"));
    expect(wherePage.last["name"], equals("Merfolk Raiders"));
    expect(wherePage.length, equals(54));
    expect(wherePage.runtimeType.toString(), equals("List"));
  });
}
