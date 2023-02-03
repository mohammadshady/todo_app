import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/done_tasks/done_screen.dart';
import 'package:todoapp/modules/new_tasks/new_task_screen.dart';
import 'package:todoapp/shared/components/component.dart';
import 'package:todoapp/shared/cubit/states.dart';

import '../modules/archives_tasks/archived_screen.dart';
import '../shared/components/constants.dart';
import '../shared/cubit/cubit.dart';

class HomeLayout extends StatelessWidget
{


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (context,state){
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        },
        builder: (context,state){
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState, //tasks.length > 0,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if(cubit.isBottomSheet){
                  if(formKey.currentState!.validate()){
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                    );
                    // insertToDatabase(
                    //   title: titleController.text,
                    //   time: timeController.text,
                    //   date: dateController.text,
                    // ).then((value){
                    //   getDataFromDatabase(database).then((value){
                    //     Navigator.pop(context);
                    //     // setState(() {
                    //     //   fabIcon = Icons.edit;
                    //     //   isBottomSheet = false;
                    //     //   tasks = value;
                    //     // });
                    //   });
                    // });

                  }

                }
                else{
                  scaffoldKey.currentState?.showBottomSheet((context) =>
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              defaultFormField(
                                text: 'Task Title',
                                type: TextInputType.text,
                                prefix: Icons.title,
                                controller: titleController,
                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              defaultFormField(
                                text: 'Task Time',
                                type: TextInputType.datetime,
                                prefix: Icons.watch_later_outlined,
                                controller: timeController,
                                onTap: (){
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value){
                                    timeController.text = value!.format(context).toString();
                                  });
                                },
                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'Time must not be empty';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              defaultFormField(
                                text: 'Task Date',
                                type: TextInputType.datetime,
                                prefix: Icons.calendar_today,
                                controller: dateController,
                                onTap: (){
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2023-06-30'),
                                  ).then((value) {
                                    dateController.text = DateFormat.yMMMd().format(value!);
                                  });
                                },
                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'Date must not be empty';
                                  }
                                  return null;
                                },
                              ),

                            ],
                          ),
                        ),
                      ),
                      elevation: 20
                  ).closed.then((value){
                    cubit.changeBottomSheet(
                        isShow: false,
                        icon: Icons.edit,
                    );
                  });
                  cubit.changeBottomSheet(
                    isShow: true,
                    icon: Icons.add,
                  );
                }

              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeIndex(index);
              },
              items: const
              [
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu) ,
                    label: 'Tasks'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline) ,
                    label: 'Done'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined) ,
                    label: 'Archived'
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}


///  set state -> done re-build
// Future<String> getName() async {
//   return 'mohammad';
// }
/// in before example (async) means that this method run in background not in main
/// when call this method must use (await) and (async)  before calling
/// any method find in await must use (async) in header
/// throw('error') -> this statement make error
/// in try,catch (لا نضمن تنفيذ الجمل بالترتيب)
/// to solve this
/// any method future when calling use .then().catchError()
/// in this solution not use async,await
/// in try,catch must use async,await
/// use async,await == use .then().catchError()
/// ...
/// sqflite -> local database
/// 1- create database
/// 2- create tables
/// 3- open database
/// 4- insert to database
/// 5- get from database
/// 6- update in database
/// 7- delete from database
/// ...
/// if you need toggle between 2 thing use bool var
/// if you need toggle between more than 2 thing use list
/// ...
/// use formKey to done validate

  
  
  