import 'dart:convert';
import 'dart:developer';

import 'package:code_text_field/code_text_field.dart';
import 'package:eticon_j2d/project_utils/json_to_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eticon_j2d/project_utils/project_utils.dart';
import 'package:eticon_j2d/project_widgets/project_widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pretty_json/pretty_json.dart';
import 'cubit/cb_main_screen.dart';
import 'cubit/st_main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlight/themes/lightfair.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/json.dart';
import 'package:flutter_highlight/themes/idea.dart';
import 'package:flutter_highlight/themes/isbl-editor-light.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_highlight/themes/github.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CodeController _jsonController;
  late CodeController _dartController;

  late TextEditingController className = TextEditingController();

  bool resReady = false;
  bool buttonTap = false;

  @override
  void initState() {
    _jsonController = CodeController(
      text: '',
      language: json,
      theme: ideaTheme,
    );
    _dartController = CodeController(
      text: '',
      language: dart,
      theme: githubTheme,//isblEditorLightTheme,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width > 1000
            ? MediaQuery.of(context).size.width
            : 1000,
        color: Color.fromRGBO(250, 250, 250, 1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'ETICON Json2Dart',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Paste your JSON in the textarea below, click convert and get your Dart classes for free.',
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 350,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JSON',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          CodeField(
                            controller: _jsonController,
                            maxLines: 20,
                            minLines: 20,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextField(
                            controller: className,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                            ],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Input dart class name...",
                                fillColor: Colors.white70),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if(!buttonTap && className.text.isNotEmpty){
                                try{
                                  Map<String, dynamic> json = {};
                                  var jsonRaw = jsonDecode(_jsonController.rawText);
                                  _jsonController.text = prettyJson(jsonRaw,);
                                  if(jsonRaw is List){
                                    json = jsonRaw[0];
                                  }
                                  else{
                                    json = jsonRaw;
                                  }
                                  String classNameText = className.text;
                                  if(!className.text.endsWith('Model')){
                                    classNameText += 'Model';
                                  }
                                  _dartController.text = JsonToDart.jsonToDart(json, classNameText);
                                } catch(e){
                                  log(e.toString());
                                  Get.dialog(CupertinoAlertDialog(
                                    title: Text('Error'),
                                    content: Text('Json syntax error'),
                                  ));
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                color: buttonTap ? Colors.grey : Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                'Generate Dart Code',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 600,
                      child: CodeField(
                        controller: _dartController,
                        lineNumberBuilder: (i, style){
                          return TextSpan();
                        },
                        background: Color.fromRGBO(250, 250, 250, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
