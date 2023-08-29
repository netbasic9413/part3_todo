import 'package:fast_app_base/common/cli_common.dart';
import 'package:fast_app_base/common/util/async/flutter_async.dart';
import 'package:fast_app_base/data/memory/todo_status.dart';
import 'package:fast_app_base/data/memory/vo_todo.dart';
import 'package:fast_app_base/screen/dialog/d_confirm.dart';
import 'package:fast_app_base/screen/dialog/d_message.dart';
import 'package:fast_app_base/screen/main/write/d_write_todo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../remote/todo_api.dart';

class TodoData extends GetxController {
  final RxList<Todo> todoList = <Todo>[].obs;

  final todoRepository = TodoApi.instance;

  //final TodoRepository todoRepository = LocalDB.instance;

  @override
  void onInit() async {
    final remoteTodoList = await todoRepository.getTodoList();
    remoteTodoList.runIfSuccess((data) {
      todoList.addAll(data);
    });
    remoteTodoList.runIfFailure((error) {
      delay(() {
        MessageDialog(error.message).show();
      }, 100.ms);
    });
    super.onInit();
  }

  int get newId {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void addTodo(BuildContext context) async {
    final result = await WriteTodoBottomSheet().show();
    result?.runIfSuccess((data) {
      final newTodo = Todo(
        id: newId,
        title: data.title,
        dueDate: data.dueDate,
        createdTime: DateTime.now(),
        status: TodoStatus.incomplete,
      );
      todoList.add(newTodo);
      todoRepository.addTodo(newTodo);
    });
  }

  void changeTodoStatus(Todo todo) async {
     TodoStatus nextStatus = todo.status;
    switch (todo.status) {
      case TodoStatus.complete:
        final result = await ConfirmDialog('다시 처음 상태로 변경하시겠어요?').show();
        if(result?.isFailure == true){
          return;
        }
        result?.runIfSuccess((data) {
          nextStatus = TodoStatus.incomplete;
        });
      case TodoStatus.incomplete:
        nextStatus = TodoStatus.ongoing;
      case TodoStatus.ongoing:
        nextStatus = TodoStatus.complete;
      case TodoStatus.unknown:
        return;
    }

    final result = await todoRepository.updateTodo(todo..status = nextStatus); //객체 안의 status 바꿔서 update요청
    result.runIfSuccess((data) => updateTodo(todo));
    result.runIfFailure((error) => MessageDialog(error.message).show());
  }

  editTodo(Todo todo) async {
    final result = await WriteTodoBottomSheet(todoForEdit: todo).show();
    result?.runIfSuccess((data) {
      todo.modifyTime = DateTime.now();
      todo.title = data.title;
      todo.dueDate = data.dueDate;
    });
    updateTodo(todo);
  }

  void updateTodo(Todo todo) async{

    todoList.refresh();
  }

  void removeTodo(Todo todo) {
    todoList.remove(todo);
    todoRepository.removeTodo(todo.id);
    //LocalDB.removeTodo(todo.id);
  }
}

mixin class TodoDataProvider {
  late final TodoData todoData = Get.find();
}