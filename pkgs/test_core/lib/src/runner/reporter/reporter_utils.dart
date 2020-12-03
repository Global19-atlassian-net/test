// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:test_api/src/util/remote_exception.dart'; // ignore: implementation_imports

/// Returns `true` if the 'GITHUB_ACTIONS' environment variable is 'true'.
///
/// See https://docs.github.com/en/free-pro-team@latest/actions/reference/environment-variables#default-environment-variables
final bool runningOnGitHubActions =
    Platform.environment['GITHUB_ACTIONS'] == 'true';

void githubErrorHeader(StringSink sink, dynamic error, StackTrace stackTrace) {
  if (runningOnGitHubActions) {
    final frames = Trace.from(stackTrace)
        .frames
        .where((element) =>
            element.library != 'package:test_api' &&
            !element.library.startsWith('org-dartlang-sdk:'))
        .toList();

    if (frames.isNotEmpty) {
      final frame = frames.first;
      final components = [
        'file=${frame.library}',
        if (frame.line != null) 'line=${frame.line}',
        if (frame.column != null) 'col=${frame.column}',
      ];

      final message = error is RemoteException ? error.type : error.runtimeType;

      // ::error file={name},line={line},col={col}::{message}
      sink.writeln('::error ${components.join(',')}::${message}');
    }
  }
}
