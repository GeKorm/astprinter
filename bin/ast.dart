import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';

main(List<String> path) {
  CompilationUnit unit = parseDartFile(path[0]);
  print(expandedAst(unit));
}

String expandedAst(CompilationUnit u) {
  Iterable children = u.childEntities;
  getRecursiveChildren(children);
  String temp = stuff.join();
  stuff.clear();
  return temp;
}

List<String> stuff = [];

void getRecursiveChildren(dynamic cu, [List<String> builder, int count]) {
  if (builder == null) {
    builder = [];
    count = 0;
  }
  for (var ch in cu) {
    var temp = null;
    count++;
    stuff.add(
        spaces(count) + ch.runtimeType.toString() + '::: ' + ch.toString() + '\n');
    try {
      temp = ch.childEntities;
    } catch (exception, stackTrace) {
      //
    }
    if (temp != null) {
      builder.add(stuff.toString() + spaces(count) + '\n\n');
      getRecursiveChildren(temp, builder, count);
      count--;
    }
  }
}

String spaces(int c) {
  List<String> spac = [];
  if (c == 0) {
    return '';
  } else if (c > 0) {
    for (int i = 0; i < c; i++) {
      spac.add('  ');
    }
    return spac.join();
  }
}