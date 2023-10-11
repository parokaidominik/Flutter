// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, prefer_const_declarations, avoid_unnecessary_containers, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:app_test/Utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

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
  final List<String> roleOptions = ['User', 'Engineer'];


//----------------------EDITABLE DATA TABLE--------------------------

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
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (cell == 'Password') {
              //---------------------PASSWORD---------------------
              return DataCell(
                TextFormField(
                  readOnly: !isEditingEnabled,
                  initialValue: row[cell].toString(),
                  onChanged: (value) {
                    if (isEditingEnabled) {
                      setState(() {
                        row[cell] = value;
                      });
                    }
                  },
                  style: TextStyle(
                color: isEditingEnabled ? null : Colors.grey,
                ),
                ));
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
              //---------------------USER---------------------
              return DataCell(
                Text(
                  row[cell].toString(),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
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

  TextEditingController createUsernameController = TextEditingController();
  TextEditingController createPinController = TextEditingController();
  TextEditingController createRoleController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchDataFromBackend();
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
  // dynamic height calculate
  double dynamicHeight = tableData.isNotEmpty
      ? (tableData.length * (24 + 2 * 15))
      : 400; // Default height

  return Padding(
    padding: EdgeInsets.only(bottom: 20), // Adjust the value as needed
    child: SingleChildScrollView(
      child: Container(
        height: dynamicHeight,
        width: w,
        margin: EdgeInsets.symmetric(horizontal: w! / 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 75,
              child: EditableTable(onDeleteAccount: deleteAccount),
            ),
            Expanded(
              flex: 25,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //----------------------SAVE BUTTON--------------------------
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
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
                            fontSize: 60,
                            color: Color.fromARGB(255, 42, 163, 208),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    //----------------------EDITING BUTTON--------------------------
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditingEnabled = !isEditingEnabled;
                          });
                        },
                        child: Text(
                          isEditingEnabled ? 'Disable Editing' : 'Enable Editing',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    //----------------------USER CREATION BUTTON--------------------------
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          showCreateUserDialog(context);
                        },
                        child: Text(
                          'Create User',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    //----------------------UPLOAD DATABSE BUTTON--------------------------
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          uploadFile();
                        },
                        child: Text(
                          'IMPORT Database',
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                    //----------------------DOWNLOAD DATABASE BUTTON--------------------------
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          _downloadDatabase();
                        },
                        child: Text(
                          'EXPORT Database',
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

//----------------------DOWNLOAD DATABASE--------------------------

void _downloadDatabase() async {
    const url =
        'http://localhost:8080/api/v1/database/download';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error, e.g., show a snackbar or display an error message
      print('Could not launch $url');
    }
  }

  //----------------------UPLOAD DATABASE--------------------------

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'], // Specify the extension of your database file
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      final bytes = file.bytes;
      if (bytes != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://localhost:8080/api/v1/database/replace'), // Update the URL
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'yourfile.db',
            contentType: MediaType('application', 'octet-stream'),
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          // Handle successful file upload, you can update the UI if needed
          print('Database file uploaded successfully');
          // Refresh the site by fetching updated data
          fetchDataFromBackend();
        } else {
          // Handle error, show a snackbar, or display an error message
          print('HTTP Error: ${response.statusCode}');
          print('Response Body: ${response.stream}');
        }
      }
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

//----------------------CREATE ACCOUNT TO BACKEND--------------------------

 Future<void> createAccount() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/account/create'),
        body: jsonEncode({
          'username': createUsernameController.text,
          'pin': createPinController.text,
          'role': createRoleController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful creation
        // You can add custom logic here if needed
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

  //----------------------ACCOUNT CREATOR WINDOW-------------------------

Future<void> showCreateUserDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(child: Text('Create User')),
        content: Container(
          height: 220.0, // Adjust the height as needed
          child: CreateUserForm(
            createAccount: createAccount,
            onCreateUser: () {
              fetchDataFromBackend();
              createUsernameController.clear();
              createPinController.clear();
              createRoleController.clear();
              Navigator.of(context).pop();
            },
            createUsernameController: createUsernameController,
            createPinController: createPinController,
            createRoleController: createRoleController,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

}

//----------------------USER CREATION--------------------------

class CreateUserForm extends StatefulWidget {
  
  final void Function() onCreateUser;
  final Future<void> Function() createAccount;
  final TextEditingController createUsernameController;
  final TextEditingController createPinController;
  final TextEditingController createRoleController;

  CreateUserForm({
    required this.onCreateUser,
    required this.createAccount,
    required this.createUsernameController,
    required this.createPinController,
    required this.createRoleController,
  });

  @override
  _CreateUserFormState createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
 @override
Widget build(BuildContext context) {
  final padding = EdgeInsets.all(8.0); // Adjust the padding as needed
  final height = 50.0; // Adjust the height as needed

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: padding,
        height: height,
        child: TextField(
          controller: widget.createUsernameController,
          decoration: InputDecoration(labelText: 'Username',
          floatingLabelBehavior: FloatingLabelBehavior.never),

        ),
      ),
      Container(
        padding: padding,
        height: height,
        child: TextField(
          controller: widget.createPinController,
          decoration: InputDecoration(labelText: 'Pin',
          floatingLabelBehavior: FloatingLabelBehavior.never),
        ),
      ),
      Container(
        padding: padding,
        height: height,
        child: TextField(
          controller: widget.createRoleController,
          decoration: InputDecoration(labelText: 'Role',
          floatingLabelBehavior: FloatingLabelBehavior.never),
        ),
      ),
      Container(
        padding: padding,
        margin: EdgeInsets.only(top: 10),
        height: height,
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
            await widget.createAccount();
          widget.onCreateUser();
          },
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // Change button color to blue
      ),
      child: Text(
        'Create',
        style: TextStyle(fontSize: 18), // Increase font size
      ),
      ),
      ),
      ),
    ],
  );
}
  
  }