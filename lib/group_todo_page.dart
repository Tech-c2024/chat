import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Goal {
  final String task;
  final String note;
  bool complete;
  String? id;

  Goal(
      {required this.task, required this.note, this.complete = false, this.id});

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'note': note,
      'complete': complete,
    };
  }

  // FirestoreからGoalを取得するためのfromMap
  factory Goal.fromMap(Map<String, dynamic> map, String id) {
    return Goal(
      task: map['task'] ?? '',
      note: map['note'] ?? '',
      complete: map['complete'] ?? false,
      id: id,
    );
  }
}

class GroupGoalPage extends StatefulWidget {
  final String groupId;

  const GroupGoalPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupGoalPageState createState() => _GroupGoalPageState();
}

class _GroupGoalPageState extends State<GroupGoalPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  // Firestoreから目標リストを取得する
  Future<List<Goal>> _getGoals() async {
    try {
      QuerySnapshot goalSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('goals')
          .get();

      List<Goal> goals = goalSnapshot.docs.map((doc) {
        return Goal.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return goals;
    } catch (e) {
      print('エラー: $e');
      return [];
    }
  }

  // Firestoreに目標を追加
  Future<void> _addGoal() async {
    if (_taskController.text.isEmpty || _noteController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Goal newGoal = Goal(
        task: _taskController.text,
        note: _noteController.text,
      );

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('goals')
          .add(newGoal.toMap());

      newGoal.id = docRef.id;

      _taskController.clear();
      _noteController.clear();
    } catch (e) {
      print('エラー: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double systemBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight =
        (MediaQuery.of(context).size.height - systemBarHeight) * 0.05;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          color: Colors.white,
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              '目標リスト',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: '目標',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'メモ',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _addGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.black, width: 0.5),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('目標を追加'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Goal>>(
                future: _getGoals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('目標がありません'));
                  }

                  List<Goal> goals = snapshot.data!;

                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      Goal goal = goals[index];
                      return ListTile(
                        title: Text(goal.task),
                        subtitle: Text(goal.note),
                        trailing: Icon(
                          goal.complete
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        onTap: () {
                          // 目標の完了状態を更新
                          setState(() {
                            goal.complete = !goal.complete;
                          });

                          FirebaseFirestore.instance
                              .collection('groups')
                              .doc(widget.groupId)
                              .collection('goals')
                              .doc(goal.id)
                              .update({'complete': goal.complete});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
