import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_pickers/country.dart' as CountryEntity;
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/NavigatorConstants.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/src/model/site.dart';
import 'package:safe_work_together/util/Navigation.dart';
import 'background.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;
import 'package:safe_work_together/extension/int_extension.dart';

class Body extends StatelessWidget {
  final FirebaseUserRepository firebaseUserRepository =
      FirebaseUserRepository();

  final FocusNode _licenceNumberFocus = FocusNode();
  final FocusNode _mobileNumberFocus = FocusNode();
  final FocusNode _perDayEntryFocus = FocusNode();
  CountryEntity.Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('65');

  CompanyRegisterBloc _bloc;
  BuildContext context;
  BuildContext dialogContext;

  String _otp = "";

  void init(BuildContext context) {
    if(this.context==null) {
      this.context = context;
      _bloc = BlocProvider.of<CompanyRegisterBloc>(context);
      _bloc.changeCountryCode(_selectedDialogCountry);
      _bloc.changeToTrackTemperature(true);
      _bloc.changeToTrackHeartRate(true);
      _bloc.changeToTrackOxygenLevel(true);
      _bloc.changeToTrackCough(true);
      _bloc.changeToTrackRunningNose(true);
      _bloc.changeToTrackSoreThroat(true);
      _bloc.changeToTrackShortnessOfBreath(true);
      listenIsShowOtpDialog();
      listenFirebaseAuth();
      listenCompanyCreated();
      listenErrorMessage();
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
              _textSelectCountry(),
              _editTextCompanyName(),
              _editTextLicenceNumber(),
              _editTextMobileNumber(),
              _textMobileNumberHint(),
              _textUploadDocument(),
              _textWhatToTrack(),
              _checkBoxTrackTemperature(),
              _checkBoxTrackHearRate(),
              _checkBoxTrackOxygenLevel(),
              _checkBoxTrackCough(),
              _checkBoxTrackRunningNose(),
              _checkBoxTrackSoreThroat(),
              _checkBoxTrackShortnessOfBreath(),
              _buttonCreateSite(),
              _listViewSiteList(),
              _buttonSubmit(),
            ]),
      ),
    );
  }

  Widget _buttonSubmit() {
    return StreamBuilder(
        stream: _bloc.progressButtonState,
        builder: (context, progressButtonState) {
          return StreamBuilder(
            stream: _bloc.isOtpVerified,
            builder: (context, snapshot) {
              bool isOtpVerified = snapshot.hasData ? snapshot.data : false;
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
                        isOtpVerified
                            ? _bloc.validateRegistrationForm()
                            : _bloc.generateOtp();
                      },
                      state: progressButtonState.hasData
                          ? progressButtonState.data
                          : ButtonState.idle));
            },
          );
        });
  }

  Widget _checkBoxTrackShortnessOfBreath() {
    return StreamBuilder(
        stream: _bloc.isToTrackShortnessOfBreath,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_SHORTNESS_OF_BREATH),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateShortnessOfBreath(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Widget _checkBoxTrackSoreThroat() {
    return StreamBuilder(
        stream: _bloc.isToTrackSoreThroat,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_SORE_THROAT),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateSoreThroat(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Widget _checkBoxTrackRunningNose() {
    return StreamBuilder(
        stream: _bloc.isToTrackRunningNose,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_RUNNING_NOSE),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateRunningNose(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Widget _checkBoxTrackCough() {
    return StreamBuilder(
        stream: _bloc.isToTrackCough,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_COUGH),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateCough(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Widget _checkBoxTrackOxygenLevel() {
    return StreamBuilder(
        stream: _bloc.isToTrackOxygenLevel,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_OXYGEN_LEVEL),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateOxygenLevel(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Widget _checkBoxTrackHearRate() {
    return StreamBuilder(
        stream: _bloc.isToTrackHeartRate,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_HEART_RATE),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateHeartRate(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Widget _checkBoxTrackTemperature() {
    return StreamBuilder(
        stream: _bloc.isToTrackTemperature,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: CheckboxListTile(
              title: Text(COMPANY_REGISTRATION_TRACK_TEMPERATURE),
              value: getTrackValue(snapshot),
              onChanged: (isChecked) {
                updateTemperature(isChecked);
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
          );
        });
  }

  Padding _textWhatToTrack() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Card(
            child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
          child: Text(COMPANY_REGISTRATION_TO_TRACK,
              style: TextStyle(
                color: Theme.Colors.blackColor,
                fontSize: 18,
              )),
        )));
  }

  Widget _textUploadDocument() {
    return StreamBuilder(
        stream: _bloc.documentUrl,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Column(
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: OutlineButton(
                        onPressed: () {
                          getImage();
                        },
                        disabledBorderColor: Colors.grey,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Text(
                            COMPANY_REGISTRATION_DOCUMENT_HINT,
                            style: TextStyle(
                              color: snapshot.hasError
                                  ? Theme.Colors.redColor
                                  : Theme.Colors.blackColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  ]),
              Visibility(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                  child: Card(
                    child: CachedNetworkImage(
                      height: 200.00,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      imageUrl: snapshot.hasData ? snapshot.data : "",
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: snapshot.hasData,
              ),
            ],
          );
        });
  }

  Widget _editTextMobileNumber() {
    return StreamBuilder(
        stream: _bloc.mobileNumber,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: TextFormField(
              focusNode: _mobileNumberFocus,
              textInputAction: TextInputAction.done,
              onChanged: (mobileNumber) {
                _bloc.changeMobileNumber(mobileNumber);
              },
              onFieldSubmitted: (term) {
                if (_bloc.isOtpVerified.hasValue && !_bloc.isOtpVerified.value) {
                  _bloc.generateOtp();
                }
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
            ),
          );
        });
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
    return ListTile(
      onTap: _dialogCountryPicker,
      title: _textSelectedCountry(),
    );
  }

  Widget _textSelectedCountry() {
    return StreamBuilder(
        stream: _bloc.countryCode,
        builder: (context, AsyncSnapshot<CountryEntity.Country> snapshot) {
          CountryEntity.Country country =
              snapshot.hasData ? snapshot.data : _selectedDialogCountry;
          return Padding(
            padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
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
                    SizedBox(width: 8.0),
                    Flexible(child: Text(country.name))
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _dialogCountryPicker() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          titlePadding: EdgeInsets.all(8.0),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration: InputDecoration(hintText: HINT_SEARCH),
          isSearchable: true,
          title: Text(ERROR_COUNTRY_CODE),
          onValuePicked: (CountryEntity.Country country) => _bloc.changeCountryCode(country),
          itemBuilder: _dialogCountryPickerItem,
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('SG'),
            CountryPickerUtils.getCountryByIsoCode('IN'),
          ],
        ),
      );

  Widget _dialogCountryPickerItem(CountryEntity.Country country) => Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 16.0),
          Flexible(child: Text(country.name))
        ],
      ));

  Widget _editTextCompanyName() {
    return StreamBuilder(
        stream: _bloc.companyName,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: TextFormField(
              onChanged: (companyName) {
                _bloc.changeCompanyName(companyName);
              },
              onFieldSubmitted: (term) {
                FocusScope.of(context).requestFocus(_licenceNumberFocus);
              },
              textInputAction: TextInputAction.next,
              maxLines: 1,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  errorText: snapshot.error,
                  labelText: COMPANY_REGISTRATION_INPUT_NAME_HINT,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _textMobileNumberHint() {
    return Padding(
      padding: EdgeInsets.fromLTRB(25, 2, 20, 0),
      child: Text(
        COMPANY_REGISTRATION_INPUT_PASSWORD_BOTTOM_HINT,
        style: TextStyle(
          color: Theme.Colors.buttonColorSuccess,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buttonCreateSite() {
    return Padding(
        padding: EdgeInsets.fromLTRB(25, 10, 20, 0),
        child: Card(
          child: FlatButton(
            onPressed: () {
              _dialogCreateSite(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  COMPANY_REGISTRATION_CREATE_SITE,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.Colors.blackColor,
                  ),
                ),
                Icon(
                  Icons.add,
                  color: Theme.Colors.blackColor,
                )
              ],
            ),
          ),
        ));
  }

  void _dialogCreateSite(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: new Text(COMPANY_REGISTRATION_CREATE_SITE),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _editTextSiteName(),
                _editTextPerDayEntry(),
                _buttonSiteSubmit(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _editTextSiteName() {
    return StreamBuilder(
        stream: _bloc.siteName,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              onChanged: (siteName) {
                _bloc.changeSiteName(siteName);
              },
              onFieldSubmitted: (term) {
                FocusScope.of(context).requestFocus(_perDayEntryFocus);
              },
              textCapitalization: TextCapitalization.words,
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  errorText: snapshot.error,
                  labelText: SITE_NAME,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _editTextPerDayEntry() {
    return StreamBuilder(
        stream: _bloc.perDayEntry,
        builder: (context, AsyncSnapshot<int> snapshot) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: TextFormField(
              focusNode: _perDayEntryFocus,
              textInputAction: TextInputAction.done,
              onChanged: (perDayEntry) {
                _bloc.changePerDayEntry(int.parse(perDayEntry));
              },
              maxLines: 1,
              maxLength: 1,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  errorText: snapshot.error,
                  labelText: EMPLOYEE_PER_DAY_ENTRY,
                  border: OutlineInputBorder()),
            ),
          );
        });
  }

  Widget _buttonSiteSubmit() {
    return RaisedButton(
      onPressed: () => {onClickSiteSubmit()},
      color: Theme.Colors.buttonColorIdle,
      child: new Text(ACTION_SUBMIT,
          style: TextStyle(
            color: Theme.Colors.whiteColor,
            fontSize: 15,
          )),
    );
  }

  Widget _listViewSiteList() {
    return StreamBuilder(
        stream: _bloc.siteList,
        builder: (context, AsyncSnapshot<List<Site>> snapshot) {
          return Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data.length : 0,
                  itemBuilder: (context, int index) {
                    final Site _site = snapshot.data[index];
                    return Padding(
                        padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                        child: Card(
                          child: ListTile(
                            title: Text(_site.name,
                                style: TextStyle(
                                  color: Theme.Colors.blackColor,
                                  fontSize: 15,
                                )),
                            subtitle: new Text(_site.perDaySubmit.entryPerDay,
                                style: TextStyle(
                                  color: Theme.Colors.blackColor,
                                  fontSize: 12,
                                )),
                          ),
                        ));
                  }));
        });
  }

  void updateTemperature(bool isChecked) {
    _bloc.changeToTrackTemperature(isChecked);
  }

  void updateHeartRate(bool isChecked) {
    _bloc.changeToTrackHeartRate(isChecked);
  }

  void updateOxygenLevel(bool isChecked) {
    _bloc.changeToTrackOxygenLevel(isChecked);
  }

  void updateCough(bool isChecked) {
    _bloc.changeToTrackCough(isChecked);
  }

  void updateRunningNose(bool isChecked) {
    _bloc.changeToTrackRunningNose(isChecked);
  }

  void updateSoreThroat(bool isChecked) {
    _bloc.changeToTrackSoreThroat(isChecked);
  }

  void updateShortnessOfBreath(bool isChecked) {
    _bloc.changeToTrackShortnessOfBreath(isChecked);
  }

  bool getTrackValue(AsyncSnapshot<bool> isToTrackValue) {
    return isToTrackValue.hasData ? isToTrackValue.data : false;
  }

  getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    _bloc.uploadImage(pickedFile.path);
  }

  onClickSiteSubmit() {
    if (_bloc.validateSite()) {
      _bloc.addSite();
      Navigation().pop(context);
    }
  }

  void listenIsShowOtpDialog() {
    _bloc.isShowOtpDialog.stream.listen((event) {
      if (event) {
        _dialogOtp();
      }
    });
  }

  void _dialogOtp() {
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

  void listenFirebaseAuth() {
    _bloc.isOtpVerified.stream.listen((event) {
      if (event) {
        Navigation().pop(dialogContext);
      }
    });
  }

  void listenCompanyCreated() {
    _bloc.isCompanyCreated.stream.listen((event) {
      if (event) {
        Navigation().pushPage(context, ROUTE_COMPANY_HOME, isUntil: true);
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
}
