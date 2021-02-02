import 'package:flutter/material.dart';

// NETWORKING
const TIME_OUT_DURATION = Duration(minutes: 3);

//const SERVER_URL = 'http://10.0.2.2:8080'; // Android Emulator
//const SERVER_URL = 'http://localhost:8080'; // IOS Emulator / Web

//const SERVER_URL = 'http://161.35.173.217:8080'; // Internet Local
//const SERVER_URL = 'http://10.0.0.46:8080'; // Local PC

const SERVER_URL = 'http://localhost'; // Kubernetes Pod / Docker Container


// COLORS
const BACKGROUND_COLOR = Color(0xff383838);
//const PRIMARY_COLOR = Color(0xff383838);

const BUTTON_COLOR = Color(0xff383838);
const CARD_COLOR = Color(0xff262727);

const ACCENT_COLOR = Color(0xff7daea3);
const ADD_COLOR = Color(0xff89b482);
const REMOVE_COLOR = Color(0xffea6962);
const WARNING_COLOR = Color(0xffcc973d);

const TEXT_COLOR = Color(0xffa8a8a8);
const TEXT_CONTENT_COLOR = Color(0xfff9f5d7);
const INACTIVE_COLOR = Color(0xffa89984);


// MESSAGES
const OFFLINE_ERROR_MESSAGE = 'Offline Error: Check Internet Connection';
