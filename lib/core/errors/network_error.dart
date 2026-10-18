import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

bool isNetworkError(Object error) =>
    error is SocketException ||
    error is TimeoutException ||
    error is FirebaseException &&
        (error.code == 'unavailable' || error.code == 'deadline-exceeded');
