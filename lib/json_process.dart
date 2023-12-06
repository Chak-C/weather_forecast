
/// Translates raw json data into csv String
String jsonToCsv(dynamic rawData) {
  final jsonData = rawData['results'].cast<Map<String, dynamic>>();

  if (jsonData.isEmpty) {
    print('Error: json data is empty');
    return '';
  }

  final csvContent = StringBuffer();

  // Extract headers (keys) from the first item in jsonData
  final headers = jsonData.first.keys.toList();
  csvContent.writeln(headers.join(',')); // Write header row

  // Write data rows
  for (final item in jsonData) {
    final row = headers.map((key) {
      final value = item[key].toString().replaceAll(',', ''); // Handle commas in values
      return '"$value"'; // Enclose values in double quotes
    }).join(',');
    csvContent.writeln(row);
  }

  // Return content as String object
  return csvContent.toString();
}