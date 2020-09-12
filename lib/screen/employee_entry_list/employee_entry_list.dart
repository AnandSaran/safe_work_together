import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/ImageConstants.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/util/Navigation.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'background.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/extension/double_extension.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;
class EmployeeEntryList extends StatelessWidget {
  EmployeeEntryListBloc _bloc;
  BuildContext context;
  ScrollController controller = ScrollController();
  List<DropdownMenuItem<Site>> _dropdownSite = List();
  Size size;

  @override
  Widget build(BuildContext context) {
    init(context);

    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          _sizeBox(height: size.height * 0.01),
          dropDownSite(),
          _sizeBox(height: size.height * 0.01),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                _listViewTodayEntryBySite(),
              ]))),
        ]));
  }

  void init(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      size = MediaQuery.of(context).size;
      controller.addListener(_scrollListener);
      _bloc = BlocProvider.of<EmployeeEntryListBloc>(context);
      _bloc.getSiteList();
      buildDropDownMenuItem();
      listenErrorMessage();
    }
  }

  void listenErrorMessage() {
    _bloc.errorMessage.stream.listen((event) {
      Navigation().showToast(context, event);
    });
  }

  Widget _listViewTodayEntryBySite() {
    return StreamBuilder(
        stream: _bloc.todayEntryListOfSite,
        builder: (context, AsyncSnapshot<Map<String, List<Entry>>> snapshot) {
          var entryMap = snapshot.hasData ? snapshot.data : new Map();
          if (entryMap.isEmpty) {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(NO_ENTRY),
            );
          } else {
            List<List<Entry>> allEntryList = entryMap.values.toList();
            return ListView.builder(
                controller: controller,
                shrinkWrap: true,
                itemCount: entryMap.values.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  List<Entry> employeeEntryList = allEntryList[index];
                  print(employeeEntryList[index].employeeName);
                  return StickyHeader(
                      header: Container(
                        height: 50.0,
                        color: Theme.Colors.profileBackgroundColorStart,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          employeeEntryList[index].employeeName,
                          style: const TextStyle(color: Colors.white,fontSize: 16.0),
                        ),
                      ),
                      content: listViewEmployeeTodayEntry(employeeEntryList));
                });
          }
        });
  }

  ListView listViewEmployeeTodayEntry(List<Entry> employeeEntryList) {
    return ListView.builder(
        controller: controller,
        shrinkWrap: true,
        itemCount: employeeEntryList.length,
        itemBuilder: (BuildContext ctxt, int index) {
          Entry entry = employeeEntryList[index];
          return Card(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(children: [
                    if (_bloc.isValidTrackData(entry.temperature))
                      _textView(entry.temperature.getTempSymbol),
                    if (_bloc.isValidTrackData(entry.heartRate))
                      _textView(entry.heartRate.toString(), icon: ICON_HEART),
                    if (_bloc.isValidTrackData(entry.oxygenLevel))
                      _textView(entry.oxygenLevel.toString(),
                          icon: ICON_OXYGEN),
                    if (_bloc.isValidTrackData(entry.cough.toDouble()))
                      _imageIcon(ICON_COUGH, entry.cough),
                    if (_bloc.isValidTrackData(entry.runningNose.toDouble()))
                      _imageIcon(ICON_NOSE, entry.runningNose),
                    if (_bloc.isValidTrackData(entry.soreThroat.toDouble()))
                      _imageIcon(ICON_SORE_THROAT, entry.soreThroat),
                    if (_bloc
                        .isValidTrackData(entry.shortnessOfBreath.toDouble()))
                      _imageIcon(ICON_BREATHE, entry.shortnessOfBreath),
                  ])));
        });
  }

  Widget _textView(String value, {String icon}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Row(
          children: [
            _sizeBox(width: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            _sizeBox(width: 3),
            if (icon != null) WebsafeSvg.asset(icon, width: 20, height: 20),
          ],
        ));
  }

  void buildDropDownMenuItem() {
    for (Site site in _bloc.siteList.value) {
      _dropdownSite.add(
        DropdownMenuItem(
          child: Text(site.name),
          value: site,
          onTap: () {
            _bloc.fetchEntry(site);
          },
        ),
      );
    }
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      print("at the end of list");
    }
  }

  Widget _sizeBox({double width = 0, double height = 0}) {
    return SizedBox(width: width, height: height);
  }

  Widget dropDownSite() {
    return StreamBuilder(
        stream: _bloc.selectedSite,
        builder: (context, AsyncSnapshot<Site> snapshot) {
          return DropdownButton<Site>(
              value: snapshot.data,
              items: _dropdownSite,
              onChanged: (value) {
                if (_bloc.selectedSite.value != value) {
                  _bloc.changeSelectedSite(value);
                }
              });
        });
  }

  _imageIcon(String icon, int value) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: WebsafeSvg.asset(icon,
            width: 24, height: 24, color: _bloc.getTrackColor(value)));
  }
}
