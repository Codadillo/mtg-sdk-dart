from mtgsdk import Card

print(Card.where(set='ktk').where(subtypes='warrior,human').all())