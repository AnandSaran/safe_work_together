import 'dart:io';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/ImageConstants.dart';
import 'package:safe_work_together/constants/NavigatorConstants.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/util/Navigation.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'background.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;
import 'package:safe_work_together/extension/company_extension.dart';

class Body extends StatelessWidget {
  final FirebaseUserRepository firebaseUserRepository =
      FirebaseUserRepository();

  final FocusNode _mobileNumberFocus = FocusNode();
  final FocusNode _employeeIdFocus = FocusNode();

  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('65');

  EmployeeLoginBloc _bloc;
  BuildContext context;

  String _otp = "";
  double _dropdownButtonWidth;
  double _mobileNumberWidth;
  Size size;

  @override
  Widget build(BuildContext context) {
    init(context);

    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _textTitle(),
              _sizeBox(height: size.height * 0.01),
              _imageLogo(),
              _sizeBox(height: size.height * 0.02),
              _textSelectCompany(),
              _editTextEmployeeId(),
              _rowMobileNumberView(),
              _buttonSubmit(),
              _textBottomNavigation(),
            ]),
      ),
    );
  }

  Widget _textTitle() {
    return Text(
      APP_NAME,
      style: TextStyle(color: Colors.black, fontSize: 25),
    );
  }

  Widget _imageLogo() {
    return WebsafeSvg.asset(
      ICON_LOGIN_PAGE_LOGO,
      width: size.width * (kIsWeb ? 0.3 : 0.7),
    );
  }

  Widget _sizeBox({double width = 0, double height = 0}) {
    return SizedBox(width: width, height: height);
  }

  Widget _textSelectCompany() {
    return StreamBuilder(
        stream: _bloc.company,
        builder: (context, AsyncSnapshot<Company> snapshot) {
          String companyTitle = snapshot.hasData
              ? snapshot.data.compoundName
              : LOGIN_SELECT_COMPANY;
          return InkWell(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: new Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    companyTitle,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            onTap: () {
              _dialogCompanyList();
            },
          );
        });
  }

  Widget _editTextEmployeeId() {
    return StreamBuilder(
        stream: _bloc.employeeId,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: TextFormField(
              focusNode: _employeeIdFocus,
              onChanged: (licenceNumber) {
                _bloc.changeEmployeeId(licenceNumber);
              },
              onFieldSubmitted: (term) {
                FocusScope.of(context).requestFocus(_mobileNumberFocus);
              },
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

  Widget _rowMobileNumberView() {
    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _textSelectCountry(),
          _editTextMobileNumber(),
        ]);
  }

  Widget _textBottomNavigation() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Text(
          LOGIN_BOTTOM_NAVIGATION_CONTENT,
          style: TextStyle(
            color: Colors.purple,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      onTap: () {
        Navigation().pushPage(context, ROUTE_LOGIN_COMPANY, isToReplace: false);
      },
    );
  }

  Widget _textSelectCountry() {
    return SizedBox(
        width: _dropdownButtonWidth,
        child: ListTile(
          onTap: _dialogCountryPicker,
          title: _textSelectedCountry(),
        ));
  }

  Widget _textSelectedCountry() {
    return StreamBuilder(
        stream: _bloc.countryCode,
        builder: (context, AsyncSnapshot<Country> snapshot) {
          Country country =
              snapshot.hasData ? snapshot.data : _selectedDialogCountry;
          return Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
            child: OutlineButton(
              onPressed: () {
                _dialogCountryPicker();
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Row(
                  children: <Widget>[
                    CountryPickerUtils.getDefaultFlagImage(country),
                    SizedBox(width: 8.0),
                    Text("+${country.phoneCode}"),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _dialogCountryPicker() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          titlePadding: EdgeInsets.all(8.0),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration: InputDecoration(hintText: HINT_SEARCH),
          isSearchable: true,
          title: Text(ERROR_COUNTRY_CODE),
          onValuePicked: (Country country) => _bloc.changeCountryCode(country),
          itemBuilder: _dialogCountryPickerItem,
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('SG'),
            CountryPickerUtils.getCountryByIsoCode('IN'),
          ],
        ),
      );

  Widget _dialogCountryPickerItem(Country country) => Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 16.0),
          Flexible(child: Text(country.name))
        ],
      ));

  Widget _editTextMobileNumber() {
    return StreamBuilder(
        stream: _bloc.mobileNumber,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: SizedBox(
                width: _mobileNumberWidth,
                child: TextFormField(
                  focusNode: _mobileNumberFocus,
                  textInputAction: TextInputAction.done,
                  onChanged: (mobileNumber) {
                    _bloc.changeMobileNumber(mobileNumber);
                  },
                  onFieldSubmitted: (term) {
                    _bloc.generateOtp();
                  },
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                      errorText: snapshot.error,
                      labelText: LOGIN_INPUT_PASSWORD_HINT,
                      border: OutlineInputBorder()),
                )),
          );
        });
  }

  Widget _buttonSubmit() {
    return StreamBuilder(
        stream: _bloc.progressButtonState,
        builder: (context, progressButtonState) {
          return StreamBuilder(
            stream: _bloc.isOtpVerified,
            builder: (context, snapshot) {
              bool isOtpVerified = snapshot.hasData ? snapshot.data : false;
              if (isOtpVerified && !progressButtonState.hasData) {
                onClickLoginFormSubmit(isOtpVerified);
              }
              return Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: ProgressButton.icon(
                      iconedButtons: {
                        ButtonState.idle: IconedButton(
                            text: isOtpVerified
                                ? ACTION_SUBMIT
                                : ACTION_VERIFY_MOBILE,
                            icon:
                                Icon(Icons.send, color: Theme.Colors.iconColor),
                            color: Theme.Colors.buttonColorIdle),
                        ButtonState.loading: IconedButton(
                            text: ACTION_LOADING,
                            color: Theme.Colors.buttonColorLoading),
                        ButtonState.fail: IconedButton(
                            text: ACTION_FAILED,
                            icon: Icon(Icons.cancel,
                                color: Theme.Colors.iconColor),
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
                        onClickLoginFormSubmit(isOtpVerified);
                      },
                      state: progressButtonState.hasData
                          ? progressButtonState.data
                          : ButtonState.idle));
            },
          );
        });
  }

  void _dialogCompanyList() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
            title: new Text(TITTLE_SELECT_COMPANY),
            content: Container(
              width: 300.0,
              child: _listViewCompanyList(),
            ));
      },
    );
  }

  Widget _listViewCompanyList() {
    return StreamBuilder(
        stream: _bloc.companyList,
        builder: (context, AsyncSnapshot<List<Company>> snapshot) {
          var companyList =
              snapshot.hasData ? snapshot.data : new List<Company>();
          return ListView.separated(
              itemCount: companyList.length,
              shrinkWrap: true,
              separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
              itemBuilder: (BuildContext ctxt, int index) {
                var company = companyList[index];
                return InkWell(
                    onTap: () {
                      onTapCompany(company);
                    },
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _textView(company.compoundName),
                          ],
                        )));
              });
        });
  }

  Widget _textView(String content) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(content),
    );
  }

  _dialogOtp() {
    _bloc.resetOtp();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return /*WillPopScope(
            onWillPop: () {},
            child: */
            AlertDialog(
                title: new Text(TITLE_VERIFY),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _editTextOtp(),
                      _buttonOtpSubmit(),
                    ],
                  ),
                ));
        /* ));*/
      },
    );
  }

  Widget _editTextOtp() {
    return StreamBuilder(
        stream: _bloc.otp,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              onChanged: (otp) {
                _otp = otp;
              },
              maxLines: 1,
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  errorText: snapshot.error,
                  errorMaxLines: 10,
                  labelText: HINT_ENTER_OTP,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _buttonOtpSubmit() {
    return RaisedButton(
      onPressed: () => {onClickOtpSubmit()},
      color: Theme.Colors.buttonColorIdle,
      child: new Text(ACTION_SUBMIT,
          style: TextStyle(
            color: Theme.Colors.whiteColor,
            fontSize: 15,
          )),
    );
  }

  void init(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      _bloc = BlocProvider.of<EmployeeLoginBloc>(context);
      _bloc.changeCountryCode(_selectedDialogCountry);
      _bloc.getCompanyList();
      listenIsShowOtpDialog();
      listenFirebaseAuth();
      listenLoginSuccess();
      listenErrorMessage();

      size = MediaQuery.of(context).size;
      double totalWidth = size.width;
      _dropdownButtonWidth = MediaQuery.of(context).size.width * 0.4;
      double paddingRight = 20;
      _mobileNumberWidth = totalWidth - _dropdownButtonWidth - paddingRight;
    }
  }

  onClickOtpSubmit() {
    _bloc.changeOtp(_otp);
    if (_bloc.validateOtpForm()) {
      _bloc.verifyOtp();
    }
  }

  listenIsShowOtpDialog() {
    _bloc.isShowOtpDialog.stream.listen((event) {
      if (event) {
        _dialogOtp();
      }
    });
  }

  void listenFirebaseAuth() {
    _bloc.isOtpVerified.stream.listen((event) {
      if (event) {
        Navigation().pop(context);
      }
    });
  }

  void listenLoginSuccess() {
    _bloc.logInSuccess.stream.listen((event) {
      if (event) {
        Navigation().pushPage(context, ROUTE_EMPLOYEE_HOME, isUntil: true);
      } else {
        _bloc.showToast(context, ERROR_MESSAGE);
        _bloc.changeProgressButtonState(ButtonState.fail);
      }
    });
  }

  void listenErrorMessage() {
    _bloc.errorMessage.stream.listen((event) {
      _bloc.showToast(context, event);
    });
  }

  void onClickLoginFormSubmit(bool isOtpVerified) {
    isOtpVerified ? _bloc.validateLoginForm() : _bloc.generateOtp();
  }

  void onTapCompany(Company company) {
    Navigation().pop(context);
    _bloc.changeCompany(company);
  }
}
