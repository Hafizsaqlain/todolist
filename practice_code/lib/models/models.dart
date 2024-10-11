class Task {
  String? sId;
  String? name;
  String? age;
  String? colour;

  Task({this.sId, this.name, this.age, this.colour});

  Task.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    age = json['age'];
    colour = json['colour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['age'] = age;
    data['colour'] = colour;
    return data;
  }
}
