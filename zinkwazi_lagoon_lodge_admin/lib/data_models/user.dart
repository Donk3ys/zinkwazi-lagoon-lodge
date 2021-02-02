import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class User extends Equatable {
  User({
    @required this.id,
    @required this.username,
    @required this.password,
    @required this.role,
    @required this.active,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String username;
  final String email;
  final String role;
  final String password;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;


  factory User.fromJson(Map<String, dynamic> json) => User(
    id : json["id"],
    username : json["username"],
    password : json["password"],
    role : json["role"],
    email : json["email"],
    active : json["active"],
    createdAt : json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    updatedAt : json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
  );

    Map<String, dynamic> toJson() => {
      "id" : id,
      "username" : username,
      "email" : email,
      "password" : password,
      "role" : role,
      "active" : active,
    };

    @override
    String toString() {
      return "$id $username $role";
    }

    @override
    List<Object> get props => [id, updatedAt];
}




