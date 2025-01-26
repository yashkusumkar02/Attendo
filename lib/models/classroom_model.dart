class ClassroomModel {
  final String id;
  final String name;
  final String college;
  final String branch;
  final String semester;
  final String year;

  ClassroomModel({
    required this.id,
    required this.name,
    required this.college,
    required this.branch,
    required this.semester,
    required this.year,
  });

  // ✅ Convert Firestore Map to ClassroomModel
  factory ClassroomModel.fromMap(String id, Map<String, dynamic> data) {
    return ClassroomModel(
      id: id,
      name: data["name"] ?? "Unknown",
      college: data["college"] ?? "Unknown",
      branch: data["branch"] ?? "Unknown",
      semester: data["semester"].toString(), // ✅ Ensure it's a String
      year: data["year"].toString(), // ✅ Ensure it's a String
    );
  }

  // ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "college": college,
      "branch": branch,
      "semester": semester,
      "year": year,
    };
  }
}
