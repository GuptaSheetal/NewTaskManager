import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:new_task_manager/screens/auth_screens/login_screen/login_screen.dart';
import 'package:new_task_manager/screens/home_screen/sub_screens/view_individual_task.dart';
import 'package:new_task_manager/services/auth_services/auth_services.dart';
import 'package:new_task_manager/services/database_services/task_services.dart';
import 'package:new_task_manager/services/database_services/user_services.dart';

import '../../models/task.dart';

class RootHomeScreen extends StatefulWidget {
  final String uid;
  const RootHomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<RootHomeScreen> createState() => _RootHomeScreenState();
}

class _RootHomeScreenState extends State<RootHomeScreen> {
  AuthServices _authServices = AuthServices();

  UserServices _userServices = UserServices();
  TaskDatabaseServices _taskDatabaseServices = TaskDatabaseServices();

  final List<Map<String, dynamic>> _taskData = [];
  final TextEditingController _taskNameController = TextEditingController();

  var _userDataStream;
  var _taskDataStream;

  Future<void> _getUserData() async {
    await _userServices.getUserData(widget.uid).then((value) {
      setState(() {
        _userDataStream = value;
      });
    });
  }

  Future<void> _getAllTasksData() async {
    await _taskDatabaseServices.getAllTasks(widget.uid).then((value) {
      setState(() {
        _taskDataStream = value;
      });
    });
  }

  Future<void> _addTaskDataToDatabase(String uid, Task task) async {
    await _taskDatabaseServices.addTaskToDatabase(uid, task);
  }

  Future<void> _deleteTask(String taskId, String uid) async {
    await _taskDatabaseServices.deleteTaskData(uid, taskId);
  }

  Future<void> _addTask() async {
    return showModalBottomSheet(
        context: context,
        isScrollControlled:
            true, // when we click on edit text keybord will appear and that rectangular box will scroll up a little
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add A Task",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          CircleAvatar(
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); //on clicking the rectangular box should close
                                  _taskNameController
                                      .clear(); // and the edit text should be clear
                                },
                                icon: const Icon(Icons.close)),
                          )
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 15)),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: TextField(
                        controller: _taskNameController,
                        decoration:
                            const InputDecoration(hintText: "Enter Task Name")),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _taskNameController.clear();
                            },
                            child: const Text("CANCEL")),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(
                            onPressed: () async {
                              DateTime dateTime = DateTime.now();
                              String taskName =
                                  _taskNameController.text.toString().trim();
                              String dateOfUpload =
                                  DateFormat("dd/MM/yyyy").format(dateTime);
                              String timeOfUpload =
                                  DateFormat("hh:mm").format(dateTime);
                              int uploadMilliSecond =
                                  dateTime.millisecondsSinceEpoch;
                              // print('The Milisecond is: $uploadMilliSecond');
                              String taskId = uploadMilliSecond.toString();
                              // print('\nThe Task Id is: $taskId');
                              Task task = Task(
                                  taskId: taskId,
                                  taskName: taskName,
                                  dateOfUpload: dateOfUpload,
                                  timeOfUpload: timeOfUpload,
                                  uploadMilliSecond: uploadMilliSecond);
                              String uid = widget.uid;

                              await _addTaskDataToDatabase(uid, task);

                              Navigator.of(context).pop();
                              _taskNameController.clear();
                            },
                            child: const Text("SUBMIT")),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  )
                ],
              ),
            ),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20))),
            width: MediaQuery.of(context).size.width,
            height: 300 + MediaQuery.of(context).viewInsets.bottom,
          );
        });
  }

  Future<void> _logOut() async {
    await _authServices.logOut();
    Fluttertoast.showToast(msg: "Logged out successfully");
    Timer(Duration(milliseconds: 350), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
    _getAllTasksData();
    // _addTask();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _addTask();
              },
              icon: Icon(Icons.add, color: Colors.white)),
          IconButton(
              onPressed: () async {
                await _logOut();
              },
              icon: Icon(Icons.exit_to_app, color: Colors.white))
        ],
        title: StreamBuilder(
            stream: _userDataStream,
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              return Text(
                snapshot == null
                    ? ""
                    : snapshot.data == null
                        ? ""
                        : "Hello ${(snapshot.data!.data() as Map<String, dynamic>)["userName"]}",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              );
            }),
      ),
      body: StreamBuilder(
          stream: _taskDataStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return snapshot == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : snapshot.data == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : snapshot.data!.docs.length == 0
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, size: screenWidth / 5.175),
                              SizedBox(
                                height: screenWidth / 27.6,
                              ),
                              Text(
                                "No Task Added Yet",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: screenWidth / 27.6,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ))
                        : ListView(
                            children: List.generate(
                              snapshot.data!.docs.length,
                              (index) => IndividualTaskBuilder(
                                screenWidth: screenWidth,
                                taskDate: (snapshot.data!.docs[index].data()
                                    as Map)["dateOfUpload"],
                                taskName: (snapshot.data!.docs[index].data()
                                    as Map)["taskName"],
                                taskTime: (snapshot.data!.docs[index].data()
                                    as Map)["timeOfUpload"],
                                onDeletePressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isDismissible: false,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20))),
                                      builder: (context) {
                                        return Container(
                                            child: Column(
                                              children: [
                                                Expanded(child: Container()),
                                                Container(
                                                  child: Text(
                                                    "Are you sure\nYou want to delete this task?",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30)))),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("No")),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    ElevatedButton(
                                                        style: ButtonStyle(
                                                            shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30)))),
                                                        onPressed: () async {
                                                          String taskId = (snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .data()
                                                              as Map)["taskId"];
                                                          await _deleteTask(
                                                              taskId,
                                                              widget.uid);

                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Task deleted successfully");
                                                          Timer(
                                                              Duration(
                                                                  milliseconds:
                                                                      350), () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        child: Text("Yes")),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                ),
                                                Expanded(
                                                    child: Container(),
                                                    flex: 2),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20))),
                                            height: 250,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width);
                                      });
                                },
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ViewIndividualTask()));
                                },
                                index: index,
                              ),
                            ),
                          );
          }),
    );
  }
}

