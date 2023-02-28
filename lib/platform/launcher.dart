import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'launcher.g.dart';

@JsonSerializable()
class AppInfo {
  String name;
  String packageName;
  String iconData;

  AppInfo(this.name, this.packageName, this.iconData);

  factory AppInfo.fromJson(Map<String, dynamic> json) => _$AppInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AppInfoToJson(this);
}