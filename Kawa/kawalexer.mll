{

  open Lexing
  open Kawaparser

  exception Error of string

  let keyword_or_ident =
  let h = Hashtbl.create 17 in
  List.iter (fun (s, k) -> Hashtbl.add h s k)
    [ "print",    PRINT;
      "main",     MAIN;
      "var",      VAR;
      "attribute",ATTRIBUTE;
      "method",   METHOD;
      "class",    CLASS;
      "new",      NEW;
      "this",     THIS;
      "if",       IF;
      "else",     ELSE;
      "while",    WHILE;
      "return",   RETURN;
      "int",      INT_TYPE;
      "bool",     BOOL_TYPE;
      "void",     VOID_TYPE;
      "true",     TRUE;
      "false",    FALSE;
      "super",    SUPER;
      "extends",  EXTENDS;
      "final",    FINAL;
      "public",   PUBLIC;
      "private",  PRIVATE;
      "protected",PROTECTED;
      "instanceof",INSTANCEOF;
    ] ;
  fun s ->
    try  Hashtbl.find h s
    with Not_found -> IDENT(s)
        
}

let digit = ['0'-'9']
let number = ['-']? digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*
  
rule token = parse
  | ['\n']            { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+  { token lexbuf }

  | "//" [^ '\n']* "\n"  { new_line lexbuf; token lexbuf }
  | "/*"                 { comment lexbuf; token lexbuf }

  | number as n  { INT(int_of_string n) }
  | ident as id  { keyword_or_ident id }

  | ";"  { SEMI }
  | "("  { LPAR }
  | ")"  { RPAR }
  | "{"  { BEGIN }
  | "}"  { END }
  | "="  { ASSIGN }
  | "+"  { ADD }
  | "-"  { SUB }
  | "*"  { MUL }
  | "/"  { DIV }
  | "%"  { REM }
  | "==" { EQ }
  | "!=" { NEQ }
  | "<"  { LT }
  | "<=" { LE }
  | ">"  { GT }
  | ">=" { GE }
  | "&&" { AND }
  | "||" { OR }
  | "."  { DOT }
  | ","  { COMMA }
  | eof  { EOF }
  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }


and comment = parse
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }
