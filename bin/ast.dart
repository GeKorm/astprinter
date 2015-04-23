import 'dart:io';
import 'dart:mirrors';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';

bool isType(dynamic obj, ClassMirror sec) {
  return reflect(obj).type.isSubtypeOf(sec);
}

main(List<String> args) {
  if (args.length == 1) {
    CompilationUnit unit = parseDartFile(args[0]);
    ClassMirror mirror = reflectClass(Object);
    stdout.write(expandedAst(unit, mirror));
  } else if (args.length == 2) {
    if (args[1] == '-dir') {
      CompilationUnit unit = parseDartFile(args[0]);
      stdout.write(astDirectives(unit));
    } else if (args[1] == '-dec') {
      CompilationUnit unit = parseDartFile(args[0]);
      ClassMirror mirror = reflectClass(Declaration);
      stdout.write(expandedAst(unit, mirror));
    } else {
      printUsageError();
    }
  } else {
    printUsageError();
  }
}

String expandedAst(CompilationUnit u, ClassMirror c) {
  Iterable children = u.childEntities;
  getRecursiveChildren(children, c);
  String temp = stuff.join('\r');
  stuff.clear();
  return temp;
}

String astDirectives(CompilationUnit u) {
  return buildListString(u.directives);
}

List<String> stuff = [];

String buildListString(NodeList nl) {
  List<String> builder = [];
  for (var item in nl) {
    builder.add(item.runtimeType.toString() + '::: ' + item.toString());
  }
  String temp = builder.join('\r');
  return temp;
}

void getRecursiveChildren(dynamic cu, ClassMirror nodeType,
    [List<String> builder, int count]) {
  if (builder == null) {
    builder = [];
    count = 0;
  }
  for (var ch in cu) {
    var temp = null;
    if (isType(ch, nodeType)) {
      count++;
      stuff.add(
          spaces(count) + ch.runtimeType.toString() + '::: ' + ch.toString());
    }
    try {
      temp = ch.childEntities;
    } catch (exception, stackTrace) {
      //
    }

    if (temp != null) {
      if (isType(ch, nodeType)) {
        builder.add(stuff.toString());
        getRecursiveChildren(temp, nodeType, builder, count);
        count--;
      } else {
        builder.add(stuff.toString());
        getRecursiveChildren(temp, nodeType, builder, count);
      }
    }
  }
}

void printUsageError() {
  print('''Usage: ast <path> <-optional>
  -dir prints directives"
  -dec prints declarations''');
  exit(1);
}

String spaces(int c) {
  List<String> spac = [];
  if (c > 0) {
    for (int i = 0; i < c; i++) {
      spac.add('  ');
    }
    return spac.join();
  } else {
    return '';
  }
}