class IndividualTaskBuilder extends StatelessWidget {
  const IndividualTaskBuilder({
    Key? key,
    required this.screenWidth,
    required this.taskName,
    required this.taskDate,
    required this.taskTime,
    required this.onPressed,
    required this.onDeletePressed,
    required this.index,
  }) : super(key: key);

  final double screenWidth;
  final int index;
  final String taskName, taskDate, taskTime;
  final VoidCallback onPressed, onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  leading: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.assignment,
                      color: Colors.black,
                      size: screenWidth / 17.25,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.25))
                        ],
                        borderRadius:
                            BorderRadius.circular(screenWidth / 10.35)),
                    height: screenWidth / 10.35,
                    width: screenWidth / 10.35,
                  ),
                  trailing: GestureDetector(
                    onTap: onDeletePressed,
                    child: Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.delete,
                        color: Colors.black,
                        size: screenWidth / 17.25,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 4),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.25))
                          ],
                          borderRadius:
                              BorderRadius.circular(screenWidth / 10.35)),
                      height: screenWidth / 10.35,
                      width: screenWidth / 10.35,
                    ),
                  ),
                  title: Text("Task Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 27.6)),
                  subtitle: Text(
                    "$taskName",
                    style: TextStyle(fontSize: screenWidth / 31.85),
                  )),
              ListTile(
                  leading: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: screenWidth / 17.25,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.25))
                        ],
                        borderRadius:
                            BorderRadius.circular(screenWidth / 10.35)),
                    height: screenWidth / 10.35,
                    width: screenWidth / 10.35,
                  ),
                  title: Text("Task Date",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 27.6)),
                  subtitle: Text(
                    "$taskDate",
                    style: TextStyle(fontSize: screenWidth / 31.85),
                  )),
              ListTile(
                  leading: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.watch,
                      color: Colors.black,
                      size: screenWidth / 17.25,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.25))
                        ],
                        borderRadius:
                            BorderRadius.circular(screenWidth / 10.35)),
                    height: screenWidth / 10.35,
                    width: screenWidth / 10.35,
                  ),
                  title: Text("Task Time",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth / 27.6)),
                  subtitle: Text(
                    "$taskTime",
                    style: TextStyle(fontSize: screenWidth / 31.85),
                  ))
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.25))
            ],
            borderRadius: BorderRadius.circular(screenWidth / 41.4),
          ),
          width: screenWidth,
          margin: EdgeInsets.only(
              left: screenWidth / 20.7,
              right: screenWidth / 20.7,
              bottom: screenWidth / 20.7,
              top: index == 0 ? screenWidth / 20.7 : 0)),
    );
  }
}
