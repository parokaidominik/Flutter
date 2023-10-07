// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:app_test/Utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Container1 extends StatefulWidget {
  const Container1({Key? key}) : super(key: key);

  @override
  State<Container1> createState() => _Container1State();
}

//----------------------EMPTY DATABASE--------------------------

List<Map<String, dynamic>> tableData = [];

//----------------------EDITABLE TABLE (ID, USERNAME, PASSWORD, ROLE)--------------------------

// Define a bool variable to track the editable state
bool isEditingEnabled = true;

class EditableTable extends StatefulWidget {
  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  final double fontSizeForColumns = 24;
  final List<String> roleOptions = ['10', '20'];

  @override
  Widget build(BuildContext context) {
    // Check if there is at least one row of data
    if (tableData.isNotEmpty) {
      return DataTable(
        columns: tableData[0].keys.map((String column) {
          return DataColumn(
            label: Text(
              column == 'accountId' ? 'ID' : 
                (column == 'pin' ? 'Password' : 
                (column == 'username' ? 'Username' : 
                (column == 'role' ? 'Role' : column))),
              style: TextStyle(
                fontSize: column == 'ID' ||
                        column == 'username' ||
                        column == 'Password' ||
                        column == 'role'
                    ? fontSizeForColumns
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
        rows: tableData.map((Map<String, dynamic> row) {

          //---------------------ID---------------------
          return DataRow(
            cells: row.keys.map((String cell) {
              if (cell == 'ID') {
                return DataCell(
                  Text(
                    row[cell].toString(),
                    style: TextStyle(
                      fontSize: fontSizeForColumns,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (cell == 'role') {

                //---------------------ROLE---------------------
                return DataCell(
                  DropdownButton<String>(
                    value: row[cell].toString(),
                    items: roleOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: isEditingEnabled
                        ? (value) {
                            setState(() {
                              row[cell] = value!;
                            });
                          }
                        : null,
                  ),
                );
              } else {
                //---------------------USER, PASSWORD---------------------
                return DataCell(
                  TextFormField(
                    readOnly: !isEditingEnabled,
                    initialValue: row[cell].toString(), 
                    onChanged: (value) {
                      setState(() {
                        row[cell] = value;
                      });
                    },
                  ),
                );
              }
            }).toList(),
          );
        }).toList(),
      );
    } else {
      return Center(
        child: Text("No data available"), // Display a message when there's no data
      );
    }
  }
}

 //----------------------BUILD--------------------------

class _Container1State extends State<Container1> {
  @override
  void initState() {
    super.initState();
    fetchDataFromBackend(); // First get the data from backend
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: DesktopContainer1(),
      desktop: DesktopContainer1(),
    );
  }

  //----------------------MAIN CONTAINER--------------------------

  Widget DesktopContainer1() {
    return Container(
      height: 400,
      width: w,
      margin: EdgeInsets.symmetric(horizontal: w! / 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 75,
            child: EditableTable(),
          ),
          Expanded(
            flex: 25,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveChanges();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20),
                      backgroundColor: Color.fromARGB(255, 19, 32, 93),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 40,
                        color: Color.fromARGB(255, 42, 163, 208),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Add a button to toggle editing
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditingEnabled = !isEditingEnabled; // Toggle the editable state
                        });
                      },
                        child: Text(
                          isEditingEnabled ? 'Disable Editing' : 'Enable Editing',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

//----------------------SAVE BUTTON--------------------------

void saveChanges() async {
  for (var row in tableData) {
    final int accountId = row['ID']; // Assuming 'ID' is the unique identifier
    final Map<String, dynamic> updatedData = {
      'accountId': accountId, // Include the unique identifier
      'username': row['username'],
      'pin': row['Password'],
      'role': row['role'],
    };

    final String apiUrl = 'http://localhost:8080/api/v1/account/$accountId'; // Construct the API URL

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        body: jsonEncode(updatedData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Data for account $accountId updated successfully.');
      } else {
        // Handle HTTP error status codes
        print('Failed to update data for account $accountId. HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions (e.g., network issues, parsing errors)
      print('Error updating data for account $accountId: $e');
    }
  }
}

//----------------------DATA FETCH FROM BACKEND--------------------------

Future<void> fetchDataFromBackend() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:8080/api/v1/account')); //Change to backend url

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      final List<Map<String, dynamic>> newTableData = jsonData.map((dynamic item) {
       return {
        'ID': item['accountId'] as int,
        'username': item['username'].toString(),
        'Password': item['pin'].toString(),
        'role': item['role'].toString(),
        };
      }).toList();


      setState(() {
        tableData = newTableData;
      });
    } else {
      // Handle HTTP error status codes
      print("HTTP Error: ${response.statusCode}");
    }
  } catch (e) {
    // Handle other exceptions (e.g., network issues, parsing errors)
    print("Error fetching data from the backend: $e");
  }
}
}