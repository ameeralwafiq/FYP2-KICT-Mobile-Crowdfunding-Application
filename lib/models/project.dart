class Project {
  String projectId;
  String category;
  int clicked;
  DateTime createdAt;
  String createdBy;
  String description;
  String endDate;
  int goal;
  String imageUrl;
  int progress;
  String startDate;
  String status;
  String title;
  String bank;
  String accountNo;
  int shared;

  // Constructor
  Project(
      {required this.projectId,
      required this.category,
      required this.clicked,
      required this.createdAt,
      required this.createdBy,
      required this.description,
      required this.endDate,
      required this.goal,
      required this.imageUrl,
      required this.progress,
      required this.startDate,
      required this.status,
      required this.title,
      required this.bank,
      required this.accountNo,
      required this.shared});

  // Factory method to create a Project from a JSON map
  factory Project.fromJson(String id, Map<String, dynamic> json) {
    return Project(
        projectId: id,
        category: json['category'] as String,
        clicked: json['clicked'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        createdBy: json['createdBy'] as String,
        description: json['description'] as String,
        endDate: json['endDate'] as String,
        goal: json['goal'] as int,
        imageUrl: json['imageUrl'] as String,
        progress: json['progress'] as int,
        startDate: json['startDate'] as String,
        status: json['status'] as String,
        title: json['title'] as String,
        bank: json['bank'] as String,
        accountNo: json['accountNo'] as String,
        shared: json['shared'] as int);
  }

  // Method to convert a Project object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'clicked': clicked,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'description': description,
      'endDate': endDate,
      'goal': goal,
      'imageUrl': imageUrl,
      'progress': progress,
      'startDate': startDate,
      'status': status,
      'title': title,
      'bank': bank,
      'accountNo': accountNo,
      'shared': shared
    };
  }
}
