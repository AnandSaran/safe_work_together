import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/src/model/site.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;
import 'package:safe_work_together/util/Navigation.dart';
import 'background.dart';

class CompanyCreateEmployee extends StatelessWidget {
  CompanyCreateEmployeeBloc _bloc;
  final FocusNode _fdEmployeeName = FocusNode();
  BuildContext context;
  final etclrEmployeeId = TextEditingController();
  final etclrEmployeeName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    init(context);

    return Background(
        child: Column(children: <Widget>[
      Expanded(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
            _editTextEmployeeId(),
            _editTextEmployeeName(),
            _textAddSites(),
            _listViewSite(),
          ]))),
      _buttonSubmit(),
    ]));
  }

  void init(BuildContext context) {
    this.context = context;
    _bloc = BlocProvider.of<CompanyCreateEmployeeBloc>(context);
    _bloc.getSiteList();
    listenLoginSuccess();
    listenErrorMessage();
  }

  Widget _editTextEmployeeId() {
    return StreamBuilder(
        stream: _bloc.employeeId,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: TextFormField(
              onChanged: (employeeId) {
                _bloc.changeEmployeeId(employeeId);
              },
              onFieldSubmitted: (term) {
                FocusScope.of(context).requestFocus(_fdEmployeeName);
              },
              controller: etclrEmployeeId,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  errorText: snapshot.error,
                  labelText: LOGIN_INPUT_EMPLOYEE_ID_HINT,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _editTextEmployeeName() {
    return StreamBuilder(
        stream: _bloc.employeeName,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: TextFormField(
              onChanged: (employeeName) {
                _bloc.changeEmployeeName(employeeName);
              },
              focusNode: _fdEmployeeName,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              controller: etclrEmployeeName,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  errorText: snapshot.error,
                  labelText: EMPLOYEE_NAME,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _buttonSubmit() {
    return StreamBuilder(
      stream: _bloc.progressButtonState,
      builder: (context, progressButtonState) {
        return Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: ProgressButton.icon(
                iconedButtons: {
                  ButtonState.idle: IconedButton(
                      text: ACTION_SUBMIT,
                      icon: Icon(Icons.send, color: Theme.Colors.iconColor),
                      color: Theme.Colors.buttonColorIdle),
                  ButtonState.loading: IconedButton(
                      text: ACTION_LOADING,
                      color: Theme.Colors.buttonColorLoading),
                  ButtonState.fail: IconedButton(
                      text: ACTION_FAILED,
                      icon: Icon(Icons.cancel, color: Theme.Colors.iconColor),
                      color: Theme.Colors.buttonColorFail),
                  ButtonState.success: IconedButton(
                      text: ACTION_SUCCESS,
                      icon: Icon(
                        Icons.check_circle,
                        color: Theme.Colors.iconColor,
                      ),
                      color: Theme.Colors.buttonColorSuccess)
                },
                onPressed: () {
                  Navigation().hidKeyPad();
                  _bloc.validateCreateEmployeeForm();
                },
                state: progressButtonState.hasData
                    ? progressButtonState.data
                    : ButtonState.idle));
      },
    );
  }

  void listenLoginSuccess() {
    _bloc.createEmployeeSuccess.stream.listen((event) {
      if (event) {
        etclrEmployeeId.clear();
        etclrEmployeeName.clear();
        _bloc.resetData();
        Navigation().showToast(context, SUCCESS_EMPLOYEE_ADDED);
      } else {
        Navigation().showToast(context, ERROR_MESSAGE);
        _bloc.changeProgressButtonState(ButtonState.fail);
      }
    });
  }

  void listenErrorMessage() {
    _bloc.errorMessage.stream.listen((event) {
      Navigation().showToast(context, event);
    });
  }

  Widget _listViewSite() {
    return StreamBuilder(
        stream: _bloc.siteList,
        builder: (context, AsyncSnapshot<List<Site>> snapshot) {
          var sites = snapshot.hasData ? snapshot.data : new List<Site>();
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sites.length,
              itemBuilder: (BuildContext ctxt, int index) {
                var site = sites[index];
                return Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: new CheckboxListTile(
                      title: new Text(site.name +
                          WHITE_SPACE +
                          HYPHEN +
                          WHITE_SPACE +
                          site.perDaySubmit.toString() +
                          WHITE_SPACE +
                          ENTRY_PER_DAY.toLowerCase()),
                      value: site.isSelected,
                      onChanged: (bool value) {
                        site.isSelected = value;
                        _bloc.changeSiteList(sites);
                      },
                    ));
              });
        });
  }

  Padding _textAddSites() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
        child: Card(
            child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
          child: Text(SELECT_EMPLOYEE_WORKING_SITES,
              style: TextStyle(
                color: Theme.Colors.blackColor,
                fontSize: 15,
              )),
        )));
  }
}
