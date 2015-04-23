# AstPrinter

A command line tool that prints the AST of a dart file.

![Output example](https://raw.githubusercontent.com/GeKorm/docimages/master/astprinter/AST.png)
The above image was achieved by using: ```ast <path> > output.txt```, 
opening output.txt in Sublime Text and adding Dart syntax highlighting.

## Usage

First, activate the package with pub global

    pub global activate astprinter
    
You must manually add the pub cache bin directory to your PATH.
Pub will warn you if you haven't already.
    
To print the AST in the console, run ast <"absolutePathToDartFile">

    ast "C:\Users\Administrator\Dart Projects\TestProject\web\main.dart"

Optional parameters: ```-dec``` and ```-dir```, print all
nested declarations and directives respectively.



## Features and bugs

Please file feature requests and bugs on [GitHub][tracker].

[tracker]: https://github.com/GeKorm/astprinter/issues/new
