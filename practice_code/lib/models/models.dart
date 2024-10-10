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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['age'] = this.age;
    data['colour'] = this.colour;
    return data;
  }
}
