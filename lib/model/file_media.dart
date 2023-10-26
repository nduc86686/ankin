class FileMedia {
  List<String>? files;

  FileMedia({this.files});

  FileMedia.fromJson(Map<String, dynamic> json) {
    files = json['files'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['files'] = this.files;
    return data;
  }
}
