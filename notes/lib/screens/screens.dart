library screens;

import 'package:flutter/material.dart';
import 'package:notes/components/components.dart';
import 'package:notes/constants.dart';
import 'package:notes/components/dialogs/dialogs.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/models.dart';
import 'package:notes/model/my_tree_node.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/services/services.dart';
import 'dart:developer';
import 'dart:async';
import 'package:notes/components/my_tree_view.dart';

part 'settings.dart';
part 'login.dart';
part 'register.dart';
part 'reset_password.dart';
part 'main_screen.dart';
part 'conflict.dart';
