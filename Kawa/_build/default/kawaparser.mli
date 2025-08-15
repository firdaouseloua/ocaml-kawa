
(* The type of tokens. *)

type token = 
  | WHILE
  | VOID_TYPE
  | VAR
  | TRUE
  | THIS
  | SUPER
  | SUB
  | SEMI
  | RPAR
  | RETURN
  | REM
  | PUBLIC
  | PROTECTED
  | PRIVATE
  | PRINT
  | OR
  | NEW
  | NEQ
  | MUL
  | METHOD
  | MAIN
  | LT
  | LPAR
  | LE
  | INT_TYPE
  | INT of (int)
  | INSTANCEOF
  | IF
  | IDENT of (string)
  | GT
  | GE
  | FINAL
  | FALSE
  | EXTENDS
  | EQ
  | EOF
  | END
  | ELSE
  | DOT
  | DIV
  | COMMA
  | CLASS
  | BOOL_TYPE
  | BEGIN
  | ATTRIBUTE
  | ASSIGN
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
