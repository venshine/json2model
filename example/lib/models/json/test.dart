import 'dart:convert' show json;
        Test testFromJson(String str) => Test.fromJson(json.decode(str));
        String testToJson(Test data) => json.encode(data.toJson());
      
class Test {
  Test({
    this.aListOfInts,
		this.list1
  });
    final List<int>? aListOfInts;
  final List1? list1;

  factory Test.fromJson(Map<String, dynamic> json) => Test(
    aListOfInts: json['aListOfInts'] == null ? null : List<int>.from(json['aListOfInts'].map((x) => x)),
		list1: json['list1'] == null ? null : List1.fromJson(json['list1'])
  );
  
  Map<String, dynamic> toJson() => {
    'aListOfInts': aListOfInts == null ? null : List<dynamic>.from(aListOfInts!.map((x) => x)),
		'list1': list1 == null ? null : list1?.toJson()
  };

}
    

class List1 {
  List1({
    this.list2,
		this.list3,
		this.list4
  });
    final List<bool>? list2;
  final List<dynamic>? list3;
  final dynamic list4;

  factory List1.fromJson(Map<String, dynamic> json) => List1(
    list2: json['list2'] == null ? null : List<bool>.from(json['list2'].map((x) => x)),
		list3: json['list3'] == null ? null : List<dynamic>.from(json['list3'].map((x) => x)),
		list4: json['list4']
  );
  
  Map<String, dynamic> toJson() => {
    'list2': list2 == null ? null : List<dynamic>.from(list2!.map((x) => x)),
		'list3': list3 == null ? null : List<dynamic>.from(list3!.map((x) => x)),
		'list4': list4
  };

}
    