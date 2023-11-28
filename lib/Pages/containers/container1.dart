// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, prefer_const_declarations, avoid_unnecessary_containers, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:app_test/Pages/Login.dart';
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

class EditableTable extends StatefulWidget {
  final void Function(int) onDeleteAccount;
  final void Function() saveChanges;

  EditableTable({
    required this.onDeleteAccount,
    required this.saveChanges,
  });

  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  final double fontSizeForColumns = 24;

  //----------------------EDITABLE DATA TABLE--------------------------

  @override
Widget build(BuildContext context) {
  if (tableData.isNotEmpty) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
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
                    Text(
                      '******', // Display asterisks or dots instead of the actual password
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (cell == 'Role') {
                  //---------------------ROLE---------------------
                  return DataCell(
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 50),
                          width: 80,
                          child: Text(
                            row[cell].toString(),
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        //---------------------EDIT BUTTON---------------------
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showEditUserDialog(context, row, () {
                              widget.saveChanges();
                            });
                          },
                        ),
                        //---------------------DELETE BUTTON---------------------
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDeleteDialog(row['ID']);
                          },
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
        ),
      ),
    );
  } else {
    return Center(
      child: Text("No data available"),
    );
  }
}

//----------------------CONFIRM DELETE DIALOG--------------------------------

Future<void> _confirmDeleteDialog(int accountId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete this account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Bezárja a dialogot
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onDeleteAccount(accountId); // Törölje az fiókot
                Navigator.of(context).pop(); // Bezárja a dialogot
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
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
  double dynamicHeight = tableData.isNotEmpty
      ? (tableData.length * (24 + 2 * 3)) + 400
      : 420; // Default height

  return Padding(
    padding: EdgeInsets.only(bottom: 20),
    child: SingleChildScrollView(
      child: Container(
        height: dynamicHeight,
        width: w,
        margin: EdgeInsets.symmetric(horizontal: w! / 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 75,
              child: EditableTable(onDeleteAccount: deleteAccount, saveChanges: saveChanges),
            ),
            Expanded(
              flex: 25,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    //----------------------LOGOUT BUTTON--------------------------
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          await Future.delayed(Duration(seconds: 1));
                          Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()));
                        },
                        child: Text(
                          'LOGOUT',
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
          print('Database file uploaded successfully');
          fetchDataFromBackend();
        } else {
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
      fetchDataFromBackend();
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (error) {
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
    } else {
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['error'];

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    }
  } catch (error) {
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
              createRoleController.text = "User";
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

//----------------------EDIT USER WINDOW-------------------------
// Define a global key for the form
final _formKey = GlobalKey<FormState>();

final _passwordController = TextEditingController();
final _roleController = TextEditingController(); // This controller is not needed for the DropdownButtonFormField

void showEditUserDialog(BuildContext context, Map<String, dynamic> user, Function onSave) {
  _passwordController.text = user['Password'];

  // Initialize the role value with the user's current role
  String selectedRole = user['Role'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('User: ${user['Username']}'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  } else if (value.length < 4) {
                    return 'Password must be at least 4 characters long';
                  } else if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value)) {
                    return 'Password can only contain English letters and numbers';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['Engineer', 'User'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  // Update the selected role when the user makes a selection
                  selectedRole = value!;
                },
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Update the user information with the edited values
                user['Password'] = _passwordController.text;
                user['Role'] = selectedRole; 
                Navigator.of(context).pop();
                onSave();
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}



//----------------------USER CREATION--------------------------

class CreateUserForm extends StatefulWidget {
  final void Function() onCreateUser;
  final Future<void> Function() createAccount;
  final TextEditingController createUsernameController;
  final TextEditingController createPinController;
  final TextEditingController createRoleController;

  // Konstruktor a kezdeti szerepkör beállításával
  CreateUserForm({
    required this.onCreateUser,
    required this.createAccount,
    required this.createUsernameController,
    required this.createPinController,
    required this.createRoleController,
  }) {
    createRoleController.text = 'User'; // Alapértelmezett szerepkör: 'User'
  }

  @override
  _CreateUserFormState createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  String selectedRole = 'User';

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.all(8.0);
    final height = 50.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: padding,
          height: height,
          child: TextField(
            controller: widget.createUsernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ),
        Container(
          padding: padding,
          height: height,
          child: TextField(
            controller: widget.createPinController,
            decoration: InputDecoration(
              labelText: 'Password',
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ),
        Container(
          padding: padding,
          height: height,
          child: DropdownButtonFormField<String>(
            value: selectedRole,
            items: ['User', 'Engineer'].map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
                widget.createRoleController.text = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Role',
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ),
      Container(
  padding: padding,
  margin: EdgeInsets.only(top: 10),
  height: height,
  child: Center(
    child: ElevatedButton(
      onPressed: () async {
        // Hibakezelés a felhasználónévre
        String? usernameError = validateUsername(widget.createUsernameController.text);
        if (usernameError != null) {
          // Ha van hiba a felhasználónévben, mutass hibaüzenetet és ne folytasd tovább
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(usernameError),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        // Ellenőrizze, hogy van-e már ilyen felhasználónév az adatbázisban
        bool isUsernameTaken = await checkIfUsernameExists(widget.createUsernameController.text);
        if (isUsernameTaken) {
          // Ha a felhasználónév már foglalt, mutass hibaüzenetet és ne folytasd tovább
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This username is already exist!'),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        // Hibakezelés a jelszóra
        String? passwordError = validatePassword(widget.createPinController.text);
        if (passwordError != null) {
          // Ha van hiba a jelszóban, mutass hibaüzenetet és ne folytasd tovább
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(passwordError),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        // Fiók létrehozása, ha minden rendben van
        await widget.createAccount();
        widget.onCreateUser();
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
      ),
      child: Text(
        'Create',
        style: TextStyle(fontSize: 18),
      ),
    ),
  ),
),
      ],
    );
  }
  
String? validateUsername(String username) {
  if (username.isEmpty) {
    return 'Username is required';
  } else if (!RegExp(r'^[a-zA-Z]*$').hasMatch(username)) {
    return 'Username can only contain English letters';
  }
  return null;
}

String? validatePassword(String password) {
  if (password.isEmpty) {
    return 'Password is required';
  } else if (password.length < 4) {
    return 'Password must be at least 4 characters long';
  } else if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(password)) {
    return 'Password can only contain English letters and numbers';
  }
  return null;
}

bool checkIfUsernameExists(String desiredUsername) {
  for (Map<String, dynamic> userData in tableData) {
    if (userData['Username'] == desiredUsername) {
      return true;
    }
  }
  return false;
}

  }