---------
# OVERVIEW
---------
This project implements a compiler for the Kawa language, with features supporting arithmetic operations, variable management, statements, classes, attributes, methods, and inheritance.  
In addition, extensions have been added to enrich the language: serial declarations, `instanceof` operator, visibility modifiers (`public`, `protected`, `private`), and `final` attributes.

The implementation was carried out in four main stages:

- **kawalexer**: Lexical analysis.  
- **kawaparser**: Syntactic (grammatical) analysis.  
- **typechecker**: Type and semantic checking.  
- **interpreter**: Execution of the program in a simulated environment.

-----------------------------
# Implemented Features
-----------------------------

## Core Features

- **Arithmetic Operations**:  
  Supports addition, subtraction, multiplication, division, and modulo.  
  Works in all components (`kawalexer`, `kawaparser`, `typechecker`, `interpreter`).  
  Tested with both simple and complex scenarios.

- **Variables**:  
  Declaration and assignment of variables.  
  Handles different types (`int`, `bool`, class instances).  
  Tested through various cases.

- **Statements**:  
  Supported control structures:  
  - Conditional statements `if-else`  
  - `while` loops  
  - `return` statements  
  Works with nested control flows.

- **Classes and Attributes**:  
  Support for defining classes with attributes and methods.  
  Handles visibility modifiers (`public`, `protected`, `private`) and `final` attributes.  
  Attribute inheritance with conflict checking.

- **Methods**:  
  Support for defining and calling methods, including constructors.  
  Methods comply with visibility rules and parameter checks.  
  Compatibility between inherited method signatures and subclass methods.

- **Inheritance**:  
  Support for single inheritance with parent-child relationship management.  
  Inherited methods and attributes follow visibility and access rules.

## Extensions

- **Serial Declarations**:  
  Ability to declare multiple variables in a single statement (example: `var int a, b, c;`).  
  Implemented in `kawaparser` and tested in all components.

- **`instanceof` Operator**:  
  Added dynamic test to check if an object is an instance (or subtype) of a class.  
  Integrated into `kawaparser`, `typechecker`, and `interpreter`.

- **Visibility Modifiers**:  
  Attributes and methods can be marked as `public`, `protected`, or `private`.  
  Visibility rules are enforced in the `typechecker` and `interpreter`.  
  Extensive tests to ensure compliance with access restrictions.

- **Final Attributes**:  
  Attributes marked as `final` must be initialized in the constructor and cannot be reassigned.  
  Checks added in `typechecker` to enforce this behavior.  
  Tested use cases, including inherited final attributes.

-----------------------------
# Implementation Process
-----------------------------
The implementation followed a step-by-step approach, as shown in the provided table.  
Each feature was first added to the lexer, then parsed in the parser, validated in the typechecker, and finally executed in the interpreter.  
Tests were performed at each stage to ensure proper functionality.

-------------------------
# Challenges Encountered
-------------------------
- **Inheritance Management**: Merging attributes and methods from parent and child classes required careful handling, especially to ensure type consistency.  
- **Type Checker**: The complexity of typing rules for inheritance and extensions required adjustments in the `typechecker`.  
- **Syntax Issues**: Several errors in `kawaparser.mly` had to be fixed, particularly for handling new extensions (`extends`, etc.).  
- **Visibility Rules**: Managing `public`, `protected`, and `private` modifiers required careful handling of class hierarchies. Debugging was complex, especially for attribute access in subclasses.  
- **`instanceof` Operator**: Dynamic type checking for objects posed challenges, especially with inheritance relationships. Thorough testing was required to cover all possible cases.  
- **Final Attributes**: Enforcing the rule that final attributes must be initialized in the constructor and cannot be reassigned required special handling in the `typechecker`. Inherited final attributes added complexity.  
- **Combining Extensions**: Integrating multiple extensions (e.g., visibility and final attributes) while maintaining consistency with inheritance required significant adjustments.

----------------------
# Testing and Validation
----------------------
Tests were performed for each feature, step by step, as shown in the table below:

| Feature                  | kawalexer | kawaparser | typechecker | interpreter |
|--------------------------|-----------|------------|-------------|-------------|
| Arithmetic Operations    | ✅        | ✅         | ✅          | ✅          |
| Variables                | ✅        | ✅         | ✅          | ✅          |
| Statements               | ✅        | ✅         | ✅          | ✅          |
| Classes & Attributes     | ✅        | ✅         | ✅          | ✅          |
| Methods                  | ✅        | ✅         | ✅          | ✅          |
| Inheritance              | ✅        | ✅         | ✅          | ✅          |
| Serial Declarations      | ✅        | ✅         | ✅          | ✅          |
| `instanceof` Operator    | ✅        | ✅         | ✅          | ✅          |
| Visibility Modifiers     | ✅        | ✅         | ✅          | ✅          |
| Final Attributes         | ✅        | ✅         | ✅          | ✅          |

-----------------------
# Current Limitations
-----------------------
- **Optimization**: The code could be optimized to reduce duplication and improve readability.

-------------
# Conclusion
-------------
The project successfully implements the core features of the Kawa language, along with several extensions.  
All components have been thoroughly tested, and most features work as expected.  
The extensions (serial declarations, `instanceof`, visibility modifiers, final attributes) have enriched the language, although they introduced additional challenges.
