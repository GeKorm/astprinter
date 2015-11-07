import 'dart:io';
import 'dart:mirrors';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';

bool isSubType(dynamic obj, List<ClassMirror> sec) {
  for (ClassMirror type in sec) {
    if (noSubTypes) {
      if (reflect(obj).type.reflectedType.toString() ==
          type.reflectedType.toString()) {
        return true;
      }
    } else {
      if (reflect(obj).type.isSubtypeOf(type)) {
        return true;
      }
    }
  }
  return false;
}

Type typeOf(dynamic obj) => reflect(obj).type.reflectedType;

bool noSubTypes = false;
List<String> failures = [], stuff = [];

main(List<String> args) {
  if (args.length == 1) {
    CompilationUnit unit = parseDartFile(args[0]);
    List<ClassMirror> mirrors = [reflectClass(Object)];
    print(expandedAst(unit, mirrors));
  } else if (args.length >= 2) {
    List<String> typeArgs = args.getRange(1, args.length).toList();
    if (typeArgs.last == '-n') {
      typeArgs.removeLast();
      noSubTypes = true;
    }
    CompilationUnit unit = parseDartFile(args[0]);
    List<ClassMirror> mirrors = createMirrors(typeArgs);
    if (mirrors.isNotEmpty) {
      print(expandedAst(unit, mirrors));
    } else {
      print('Invalid AST node Types: ' + typeArgs.join(' '));
      exit(2);
    }
  } else {
    print('''
        Usage: ast <path> <Type(optional)> <-n(optional)>

        <path> must be absolute
        <Type> will print all nodes that are subtypes of Type
        Can enter multiple <Type> arguments.
        To print Types without their subtypes append -n.
        ''');
    exit(2);
  }
}

List<ClassMirror> createMirrors(List<String> types) {
  List<Symbol> symbols = [];
  for (var type in types) {
    symbols.add(new Symbol(type));
  }
  MirrorSystem mirrors = currentMirrorSystem();
  Map<Symbol, DeclarationMirror> combinedEngine = {};
  Map<Symbol, DeclarationMirror> engineAst = mirrors.libraries.values
      .firstWhere((LibraryMirror engine) =>
          engine.qualifiedName == new Symbol('engine.ast'))
      .declarations;
  Map<Symbol, DeclarationMirror> engineScanner = mirrors.libraries.values
      .firstWhere((LibraryMirror engine) =>
          engine.qualifiedName == new Symbol('engine.scanner'))
      .declarations;
  List<ClassMirror> cmAst = [];
  combinedEngine..addAll(engineAst)..addAll(engineScanner);
  for (var symbol in symbols) {
    if (combinedEngine.containsKey(symbol)) {
      cmAst.add(combinedEngine[symbol]);
    } else {
      //TODO: Replace with a proper regex
      failures.add(symbol
          .toString()
          .replaceAll('Symbol(', '')
          .replaceAll('(', '')
          .replaceAll(')', ''));
    }
  }
  return cmAst;
}

String expandedAst(CompilationUnit u, List<ClassMirror> c) {
  Iterable children = u.childEntities;
  getRecursiveChildren(children, c);
  String temp = stuff.join('\n');
  if (failures.isNotEmpty) {
    temp += '\nInvalid AST node Types (not printed): ';
    for (var item in failures) {
      temp += '$item ';
    }
  }
  stuff.clear();
  failures.clear();
  noSubTypes = false;
  return temp;
}

void getRecursiveChildren(dynamic cu, List<ClassMirror> nodeTypes,
    [List<String> builder, int count]) {
  if (builder == null) {
    builder = [];
    count = 0;
  }
  for (var ch in cu) {
    var temp = null;
    if (isSubType(ch, nodeTypes)) {
      count++;
      stuff.add(spaces(count) + typeOf(ch).toString() + '::: ' + ch.toString());
    }
    try {
      temp = ch.childEntities;
    } catch (exception) {
      //
    }
    if (temp != null) {
      if (isSubType(ch, nodeTypes)) {
        builder.add(stuff.toString());
        getRecursiveChildren(temp, nodeTypes, builder, count);
        count--;
      } else {
        builder.add(stuff.toString());
        getRecursiveChildren(temp, nodeTypes, builder, count);
      }
    }
  }
}

String spaces(int c) {
  List<String> space = [];
  if (c > 1) {
    for (int i = 1; i < c; i++) {
      space.add('  ');
    }
    return space.join();
  } else {
    return '';
  }
}
