import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _rememberme = true;
  bool _passwordShow = false;

  String _email = 'luis@yopmail.com';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '123456';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _showLogo(),
              SizedBox(height: 20,),
              _showEmail(),
              _showPassword(),
              _showRememberme(),
              _showButtons(),
            ],
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...') : Container(),
        ],
      ),
    ); 
    
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage('assets/vehicles_logo.png'),
      width: 300,);
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.email),
          prefixIcon: Icon(Icons.alternate_email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          hintText: 'Ingrese tu email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          labelStyle: TextStyle(
            color: Color(0xFF6200EE),
          ),
        ),
        onChanged: (value){
          _email = value;
        },
      )
    );
  }

  Widget _showPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.text,
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: _passwordShow ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
            onPressed: (){
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          hintText: 'Ingrese tu email...',
          labelText: 'Password',
          errorText: _passwordShowError ? _passwordError : null,
        ),
        onChanged: (value){
          _password = value;
        },
      )
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Text('Iniciar sesión'),
              
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states){
                    return Color(0xFFEDBF69);
                  }
                ),
              ),

              onPressed: () => _login(),
             
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              child: Text('Crear cuenta'),

              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states){
                    return Color(0xFFA77B06);
                  }
                ),
              ),
              onPressed: (){}
            ),
          ),
        ],
      ),
    );
  }

  Widget _showRememberme() {
    return CheckboxListTile(
      title: Text('Recordarme'), 
      value: _rememberme,
      onChanged: (value) { 
        setState(() {     
          _rememberme = value!;
        });
      },
    );
  }

  void _login() async{

    setState(() {
      _passwordShow = false;
    });

    if(!_validateFields()) return;

    setState(() => {
      _showLoader = true
    });

    // Get request in the body, and save in object type Map
    Map<String, dynamic> request = {
      'userName': _email,
      'password': _password
    };

    var url = Uri.parse('${Constans.apiUrl}/api/Account/CreateToken');
    var response = await http.post(
      url, 
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
      body: jsonEncode(request)
    );

    setState(() => {
      _showLoader = false
    });

    if(response.statusCode >= 400){
      setState(() {
        _passwordShowError = true;
        _passwordError = 'Email o contraseña incorretos.';
      });
      
      return;

    }

    var body = response.body;
    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => HomeScreen(token: token,)
      )
    );
  }

  bool _validateFields() {
    bool isValid = true;

    if(_email.isEmpty){
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes de ingresar tu email...';      
    }else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email válido.';
    }else{
      _emailShowError = false;
    }
    
    if(_password.isEmpty){
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes de ingresar tu contraseña...';      
    }else if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar una contraseña de al menos 6 carácteres.';
    }else{
      _passwordShowError = false;
    }

    setState(() { });
    return isValid;
  }
}