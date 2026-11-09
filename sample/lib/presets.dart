/// 预设样例：每个覆盖库的一类能力
class Preset {
  const Preset(this.label, this.className, this.json);

  final String label;
  final String className;
  final String json;
}

const presets = [
  Preset('Object', 'user', '''
{
  "id": 1024,
  "name": "Ada",
  "email": "ada@example.com",
  "verified": true,
  "score": 98.5,
  "tags": ["admin", "writer"],
  "address": {
    "city": "London",
    "zip": "EC1A"
  }
}'''),
  Preset('Array', 'products', '''
[
  {
    "sku": "A-100",
    "title": "Keyboard",
    "price": 49.9,
    "stock": 12,
    "colors": ["black", "white"]
  },
  {
    "sku": "B-200",
    "title": "Mouse",
    "price": 19,
    "stock": 40,
    "colors": ["grey"]
  }
]'''),
  Preset('Nested', 'order', '''
{
  "orderId": "SO-2026-0042",
  "paid": false,
  "customer": {
    "name": "Lin",
    "contact": { "phone": "000-0000", "wechat": null }
  },
  "items": [
    { "name": "Coffee beans", "qty": 2, "unitPrice": 12.5 },
    { "name": "Filter paper", "qty": 1, "unitPrice": 3 }
  ],
  "coupons": []
}'''),
  Preset('Tricky keys', 'item', r'''
{
  "user-name": "venshine",
  "class": "VIP",
  "1st": true,
  "_id": 7,
  "$ref": "#/defs/item",
  "it's": "quoted",
  "price": 10
}'''),
];
