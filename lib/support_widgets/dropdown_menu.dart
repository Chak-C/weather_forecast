import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forecast/main.dart';
import 'package:weather_forecast/support_widgets/miscellenous_widget.dart';

/// Combination of SectionSelect and Prefix text using Row widget
/// Used in selection_page
class DropRow extends StatelessWidget {
  const DropRow({
    super.key, 
    this.prefix,
    required this.dropdownNumber
  });

  final String? prefix;
  final int dropdownNumber;

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefix != null)
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '$prefix: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ),
          ),
        SectionSelect(
          initialIndex: selectedIndex,
          listNumber: dropdownNumber
        ),
      ],
    );
  }
}

/// Custom dropdown menu for selecting columns for analysis.
class SectionSelect extends StatefulWidget {
  const SectionSelect({
    super.key,
    required this.initialIndex,
    required this.listNumber
  });

  final int initialIndex;
  final int listNumber;
  
  @override
  State<SectionSelect> createState() => _SectionSelectState();
}

class _SectionSelectState extends State<SectionSelect> {
  var selectedIndex = 0; 
  
  // changes the column selection in dropdown menus
  void changeSelection(AppState appState, int listNumber, int columnIndex) {
    switch(listNumber) {
      case 0:
        appState.citySelected = columnIndex - 1;
      case 1:
        appState.daysSelected = columnIndex - 1;
    }
    
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var colorScheme = Theme.of(context).colorScheme;

    late final List<String> dropdownList;
    
    switch(widget.listNumber) {
      case 0:
        dropdownList = ['Null'] + appState.cities;
      case 1:
        dropdownList = ['Null'] + appState.days.map((days) => days.toString()).toList();
      default:
        '';
    } 

    final GlobalKey<FlashingBoxState> flashingBoxKey = GlobalKey<FlashingBoxState>();

    String selectedHeader = dropdownList[selectedIndex];

    const double width = 250;
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    
    return Row(
      children: [
        SizedBox(
          width: width,
          child: PopupMenuButton(
            initialValue: selectedHeader,
            onSelected: (item) {
              appState.selectionError = false;
              setState(() {
                selectedIndex = dropdownList.indexOf(item);
                changeSelection(appState, widget.listNumber, selectedIndex);
              });
            },
            itemBuilder: (BuildContext context) {
              return dropdownList.map((String item) {
                return PopupMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 16),),
                );
              }).toList();
            },
            child: Stack(
              children: [
                Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3, color: color),
                  color: colorScheme.onPrimary
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedHeader,
                        style: const TextStyle(fontSize: 16,)
                        ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                if(appState.selectionError)
                  Visibility(
                    visible: widget.listNumber == 0 ? appState.citySelected == -1 : appState.daysSelected == -1,
                    child: Positioned(top: 0, right: 0, left: 0, bottom: 0, child: FlashingBox(key: flashingBoxKey, width: 220),)
                  )              
              ],
            ),
          ),
        ),
      ],
    );
  }
}