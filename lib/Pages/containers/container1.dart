// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, prefer_const_declarations, avoid_unnecessary_containers, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

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

bool isEditingEnabled = true;

class EditableTable extends StatefulWidget {

  final void Function(int) onDeleteAccount;
  EditableTable({required this.onDeleteAccount});

  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  final double fontSizeForColumns = 24;
  final List<String> roleOptions = ['10', '20', 'User', 'Engineer'];


//----------------------DATA TABLE--------------------------

  @override
  Widget build(BuildContext context) {
    if (tableData.isNotEmpty) {
      return DataTable(
        columns: tableData[0].keys.map((String column) {
          return DataColumn(
            label: Text(
              column == 'accountId'
                  ? 'ID'
                  : (column == 'pin'
                      ? 'Password'
                      : (column == 'username' ? 'Username' : (column == 'role' ? 'Role' : column))),
              style: TextStyle(
                fontSize: column == 'ID' || column == 'Username' || column == 'Password' || column == 'Role'
                    ? fontSizeForColumns
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
        rows: tableData.asMap().entries.map((entry) {
          final Map<String, dynamic> row = entry.value;

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
              } else if (cell == 'Role') {
                //---------------------ROLE---------------------
                return DataCell(
                  Row(
                    children: [
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
                                  row[cell] = value;
                                });
                              }
                            : null,
                      ),

                      //--------------------- DELETE ACCOUNT----------------------
                      Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                        child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: isEditingEnabled
                        ? () {
                          widget.onDeleteAccount(row['ID']);
                      }
                    : null,
                  ),
                ),
              ],
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
        child: Text("No data available"),
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
            child: EditableTable(onDeleteAccount: deleteAccount,),
          ),
          Expanded(
            flex: 25,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //----------------------SAVE BUTTON--------------------------
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
                  //----------------------EDITING BUTTON--------------------------
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditingEnabled = !isEditingEnabled;
                        });
                      },
                        child: Text(
                          isEditingEnabled ? 'Disable Editing' : 'Enable Editing',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

//----------------------SAVE CHANGES--------------------------

void saveChanges() async {
  for (var row in tableData) {
    final int accountId = row['ID'];
    final String username = row['Username'];
    final String pin = row['Password'];
    final String role = row['Role'];

    await updateAccount(accountId, username, pin, role);
  }
}

//---------------------UPDATE ACCOUNT IN BACKEND----------------------------------

Future<void> updateAccount(int accountId, String username, String pin, String role) async {
  final String apiUrl = 'http://localhost:8080/api/v1/account/update'; // Replace with your API endpoint

  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'accountId': accountId,
        'username': username,
        'pin': pin,
        'role': role,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Handle successful update, you can update the UI if needed
      fetchDataFromBackend();
    } else {
      // Handle error, show a snackbar, or display an error message
      print('HTTP Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (error) {
    // Handle exceptions
    print('Error: $error');
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
        'Username': item['username'].toString(),
        'Password': item['pin'].toString(),
        'Role': item['role'].toString(),
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

//----------------------DELETE ACCOUNT FROM BACKEND--------------------------

Future<void> deleteAccount(int accountId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/api/v1/account/delete'),
        body: jsonEncode([accountId]),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful deletion, you can update the UI if needed
        fetchDataFromBackend();
      } else {
        // Handle error, show a snackbar, or display an error message
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
    }
  }
}

class Account {
  final int accountId;
  final String username;
  final String pin;
  final String role;

  Account({
    required this.accountId,
    required this.username,
    required this.pin,
    required this.role,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'],
      username: json['username'],
      pin: json['pin'],
      role: json['role'],
    );
  }
}