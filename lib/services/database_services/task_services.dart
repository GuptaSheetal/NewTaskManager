import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_manager/models/task.dart';

class TaskDatabaseServices {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // add task to database
  // User => uid => Task => taskId => taskData

  Future<void> addTaskToDatabase(String uid, Task task) async {
    String taskId = task.taskId;
    String taskName = task.taskName;
    String dateOfUpload = task.dateOfUpload;
    String timeOfUpload = task.timeOfUpload;
    int uploadMilliSecond = task.uploadMilliSecond;

  Map<String, dynamic> data = {
    "taskId": taskId,
    "taskName": taskName,
    "dateOfUpload": dateOfUpload,
    "timeOfUpload": timeOfUpload,
    "uploadMilliSecond": uploadMilliSecond
  };

  await _firebaseFirestore.collection("Users").doc(uid).collection("Tasks").doc(taskId).set(data);
  }

  // view individual task
  // User => uid => Task => taskid <= taskData

  Future<Stream<DocumentSnapshot>> getIndividualTask(String uid, String taskId) async {
    return _firebaseFirestore.collection("Users").doc(uid).collection("Tasks").doc(taskId).snapshots();
  }

  // view all tasks
  // User => uid => Task <= getAlltasks
  Future<Stream<QuerySnapshot>> getAllTasks(String uid) async {
    return _firebaseFirestore.collection("Users").doc(uid).collection("Tasks").orderBy("uploadMilliSecond", descending: true).snapshots();
  }

  // update task
  // User => uid => Task => taskId => updatedata
  Future<void> updateTaskData(String uid, String taskId, Map<String, dynamic> taskData) async {
    await _firebaseFirestore.collection("Users").doc(uid).collection("Tasks").doc(taskId).update(taskData);
  }

  // delete task
  // User => uid => Task => taskId => deleteTask

  Future<void> deleteTaskData(String uid, String taskId) async {
    await _firebaseFirestore.collection("Users").doc(uid).collection("Tasks").doc(taskId).delete();
  }

}