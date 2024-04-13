library screens;

import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/dialogs/aboutAppDialog.dart';
import 'package:notes/components/dialogs/deleteDialog.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/logger.dart';
import 'package:notes/main.dart';
import 'package:notes/model/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/theme.dart';
import 'package:notes/screens/conflict.dart';
import 'package:notes/screens/logs.dart';
import 'package:provider/provider.dart';

part 'settings.dart';
