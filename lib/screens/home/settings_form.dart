import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  String _currentName;
  String _currentSugars;
  int _currentStrength;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        }

        UserData userData = snapshot.data;

        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Update your brew settings.',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: "Name"),
                validator: (val) => val.isEmpty ? 'Please enter a name' : null,
                onChanged: (val) => setState(() => _currentName = val),
                initialValue: userData.name,
              ),
              SizedBox(height: 10.0),
              // dropdown
              DropdownButtonFormField(
                items: sugars
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text("$e Sugars")))
                    .toList(),
                value: _currentSugars ?? userData.sugars,
                decoration: textInputDecoration,
                onChanged: (val) => setState(() => _currentSugars = val),
              ),
              // slider
              Slider(
                min: 100,
                max: 900,
                divisions: 8,
                value: (_currentStrength ?? userData.strength).toDouble(),
                activeColor:
                    Colors.brown[_currentStrength ?? userData.strength],
                inactiveColor: Colors.brown[50],
                onChanged: (val) =>
                    setState(() => _currentStrength = val.round()),
              ),
              RaisedButton(
                  color: Colors.pink[400],
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      await DatabaseService(uid: user.uid).updateUserData(
                          _currentSugars ?? userData.sugars,
                          _currentStrength ?? userData.strength,
                          _currentName ?? userData.name);
                      Navigator.pop(context);
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}
