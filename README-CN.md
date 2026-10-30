# json2model [![Pub Version](https://img.shields.io/pub/v/json2model)](https://pub.dev/packages/json2model)

[English](https://github.com/venshine/json2model/blob/main/README.md) | 简体中文

在代码中执行命令，根据 JSON 字符串生成对应的 Dart 模型类。
[https://pub.dev/packages/json2model](https://pub.dev/packages/json2model)

## 用法

简单示例：

```dart
import 'package:json2model/json2model.dart';

void main() {
  run(['--src=example/json', '--dst=example/lib/models']);
}
```

## 功能
| 功能                       | 状态     |
| :----                     |     ---: |
| 空安全（null safety）        |       ✅ |
| toJson 和 fromJson          |       ✅ |
| encoder 和 decoder          |       ✅ |
| 所有属性为 final             |       ✅ |
| 所有属性可选                 |       ✅ |

## 问题反馈

功能建议和 bug 请提交到 [issue 列表][tracker]。

[tracker]: https://github.com/venshine/json2model/issues

## 关于
[venshine.cn@gmail.com](venshine.cn@gmail.com)

## 许可证
[BSD 3-clause](https://opensource.org/license/bsd-3-clause/)
