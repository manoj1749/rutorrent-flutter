import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rutorrentflutter/components/task_tile.dart';
import 'dart:convert';

import 'package:rutorrentflutter/models/task.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasksList = [];
  bool loadingTasks;

  String url = 'http://192.168.43.176/rutorrent/plugins/httprpc/action.php';

  _initTasksData() async{
    List<Task> updatedList = [];
    var response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Connection": "keep-alive",
          "Accept-Encoding": "gzip, deflate, br",
          "Accept" : "*/*",
          "Accept-Language" : "en-GB,en-US;q=0.9,en;q=0.8",
          "X-Requested-With": "XMLHttpRequest",
        },
        body: {
          'mode': 'list',
        },
        encoding: Encoding.getByName("utf-8"));
    print(response.statusCode);
    print(response.body);

    var tasksPath = jsonDecode(response.body)['t'];
    for(var hashKey in tasksPath.keys){
      var taskObject = tasksPath[hashKey];
      Task task = Task(hashKey); // new task created
      task.name = taskObject[4];
      task.size = filesize(taskObject[5]);
      task.savePath = taskObject[25];
      print(task.savePath);

      updatedList.add(task);
    }
    setState(() {
      tasksList=updatedList;
      loadingTasks=false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadingTasks=true;
    _initTasksData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.solidMoon),
            onPressed: (){
              Fluttertoast.showToast(msg: "Night mode currently unavailable");
              _initTasksData();
            },
          ),
        ],
      ),
      drawer: Drawer(),
      body: Container(
        child: loadingTasks?
        Center(child: CircularProgressIndicator()):
            ListView.builder(
              itemCount: tasksList.length,
              itemBuilder: (BuildContext context,int index){
                return TaskTile(tasksList[index]);
              },
            )
      ),
    );
  }
}

