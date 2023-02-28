import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zcar/platform/launcher.dart';
import 'package:zcar/platform/zcar.dart';

class Launcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Icon(Icons.arrow_back),
                ),
              ),
            )
          ),
          Flexible(
            flex: 9,
            child: _buildAppGrid(context)
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid(BuildContext context) {
    return FutureBuilder<List<AppInfo>>(
      future: ZCar.listAllApps(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return GridView.count(
          crossAxisCount: 5,
          padding: EdgeInsets.all(15),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          children: snapshot.requireData.map((e) => GestureDetector(
            onTap: () {
              ZCar.runApp(e.packageName);
              Navigator.pop(context);
            },
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Image.memory(base64Decode(e.iconData), fit: BoxFit.cover,),
                ),
                Column(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      color: Colors.black45,
                      child: Center(
                        child: Text(e.name, style: TextStyle(fontSize: 24, color: Colors.white),),
                      ),
                    )
                  ],
                )
              ],
            ),
          )).toList(),
        );
      },
    );
  }
}