import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/util/Navigation.dart';
import 'background.dart';

class CompanyEmployeeList extends StatelessWidget {
  CompanyEmployeeListBloc _bloc;
  BuildContext context;
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    init(context);
    return Background(child: _listViewEmployeeList());
  }

  void init(BuildContext context) {
    this.context = context;
    controller.addListener(_scrollListener);
    _bloc = BlocProvider.of<CompanyEmployeeListBloc>(context);
    _bloc.getSiteList();
    _bloc.getFirstEmployeeList();
    listenErrorMessage();
  }

  void listenErrorMessage() {
    _bloc.errorMessage.stream.listen((event) {
      Navigation().showToast(context, event);
    });
  }

  Widget _listViewEmployeeList() {
    return StreamBuilder(
        stream: _bloc.employeeList,
        builder: (context, AsyncSnapshot<List<Employee>> snapshot) {
          var employeeList =
              snapshot.hasData ? snapshot.data : new List<Employee>();
          return ListView.builder(
              controller: controller,
              itemCount: employeeList.length,
              itemBuilder: (BuildContext ctxt, int index) {
                var employee = employeeList[index];
                return Card(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _textView(employee.employeeName,
                                icon: Icons.person),
                            _textView(employee.employeeId,
                                icon: Icons.credit_card),
                            if (employee.mobileNumber != null)
                              _textView(employee.mobileNumber,
                                  icon: Icons.phone),
                          ],
                        )));
              });
        });
  }

  Widget _textView(String content, {IconData icon}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Row(
          children: [
            Icon(icon),
            _sizeBox(width: 10),
            Text(content),
          ],
        ));
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      print("at the end of list");
      _bloc.getNextEmployeeList();
    }
  }

  Widget _sizeBox({double width = 0, double height = 0}) {
    return SizedBox(width: width, height: height);
  }
}
