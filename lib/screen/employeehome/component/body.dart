import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/ImageConstants.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;
import 'package:safe_work_together/util/date_utl.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'background.dart';
import 'package:safe_work_together/extension/employee_extension.dart';
import 'package:safe_work_together/extension/list_site_extension.dart';

class Body extends StatelessWidget {
  BuildContext context;
  EmployeeHomeBloc _bloc;
  Size size;
  final FocusNode _oxygenLevelFocus = FocusNode();
  final FocusNode _heartRateFocus = FocusNode();

  void init(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      _bloc = BlocProvider.of<EmployeeHomeBloc>(this.context);
      _bloc.getEmployee();
      size = MediaQuery.of(context).size;
    }
  }

  @override
  Widget build(BuildContext context) {
    init(context);

    return Background(
        child: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _textViewName(),
                _textViewGreeting(),
                _textViewAssignedSite(),
                _textViewPerDaySubmit(),
                _visibleTemperature(),
                _sizeBox(height: size.height * 0.02),
                _visibleOxygen(),
                _sizeBox(height: size.height * 0.02),
                _visibleHeartRate(),
                _sizeBox(height: size.height * 0.02),
                _visibleCough(),
                _sizeBox(height: size.height * 0.01),
                _visibleSoreThroat(),
                _sizeBox(height: size.height * 0.01),
                _visibleRunningNose(),
                _sizeBox(height: size.height * 0.01),
                _visibleShortnessOfBreath(),
                _sizeBox(height: size.height * 0.01),
                _buttonSubmit(),
              ]),
        )
      ],
    )));
  }

  Widget _textViewName() {
    return StreamBuilder(
        stream: _bloc.employee,
        builder: (context, AsyncSnapshot<Employee> snapshot) {
          var employeeTitle = "";
          if (snapshot.hasData) {
            employeeTitle = snapshot.data.compoundName;
          }
          return Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
                child: Text(employeeTitle,
                    style: TextStyle(
                      color: Theme.Colors.blackColor,
                      fontSize: 30,
                    )),
              ));
        });
  }

  Widget _textViewGreeting() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
          child: Text(DateUtil().generateGreeting(),
              style: TextStyle(
                color: Theme.Colors.blackColor,
                fontSize: 25,
              )),
        ));
  }

  Widget _rowTemperatureView() {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Flexible(
            child: _textInputTrack(
                COMPANY_REGISTRATION_TRACK_TEMPERATURE, ICON_TEMPERATURE),
            flex: 2,
          ),
          new Flexible(
            child: _editTextTemperature(),
            flex: 1,
          ),
        ]);
  }

  Widget _textInputTrack(String track, String icon) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: SizedBox(
                width: 30,
                child: WebsafeSvg.asset(icon, width: 24, height: 24)),
          ),
          TextSpan(
            text: track,
            style: TextStyle(color: Theme.Colors.blackColor, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _textTrack(String track, String icon) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: WebsafeSvg.asset(icon, width: 24, height: 24),
          ),
          WidgetSpan(
            child: _sizeBox(width: 10),
          ),
          TextSpan(
            text: track,
            style: TextStyle(color: Theme.Colors.blackColor, fontSize: 17),
          ),
        ],
      ),
    );
  }

  Widget _editTextTemperature() {
    return StreamBuilder(
        stream: _bloc.temperature,
        builder: (context, AsyncSnapshot<double> snapshot) {
          return SizedBox(
              width: 100,
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                onFieldSubmitted: (term) {
                  if(_bloc.company.value.isToTrackOxygenLevel) {
                    FocusScope.of(context).requestFocus(_oxygenLevelFocus);
                  }else {
                    FocusScope.of(context).requestFocus(_heartRateFocus);
                  }
                },
                onChanged: (text) {
                  _bloc.changeTemperature(double.parse(text));
                },
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  inputFormatDecimal(),
                ],
                decoration: InputDecoration(
                    errorText: snapshot.error,
                    border: OutlineInputBorder(),
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0)),
              ));
        });
  }

  FilteringTextInputFormatter inputFormatDecimal() =>
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

  Widget _rowOxygenView() {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Flexible(
            child: _textInputTrack(
                COMPANY_REGISTRATION_TRACK_OXYGEN_LEVEL, ICON_OXYGEN),
            flex: 2,
          ),
          new Flexible(
            child: _editTextOxygen(),
            flex: 1,
          ),
        ]);
  }

  _editTextOxygen() {
    return StreamBuilder(
        stream: _bloc.oxygen,
        builder: (context, AsyncSnapshot<double> snapshot) {
          return SizedBox(
              width: 100,
              child: TextFormField(
                onFieldSubmitted: (term) {
                  FocusScope.of(context).requestFocus(_heartRateFocus);
                },
                onChanged: (text) {
                  _bloc.changeOxygen(double.parse(text));
                },
                focusNode: _oxygenLevelFocus,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                inputFormatters: [
                  inputFormatDecimal(),
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    errorText: snapshot.error,
                    border: OutlineInputBorder(),
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0)),
              ));
        });
  }

  Widget _rowHeartRateView() {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Flexible(
            child: _textInputTrack(
                COMPANY_REGISTRATION_TRACK_HEART_RATE, ICON_HEART),
            flex: 2,
          ),
          new Flexible(
            child: _editTextHeartRate(),
            flex: 1,
          ),
        ]);
  }

  _editTextHeartRate() {
    return StreamBuilder(
        stream: _bloc.heartRate,
        builder: (context, AsyncSnapshot<double> snapshot) {
          return SizedBox(
              width: 100,
              child: TextFormField(
                inputFormatters: [
                  inputFormatDecimal(),
                ],
                onChanged: (text) {
                  _bloc.changeHeartRate(double.parse(text));
                },
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                focusNode: _heartRateFocus,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    errorText: snapshot.error,
                    border: OutlineInputBorder(),
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0)),
              ));
        });
  }

  _rowTrack(String track, String icon, BehaviorSubject<int> data,
      Function(int p1) changeData) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Flexible(
            child: _textTrack(track, icon),
            flex: 1,
          ),
          new Flexible(
            child: _rowRadioButton(data, changeData),
            flex: 1,
          ),
        ]);
  }

  _rowRadioButton(BehaviorSubject<int> data, Function(int p1) changeData) {
    return StreamBuilder(
        stream: data,
        initialData: 1,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          child:
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              new Radio(
                value: 0,
                groupValue: snapshot.data,
                onChanged: changeData,
              ),
              new Text(
                YES,
                style: new TextStyle(fontSize: 14.0),
              ),
              new Radio(
                value: 1,
                groupValue: snapshot.data,
                onChanged: changeData,
              ),
              new Text(
                NO,
                style: new TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          );
        });
  }

  Widget _sizeBox({double width = 0, double height = 0}) {
    return SizedBox(width: width, height: height);
  }

  Widget _textViewAssignedSite() {
    return StreamBuilder(
        stream: _bloc.employee,
        builder: (context, AsyncSnapshot<Employee> snapshot) {
          var employeeSite = "";
          if (snapshot.hasData) {
            employeeSite = snapshot.data.siteList.generateSiteList;
          }
          return Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 5),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(employeeSite,
                    style: TextStyle(
                      color: Theme.Colors.blackColor,
                      fontSize: 15,
                    )),
              ));
        });
  }

  Widget _textViewPerDaySubmit() {
    return StreamBuilder(
        stream: _bloc.perDaySubmit,
        builder: (context, AsyncSnapshot<int> snapshot) {
          var entryLeftContent = "";
          if (snapshot.hasData) {
            if (snapshot.data == 0) {
              entryLeftContent = ASSIGNED_ENTRY_COMPLETE;
            } else {
              entryLeftContent = snapshot.data.toString() +
                  WHITE_SPACE +
                  ASSIGNED_ENTRY_LEFT_TODAY;
            }
          }
          return Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(entryLeftContent,
                    style: TextStyle(
                      color: Theme.Colors.blackColor,
                      fontSize: 15,
                    )),
              ));
        });
  }

  Widget _buttonSubmit() {
    return StreamBuilder(
      stream: _bloc.progressButtonState,
      builder: (context, progressButtonState) {
        return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                  onClickFormSubmit();
                },
                state: progressButtonState.hasData
                    ? progressButtonState.data
                    : ButtonState.idle));
      },
    );
  }

  void onClickFormSubmit() {
    _bloc.validateForm();
  }

  _visibleTemperature() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackTemperature : false;
          return Visibility(
            child: _rowTemperatureView(),
            visible: isVisible,
          );
        });
  }

  _visibleOxygen() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackOxygenLevel : false;
          return Visibility(
            child: _rowOxygenView(),
            visible: isVisible,
          );
        });
  }

  _visibleHeartRate() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackHeartRate : false;
          return Visibility(
            child: _rowHeartRateView(),
            visible: isVisible,
          );
        });
  }

  _visibleCough() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackCough : false;
          return Visibility(
            child: _rowTrack(COMPANY_REGISTRATION_TRACK_COUGH, ICON_COUGH,
                _bloc.cough, _bloc.changeCough),
            visible: isVisible,
          );
        });
  }

  _visibleSoreThroat() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackSoreThroat : false;
          return Visibility(
            child: _rowTrack(COMPANY_REGISTRATION_TRACK_SORE_THROAT,
                ICON_SORE_THROAT, _bloc.soreThroat, _bloc.changeSoreThroat),
            visible: isVisible,
          );
        });
  }

  _visibleRunningNose() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackRunningNose : false;
          return Visibility(
            child: _rowTrack(COMPANY_REGISTRATION_TRACK_RUNNING_NOSE, ICON_NOSE,
                _bloc.runningNose, _bloc.changeRunningNose),
            visible: isVisible,
          );
        });
  }

  _visibleShortnessOfBreath() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          bool isVisible =
              snapshot.hasData ? snapshot.data.isToTrackRunningNose : false;
          return Visibility(
            child: _rowTrack(
                COMPANY_REGISTRATION_TRACK_SHORTNESS_OF_BREATH,
                ICON_BREATHE,
                _bloc.shortnessOfBreath,
                _bloc.changeShortnessOfBreath),
            visible: isVisible,
          );
        });
  }
}
