import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/shared/cubit/cubit.dart';

Widget defaultFormField({
  @required String? text,
  @required IconData? prefix,
  @required TextEditingController? controller,
  bool obsecurt = false,
  TextInputType? type ,
  IconData? suffix,
  FormFieldValidator<String>? validate,
  FormFieldValidator<String>? onChange,
  void Function()? suffixPressed,
  void Function()? onTap,
  FormFieldValidator<String>? onSubmit,
}) => TextFormField(
  onFieldSubmitted: onSubmit ,
  keyboardType: type,
  obscureText: obsecurt,
  controller: controller,
  validator: validate,
  onTap: onTap,
  onChanged: onChange,
  decoration: InputDecoration(
    labelText: text,
    prefixIcon: Icon(
        prefix
    ),
    suffixIcon: suffix != null ? IconButton(
      icon: Icon(suffix),
      onPressed: suffixPressed,

    ) : null,
    border: OutlineInputBorder(),
  ),
);

Widget buildTaskItem(Map model,context) => Dismissible(
  key: Key(model['id'].toString()), // key not useful(ليس له فاىدة)
  child: Padding(

    padding: const EdgeInsets.all(20.0),

    child: Row(

      //crossAxisAlignment: CrossAxisAlignment.start,

      children:

      [

        CircleAvatar(

          radius: 40,

          child: Text(

            '${model['time']}',

          ),

        ),

        SizedBox(

          width: 20,

        ),

        Expanded(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children:

            [

              Text(

                '${model['title']}',

                style: TextStyle(

                  fontSize: 20,

                  fontWeight: FontWeight.bold,

                ),

              ),

              Text(

                '${model['date']}',

                style: TextStyle(

                  color: Colors.grey,

                ),

              ),

            ],

          ),

        ),

        SizedBox(

          width: 20,

        ),

        IconButton(

            onPressed: (){

              AppCubit.get(context).updateData(

                  status: 'done',

                  id: model['id'],

              );

            },

            icon: Icon(

                Icons.check_box,

              color: Colors.green,

            ),

        ),

        IconButton(

          onPressed: (){

            AppCubit.get(context).updateData(

              status: 'archived',

              id: model['id'],

            );

          },

          icon: Icon(

              Icons.archive,

            color: Colors.black45,

          ),

        ),

      ],

    ),

  ),
  onDismissed: (direction){
    AppCubit.get(context).deleteData(
        id: model['id'],
    );
  },
);

Widget tasksBuilder({
  required List<Map> list,
}) => ConditionalBuilder(
  condition: list.length > 0,
  builder: (context) => ListView.separated(
    itemBuilder: (context,index) => buildTaskItem(list[index],context),
    separatorBuilder: (context,index) => Padding(
      padding: const EdgeInsetsDirectional.only(
          start: 20
      ),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[300],
      ),
    ),
    itemCount: list.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
      [
        Icon(
          Icons.menu,
          size: 100,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, Please Add Some Tasks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
);