import 'dart:io';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
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
import 'package:safe_work_together/util/Navigation.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'background.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;

class Body extends StatelessWidget {
  final FirebaseUserRepository firebaseUserRepository =
      FirebaseUserRepository();

  final FocusNode _mobileNumberFocus = FocusNode();
  final FocusNode _licenceNumberFocus = FocusNode();

  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('65');

  CompanyLoginBloc _bloc;
  BuildContext context;
  BuildContext dialogContext;

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
              _sizeBox(height: size.height * 0.02),
              _imageLogo(),
              _sizeBox(height: size.height * 0.02),
              _editTextLicenceNumber(),
              _rowMobileNumberView(),
              _sizeBox(height: size.height * 0.02),
              _buttonSubmit(),
              _textBottomNavigation(),
            ]),
      ),
    );
  }

  Widget _imageLogo() {
    return WebsafeSvg.asset(
      ICON_LOGIN_PAGE_LOGO,
      width: size.width * (kIsWeb ? 0.3 : 0.7),
    );
  }

  Widget _textTitle() {
    return Text(
      APP_NAME,
      style: TextStyle(color: Colors.black, fontSize: 25),
    );
  }

  Widget _editTextLicenceNumber() {
    return StreamBuilder(
        stream: _bloc.licenceNumber,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextFormField(
              focusNode: _licenceNumberFocus,
              onChanged: (licenceNumber) {
                _bloc.changeLicenceNumber(licenceNumber);
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
                  labelText: COMPANY_LOGIN_INPUT_USER_ID_HINT,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _textSelectCountry() {
    return SizedBox(
        width: _dropdownButtonWidth,
        child: ListTile(
          onTap: _dialogCountryPicker,
          title: _textSelectedCountry(),
        ));
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
                    _bloc.changeOtpVerified(false);
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

  Widget _textBottomNavigation() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Text(
          COMPANY_LOGIN_BOTTOM_NAVIGATION_CONTENT,
          style: TextStyle(
            color: Colors.purple,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      onTap: () {
        onClickBottomNavigation();
      },
    );
  }

  _dialogOtp() {
    _bloc.resetOtp();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
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
        Navigation().pop(dialogContext);
      }
    });
  }

  void listenLoginSuccess() {
    _bloc.logInSuccess.stream.listen((event) {
      if (event) {
        Navigation().pushPage(context, ROUTE_COMPANY_HOME, isUntil: true);
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

  Widget _sizeBox({double width = 0, double height = 0}) {
    return SizedBox(width: width, height: height);
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

  void onClickLoginFormSubmit(bool isOtpVerified) {
    isOtpVerified ? _bloc.validateLoginForm() : _bloc.generateOtp();
  }

  void onClickBottomNavigation() {
    Navigation().pushPage(
      context,
      ROUTE_COMPANY_REGISTRATION,
    );
  }

  void init(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      _bloc = BlocProvider.of<CompanyLoginBloc>(context);
      _bloc.changeCountryCode(_selectedDialogCountry);
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
}
