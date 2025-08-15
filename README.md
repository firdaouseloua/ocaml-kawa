# Kawa – An Object-Oriented Language in OCaml

Kawa is an object-oriented programming language implemented in OCaml.  
It includes a lexer, parser, type checker, and interpreter. This project is useful for learning about compiler design, interpreters, and type systems.

---

## Features
- Custom object-oriented syntax
- Lexer and parser built with **OCamlLex** and **Menhir**
- Static type checking
- Interpreter for executing `.kwa` programs
- Example `.kwa` test files

---

## Repository Structure
```
KAWA/
├── _build/                     # Build artifacts
├── tests/                      # Example programs in .kwa
│   ├── arith.kwa
│   ├── class.kwa
│   ├── method.kwa
│   ├── ...
├── dune                        # Dune build file
├── dune-project                # Dune project configuration
├── interpreter.ml              # Program interpreter
├── kawa.ml                     # AST definitions
├── kawai.ml                    # Main program entry
├── kawalexer.mll               # Lexer
├── kawaparser.mly               # Parser
├── typechecker.ml               # Type checker
└── Readme.txt                  # Original project notes
```

---

## Requirements
- [OCaml](https://ocaml.org/) ≥ 4.12
- [Dune](https://dune.build/) build system
- Menhir (`opam install menhir`)
- OCamlLex (comes with OCaml)

---

## Running Tests
Test files are located in `tests/` and demonstrate various features:
- `arith.kwa` – Arithmetic operations
- `class.kwa` – Class declaration
- `method.kwa` – Method definitions
- `extend.kwa` – Class inheritance
- `visibility.kwa` – Public/private/protected members

Example:
```bash
dune exec ./kawai.exe tests/class.kwa
```

---

## Components Overview

### Lexer - `kawalexer.mll`
Defines tokens for keywords, symbols, identifiers, integers, etc.  
Example:
```ocaml
rule token = parse
  | "class" { CLASS }
  | "extends" { EXTENDS }
  | ['0'-'9']+ as num { INT (int_of_string num) }
  | eof { EOF }
```

### Parser - `kawaparser.mly`
Implements grammar rules for Kawa syntax using Menhir.  
Example:
```ocaml
class_decl:
  CLASS IDENT LBRACE class_body RBRACE { ... }
```

### Type Checker - `typechecker.ml`
Performs static type checking for:
- Class and method definitions
- Variable declarations
- Expression type validation

Example rule:
```ocaml
if t1 <> t2 then
  failwith ("Type error: expected " ^ t1 ^ " but got " ^ t2)
```

### Interpreter - `interpreter.ml`
Executes `.kwa` programs by interpreting the AST:
- Evaluates expressions
- Manages object instances
- Calls methods dynamically

---

## Example `.kwa` Program
```java
class Hello {
  public void sayHello() {
    print("Hello, World!");
  }
}

Hello h = new Hello();
h.sayHello();
```

Run it:
```bash
dune exec ./kawai.exe tests/hello.kwa
```

---

## Developer Commands
```bash
# Clean build artifacts
dune clean

# Rebuild project
dune build

# Run with specific test
dune exec ./kawai.exe tests/method.kwa
```

---


## Acknowledgements
Developed as part of a compiler/interpreter course project in OCaml.
