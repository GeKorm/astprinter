# AstPrinter

A command line tool that prints the expanded AST (Abstract Syntax Tree) of a dart file.

![Output example](https://raw.githubusercontent.com/GeKorm/docimages/master/astprinter/AST.png)

The above image was created using ```ast <path> > output.txt```, then
opening output.txt in Sublime Text and adding Dart syntax highlighting.

## Usage

First, activate the package with pub global

    pub global activate astprinter
You must manually add the pub cache bin directory to your PATH.
Pub will warn you if you haven't already.
    
To print the AST in the console, run ```ast <"absolutePathToDartFile"> <Type(OPTIONAL)>```

    ast "C:\Path\web\main.dart" Declaration
Optional argument ```Type``` will print all AST nodes that are subtypes of ```Type```

## Features and bugs

Please file feature requests and bugs on [GitHub][tracker].

[tracker]: https://github.com/GeKorm/astprinter/issues/new
