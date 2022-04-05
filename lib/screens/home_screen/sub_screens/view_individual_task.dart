import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_task_manager/constants/constants.dart';
import 'package:new_task_manager/services/database_services/task_services.dart';

class ViewIndividualTask extends StatefulWidget {
  final String uid, taskId;
  const ViewIndividualTask({Key? key, required this.uid, required this.taskId})
      : super(key: key);

  @override
  State<ViewIndividualTask> createState() => _ViewIndividualTaskState();
}

class _ViewIndividualTaskState extends State<ViewIndividualTask> {
  TaskDatabaseServices _taskDatabaseServices = TaskDatabaseServices();

  var _taskDataStream;

  TextEditingController _taskNameController = TextEditingController();

  Future<void> _updateTaskData(Map<String, dynamic> taskData) async {
    await _taskDatabaseServices.updateTaskData(
        widget.uid, widget.taskId, taskData);
  }

  Future<void> _updateTask(String previousTaskName) async {
    _taskNameController.text = previousTaskName;
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
                            "Update Task Name",
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
                              if (_taskNameController.text
                                  .toString()
                                  .trim()
                                  .isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "Task Name should not be empty");
                              } else {
                                String taskName =
                                    _taskNameController.text.toString().trim();

                                Map<String, dynamic> taskData = {
                                  "taskName": taskName
                                };

                                await _updateTaskData(taskData);

                                Fluttertoast.showToast(
                                    msg: "Task Name updated successfully");

                                Navigator.of(context).pop();
                                _taskNameController.clear();
                              }
                            },
                            child: const Text("UPDATE")),
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

  Future<void> _getIndividualTaskData() async {
    await _taskDatabaseServices
        .getIndividualTask(widget.uid, widget.taskId)
        .then((value) {
      setState(() {
        _taskDataStream = value;
      });
    });
  }

  Future<void> _deleteTask() async {
    await _taskDatabaseServices.deleteTaskData(widget.uid, widget.taskId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getIndividualTaskData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    barrierColor: primaryColor,
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
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 15),
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
                                        Navigator.of(context).pop();
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
                                        await _deleteTask();

                                        Fluttertoast.showToast(
                                            msg: "Task deleted successfully");
                                        Timer(Duration(milliseconds: 350), () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text("Yes")),
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                              Expanded(child: Container(), flex: 2),
                            ],
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          height: 250,
                          width: MediaQuery.of(context).size.width);
                    });
              },
              icon: Icon(Icons.delete, color: Colors.white)),
        ],
        title: Text(
          "Task Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
          stream: _taskDataStream,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            return snapshot == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : snapshot.data == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // SizedBox(
                            //   height: screenWidth / 16.56,
                            //   width: screenWidth,
                            // ),
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
                                            color:
                                                Colors.black.withOpacity(0.25))
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          screenWidth / 10.35)),
                                  height: screenWidth / 10.35,
                                  width: screenWidth / 10.35,
                                ),
                                trailing: IconButton(
                                    onPressed: () async {
                                      String previousTaskName =
                                          "${(snapshot.data!.data() as Map)["taskName"]}";
                                      await _updateTask(previousTaskName);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                      size: screenWidth / 17.25,
                                    )),
                                title: Text("Task Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth / 27.6)),
                                subtitle: Text(
                                  "${(snapshot.data!.data() as Map)["taskName"]}",
                                  style:
                                      TextStyle(fontSize: screenWidth / 31.85),
                                )),
                            // SizedBox(
                            //   height: screenWidth / 18.81,
                            // ),
                            Divider(
                              height: 0,
                              color: Color(0xFFC4C4C4),
                              indent: screenWidth / 21.79,
                              endIndent: screenWidth / 21.79,
                            ),
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
                                            color:
                                                Colors.black.withOpacity(0.25))
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          screenWidth / 10.35)),
                                  height: screenWidth / 10.35,
                                  width: screenWidth / 10.35,
                                ),
                                title: Text("Task Date",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth / 27.6)),
                                subtitle: Text(
                                  "${(snapshot.data!.data() as Map)["dateOfUpload"]}",
                                  style:
                                      TextStyle(fontSize: screenWidth / 31.85),
                                )),
                            // SizedBox(
                            //   height: screenWidth / 18.81,
                            // ),
                            Divider(
                              height: 0,
                              color: Color(0xFFC4C4C4),
                              indent: screenWidth / 21.79,
                              endIndent: screenWidth / 21.79,
                            ),
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
                                            color:
                                                Colors.black.withOpacity(0.25))
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          screenWidth / 10.35)),
                                  height: screenWidth / 10.35,
                                  width: screenWidth / 10.35,
                                ),
                                title: Text("Task Time",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth / 27.6)),
                                subtitle: Text(
                                  "${(snapshot.data!.data() as Map)["timeOfUpload"]}",
                                  style:
                                      TextStyle(fontSize: screenWidth / 31.85),
                                )),
                            // SizedBox(
                            //   height: screenWidth / 18.81,
                            // ),
                            Divider(
                              height: 0,
                              color: Color(0xFFC4C4C4),
                              indent: screenWidth / 21.79,
                              endIndent: screenWidth / 21.79,
                            )
                          ],
                        ),
                      );
          }),
    );
  }
}
