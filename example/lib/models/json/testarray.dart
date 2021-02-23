import 'dart:convert' show json;
        List<Testarray> testarrayFromJson(String str) => List<Testarray>.from(json.decode(str).map((x) => Testarray.fromJson(x)));
        String testarrayToJson(List<Testarray> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
      
class Testarray {
  Testarray({
    this.md5,
		this.height,
		this.width,
		this.type,
		this.format,
		this.url
  });
    final String md5;
  final String height;
  final String width;
  final String type;
  final List<Format> format;
  final String url;

  factory Testarray.fromJson(Map<String, dynamic> json) => Testarray(
    md5: json['md5'],
		height: json['height'],
		width: json['width'],
		type: json['type'],
		format: json['format'] == null ? null : List<Format>.from(json['format'].map((x) => Format.fromJson(x))),
		url: json['url']
  );
  
  Map<String, dynamic> toJson() => {
    'md5': md5,
		'height': height,
		'width': width,
		'type': type,
		'format': format == null ? null : List<dynamic>.from(format.map((x) => x.toJson())),
		'url': url
  };

}
    

class Format {
  Format({
    this.type,
		this.name
  });
    final String type;
  final String name;

  factory Format.fromJson(Map<String, dynamic> json) => Format(
    type: json['type'],
		name: json['name']
  );
  
  Map<String, dynamic> toJson() => {
    'type': type,
		'name': name
  };

}
    