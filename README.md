# json2model [![Pub Version](https://img.shields.io/pub/v/json2model)](https://pub.dev/packages/json2model)
This library generates a model object corresponding to a JSON string by executing commands in code
[https://pub.dev/packages/json2model](https://pub.dev/packages/json2model)

## Usage

A simple usage example:

```dart
import 'package:json2model/json2model.dart';

void main() {
  run(['--src=example/json', '--dst=example/lib/models']);
}
```

## Feature
| Feature                   | Status   |
| :----                     |     ---: |
| null safety               |       ✅ |
| toJson & fromJson         |       ✅ |
| encoder & decoder         |       ✅ |
| all properties final      |       ✅ |
| all properties optional   |       ✅ |

## Bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/venshine/json2model/issues

## About
[venshine.cn@gmail.com](venshine.cn@gmail.com)

## License
[BSD 3-clause](https://opensource.org/license/bsd-3-clause/)
