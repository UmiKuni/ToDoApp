class Task {
  int? _id;
  late String _title;
  late String _description;
  late String _frequency;
  late String _duedate;

  // Constructor
  Task(this._title, this._description, this._frequency, this._duedate);

  Task.withId(this._id, this._title, this._description, this._frequency, this._duedate);

  Task.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._frequency = map['frequency'];
    this._duedate = map['duedate'];
  }

  // Getters
  int? get id => _id;

  String get title => _title;

  String get description => _description;

  String get frequency => _frequency;

  String get duedate => _duedate;

  // Setters
  set title(String newTitle){
    if(newTitle.length <= 255){
      this._title = newTitle;
    }
  }

  set description(String newDescription){
    if(newDescription.length <= 255){
      this._description = newDescription;
    }
  }

  set frequency(String newFrequency){
    if(newFrequency.length <= 255){
      this._frequency = newFrequency;
    }
  }

  set duedate(String newDueDate){
    if(newDueDate.length <= 255){
      this._duedate = newDueDate;
    }
  }

  // Convert a Task object to Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['frequency'] = _frequency;
    map['duedate'] = _duedate;

    return map;
  }

}