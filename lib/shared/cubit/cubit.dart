import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/shared/cubit/states.dart';

import '../../modules/archives_tasks/archived_screen.dart';
import '../../modules/done_tasks/done_screen.dart';
import '../../modules/new_tasks/new_task_screen.dart';

class AppCubit extends Cubit<AppStates>{

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens =
  [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];
  List<String> titles =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  var isBottomSheet = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheet({
  required bool isShow,
    required IconData icon,
}){
    isBottomSheet = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  void createDatabase()
  {
    openDatabase(
      'todo.db',
      //if todo.db exist execute onOpen(not execute onCreate)
      //if todo.db not exist execute onCreate then onOpen
      version: 1,
      //change version to 2 when update table of database
      //onCreate execute just once
      onCreate: (database,version){
        print('database created');
        database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT,status TEXT)').then((value)
        {
          print('table created');
        }).catchError((error)
        {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database){
        print('database opened');
        getDataFromDatabase(database);
      },
    ).then((value){
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async
  {
     await database.transaction((txn)async{
      txn.rawInsert('INSERT INTO tasks(title, date, time,status) VALUES("$title", "$date", "$time","new")')
          .then((value){
             print('$value inserted successfully');
             emit(AppInsertDatabaseState());

             getDataFromDatabase(database);
      }).catchError((error){
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  void updateData({
  required String status,
    required int id,
})async{
     database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', '$id']).then((value){
          getDataFromDatabase(database);
        emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  })async{
    database.rawDelete('DELETE FROM tasks WHERE id = ?', ['$id']).then((value){
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  void getDataFromDatabase(database){
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
     database.rawQuery('SELECT * FROM tasks').then((value){
       value.forEach((element) {
         if(element['status'] == 'new'){
           newTasks.add(element);
         }else if(element['status'] == 'done'){
           doneTasks.add(element);
         }else{
           archivedTasks.add(element);
         }
       });
       emit(AppGetDatabaseState());
     });

  }

}