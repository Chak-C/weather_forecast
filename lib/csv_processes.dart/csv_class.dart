
import 'dart:typed_data';

class LoadedCSV  {
  List<List<dynamic>> currentCSV;

  LoadedCSV({
    required this.currentCSV
  });

  /// Retrieve all rows with the section attribute provided.
  /// 
  /// Returns: List<dynamic>
  List<dynamic> getColumn(int sectionIndex, int skip) {

    List<dynamic> extractedRows = [];

    for (int i = skip; i < currentCSV.length - 1; i++) {
      List<dynamic> row = currentCSV[i];
      if (row.length > sectionIndex) {
        extractedRows.add(row[sectionIndex]);
      } else {
        extractedRows.add(null);
      }
    }

    return extractedRows;
  }

  int length() {
    return currentCSV.length;
  }

  /// Create and return a sample csv environment
  LoadedCSV _testSetup() {
    List<List<dynamic>> temp = [
      ['ID', 'Section', 'Name', 'Description', 'Synonym', 'Format'],
      [0, 'Origin', '', 'Genesis of the material, inspiration of the content', '', ''],
      [0, 'Position', '', '90%', '', ''],
      [0, 'Hair', '', 'Fairly generic', '', ''],
      [0, 'Tags', '', 'The fun part', '', ''],
      [0, 'Safe', '', 'Well... If you say so.', '', ''],
      [1, 'Origin', 'Azur', 'Existing', '', 'AE'],
      [2, 'Origin', 'Genshin', 'Gain', '', 'AE'],
    ];

    return LoadedCSV(currentCSV: temp);
  }
}

Float32List convertToFloat32(List<dynamic> dynamicList) {
  List<double> doubleList = dynamicList.map((dynamic element) {
    return double.parse(element.toString());
  }).toList();

  return Float32List.fromList(doubleList);
}

dynamic convertToDouble(List<dynamic> dynamicList) {
  return dynamicList.map((value) => double.parse(value)).toList();
}