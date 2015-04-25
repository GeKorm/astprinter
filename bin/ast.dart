import 'dart:io';
import 'dart:mirrors';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/scanner.dart';

bool isSubType(dynamic obj, ClassMirror sec) =>
    reflect(obj).type.isSubtypeOf(sec);

Type typeOf(dynamic obj) => reflect(obj).type.reflectedType;

main(List<String> args) {
  if (args.length == 1) {
    CompilationUnit unit = parseDartFile(args[0]);
    ClassMirror mirror = reflectClass(Object);
    print(expandedAst(unit, mirror));
  } else if (args.length == 2) {
    CompilationUnit unit = parseDartFile(args[0]);
    List mirrors = createMirrors(args[1]);
    if (mirrors[0] != null) {
      print(expandedAst(unit, mirrors[0]));
    } else if (mirrors[1] != null) {
      print(expandedAst(unit, mirrors[1]));
    } else {
      print('Invalid AST node Type: ' + args[1]);
      exit(2);
    }
  } else {
    print('''
        Usage: ast <path> <Type(optional)> ||| prints the whole expanded AST

        <path> must be absolute
        <Type> will print all nodes that are subtypes of Type
        ''');
    exit(2);
  }
}

List createMirrors(String arg) {
  MirrorSystem mirrors = currentMirrorSystem();
  LibraryMirror engineAst = mirrors.libraries.values.firstWhere(
      (LibraryMirror engineAst) =>
          engineAst.qualifiedName == new Symbol('engine.ast'));
  LibraryMirror engineScanner = mirrors.libraries.values.firstWhere(
      (LibraryMirror engineScanner) =>
          engineScanner.qualifiedName == new Symbol('engine.scanner'));
  ClassMirror cmAst;
  ClassMirror cmScanner;
  try {
    cmAst = engineAst.declarations[new Symbol(arg)];
    cmScanner = engineScanner.declarations[new Symbol(arg)];
  } catch (exception, stackTrace) {
    //
  }
  return [cmAst, cmScanner];
}

String expandedAst(CompilationUnit u, ClassMirror c) {
  Iterable children = u.childEntities;
  getRecursiveChildren(children, c);
  String temp = stuff.join('\n');
  stuff.clear();
  return temp;
}

List<String> stuff = [];

void getRecursiveChildren(dynamic cu, ClassMirror nodeType,
    [List<String> builder, int count]) {
  if (builder == null) {
    builder = [];
    count = 0;
  }
  for (var ch in cu) {
    var temp = null;
    if (isSubType(ch, nodeType)) {
      count++;
      stuff.add(spaces(count) + typeOf(ch).toString() + '::: ' + ch.toString());
    }
    try {
      temp = ch.childEntities;
    } catch (exception, stackTrace) {
      //
    }
    if (temp != null) {
      if (isSubType(ch, nodeType)) {
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

String spaces(int c) {
  List<String> spac = [];
  if (c > 1) {
    for (int i = 1; i < c; i++) {
      spac.add('  ');
    }
    return spac.join();
  } else {
    return '';
  }
}
