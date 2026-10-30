## 1.0.0
* init project, This library generates a model object corresponding to a JSON string by executing commands in code 
## 1.0.1
* update LICENSE
## 1.0.2
* Null safety is supported
## 1.1.0
* Support Dart 3: SDK constraint changed to `^3.0.0`, replace discontinued `pedantic` / `effective_dart` with `lints`
* Fix: JSON keys that are not valid Dart identifiers (e.g. `user-name`, `class`, `1st`, `_id`, `it's`) now generate compilable fields, the original key is kept for `fromJson` / `toJson`
* Fix: `double` fields accept integer JSON values (e.g. `10`) instead of throwing a type error
## 1.1.1
* Remove the IDE file `json2model.iml` and the outdated `cmd.sh` from the published package
## 1.1.2
* Add a Chinese README (`README-CN.md`), linked from `README.md`
* Use `repository` and `issue_tracker` in `pubspec.yaml` instead of `homepage`
## 1.1.3
* Add API documentation for `run`, `parse` and the library
* Follow Dart naming conventions in internal code; no API changes
