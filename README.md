# mtg_sdk

A library for Magic: The Gathering developers working in dart.
It uses the official mtg api endpoint at https://api.magicthegathering.io.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage
There are two main modules in this library for querying: the sets and cards module.
This library is all asynchronous, so familarizing yourself with dart:async at https://api.dartlang.org/stable/1.24.3/dart-async/dart-async-library.html is important.

## cards

### cards.where(Map properties)
cards.where() returns a list of all cards with specefied properties. The cards are represented by a map of all their properties. It takes in one parameter which is a map of all desired properties. Note that in all queries capitilization is unnecessary, but correct capitilization is necessary when accessing the json.
A list of all properties for cards can be found at https://docs.magicthegathering.io/#api_v1cards_list.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  List<Map> stdcounters = await cards.where({"gameFormat": "standard", "legality": "legal", "text": "counter target"});
  stdcounters.forEach((e) => print(e["name"]));
}
```
    OUTPUT:
    Cancel
    Censor
    Essence Scatter
    Reduce
    Disallow
    Metallic Rebuke
    Negate
    Cancel
    ...
Note: There may be different versions of the same card returned (as shown above with cancel).

### cards.find(int id)
cards.find() returns a map of all the properties of the desired card. It takes in one parameter which is the multiverse id of the desired card.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  print(await cards.find(3369)["name"]);
}
```
    OUTPUT:
    Teferi's Imp

### cards.formats(), cards.types(), cards.supertypes(), and cards.subtypes()
cards.formats(), cards.types(), cards.supertypes(), and cards.subtypes() are general informative functions which each return a list of all their respective information.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  print(await cards.formats());
}
```
    OUTPUT:
    [Amonkhet Block, Battle for Zendikar Block, Classic, Commander, Extended, Ice Age Block, Innistrad Block, Invasion Block, Ixalan    Block, Kaladesh Block, Kamigawa Block...
## sets

### sets.where(Map properties)
sets.where() is identical to cards.where(), except it queries all sets. A list of all properties for sets can be found at https://docs.magicthegathering.io/#api_v1sets_list.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  un = await sets.where({"border": "silver"});
  un.foreach((e) => print(e["name"]));
}
```

### sets.find(String id)
sets.find() functions the same as cards.find(), except the parameter required is the three letter set code.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  print(await sets.find("UST")["name"]);
}
```

### sets.generateBooster(String id)
sets.generateBooster() returns a simulated booster pack opening of a desired product. This is returned in the form of a list of all cards in the simulated booster, where each card is a map of its properties. It takes in a single paramater that is a three letter set code.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  hmlpack = await sets.generateBooster("HML");
  hmlpack.foreach((e) => print(e["name"]))
}
```

### Exceptions
If you make a query and there is an error with it, (most commonly no cards found with the specefied parameters), an exception will be thrown.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  await cards.where({"name": "I'maboutto404", "colors": ["blue"], "power": 2});
}
```

    OUTPUT:
    Unhandled exception:
    Exception: Error 404 while querying. 'Not Found' at http://api.magicthegathering.io/v1/cards?&name=I'maboutto404 with search terms:
    {"name": "I'maboutto404", "colors": ["blue"], "power": 2}

If you have a 404 and suspect that there may be a typo, you can call debug404() on the error. debug404() queries for a single card with each parameter alone and returns all parameters that fail.

```dart
import 'package:mtg_sdk/mtg_sdk.dart';
import 'dart:async';

Future<void> main() async {
  try {
    await cards.where({"name": "I'maboutto404", "colors": ["blue"], "power": 2});
  } catch (e) {
    print("Failed properties: ${await e.debug404()}");
  }
}
```

    OUTPUT:
    Failed properties: {name: I'maboutto404}

If you would like to do error handling yourself or simply do not want errors to be thrown, you can do any of the following. Setting exceptions to false is the recommended of the below, considering that you will likely consistently want or not want errors to be thrown.

```dart
sets.exceptions = false;
cards.exceptions = false;
// OR
sets.safe().find("DOM");
cards.safe().where({});
// OR
safeSets.where({});
safeCards.find(3369);
```

## Issues
If you have any issues, you can submit a pull request or raise an issue at https://github.com/Codadillo/mtg-sdk-dart.
