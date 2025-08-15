%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <string> IDENT
%token MAIN VAR ATTRIBUTE METHOD CLASS NEW THIS SUPER EXTENDS
%token INT_TYPE BOOL_TYPE VOID_TYPE
%token LPAR RPAR BEGIN END SEMI COMMA DOT
%token ADD SUB MUL DIV REM ASSIGN
%token PRINT IF ELSE WHILE RETURN TRUE FALSE
%token EQ NEQ LT LE GT GE AND OR
%token FINAL
%token PUBLIC PRIVATE PROTECTED
%token INSTANCEOF
%token EOF

%start program
%type <Kawa.program> program

(*precedence declarations*)
%right ASSIGN
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left ADD SUB
%left MUL DIV REM

%%

program:
| globals=var_decl_list classes=class_list MAIN BEGIN main=seq END EOF
    { {classes; globals; main} }
;

(* Variable declarations list *)
var_decl_list:
| /* empty */ { [] }
| var_decl var_decl_list { $1 @ $2 }
;

(* Single variable declaration *)
var_decl:
| VAR typ var_list SEMI { List.map (fun id -> (id, $2)) $3 }
;

(* List of variable names *)
var_list:
| IDENT { [$1] }
| IDENT COMMA var_list { $1 :: $3 }
;

(* List of class definitions *)
class_list:
| /* empty */ { [] }
| class_def class_list { $1 :: $2 }
;

(* Class definition *)
class_def:
| CLASS IDENT BEGIN attr_list method_list END
    { 
      { class_name=$2; attributes=$4; methods=$5; parent=None } 
    }
| CLASS IDENT EXTENDS IDENT BEGIN attr_list method_list END
    { 
      { class_name=$2; attributes=$6; methods=$7; parent=Some($4) } 
    }
;


attr_list:
| /* empty */ { [] }
| PRIVATE ATTRIBUTE FINAL typ IDENT SEMI attr_list { ($5, $4, true, Private) :: $7 }  (* Attribut final et privé *)
| PROTECTED ATTRIBUTE FINAL typ IDENT SEMI attr_list { ($5, $4, true, Protected) :: $7 }  (* Attribut final et protégé *)
| ATTRIBUTE FINAL typ IDENT SEMI attr_list { ($4, $3, true, Public) :: $6 }  (* Attribut final et public *)
| PUBLIC ATTRIBUTE FINAL typ IDENT SEMI attr_list { ($5, $4, true, Public) :: $7 }  (* Attribut final et public *)
| PRIVATE ATTRIBUTE typ IDENT SEMI attr_list { ($4, $3, false, Private) :: $6 }  (* Attribut privé *)
| PROTECTED ATTRIBUTE typ IDENT SEMI attr_list { ($4, $3, false, Protected) :: $6 }  (* Attribut protégé *)
| PUBLIC ATTRIBUTE typ IDENT SEMI attr_list { ($4, $3, false, Public) :: $6 }  (* Attribut public *)
| ATTRIBUTE typ IDENT SEMI attr_list { ($3, $2, false, Public) :: $5 }  (* Attribut public *)
;



(* Method definitions *)
method_list:
| /* empty */ { [] }
| method_def method_list { $1 :: $2 }
;


method_def:
| PRIVATE METHOD typ IDENT LPAR param_list RPAR BEGIN locals=var_decl_list code=seq END
    { {method_name=$4; params=$6; locals; code; return=$3; visibility=Private} }
| PROTECTED METHOD typ IDENT LPAR param_list RPAR BEGIN locals=var_decl_list code=seq END
    { {method_name=$4; params=$6; locals; code; return=$3; visibility=Protected} }
| METHOD typ IDENT LPAR param_list RPAR BEGIN locals=var_decl_list code=seq END
    { {method_name=$3; params=$5; locals; code; return=$2; visibility=Public} }
;


param_list:
| /* empty */ { [] }
| typ IDENT { [($2, $1)] }
| typ IDENT COMMA param_list { ($2, $1) :: $4 }
;

typ:
| INT_TYPE { TInt }
| BOOL_TYPE { TBool }
| VOID_TYPE { TVoid }
| IDENT { TClass($1) }
;

(* Sequence of instructions *)
seq:
| /* empty */ { [] }
| instr seq { $1 :: $2 }
;

instr:
| PRINT LPAR expr RPAR SEMI { Print($3) }
| mem_access ASSIGN expr SEMI { Set($1, $3) }
| IF LPAR expr RPAR BEGIN s1=seq END ELSE BEGIN s2=seq END { If($3, s1, s2) }
| WHILE LPAR expr RPAR BEGIN s=seq END { While($3, s) }
| RETURN expr SEMI { Return($2) }
| expr SEMI { Expr($1) }
;

expr:
| INT { Int($1) }                                    (* Integer constant *)
| TRUE { Bool(true) }                                (* Boolean true *)
| FALSE { Bool(false) }                              (* Boolean false *)
| THIS { This }                                      (* Current object reference *)
| NEW IDENT { New($2) }                              (* New object creation *)
| NEW IDENT LPAR expr_list RPAR { NewCstr($2, $4) }  (* Constructor call *)
| mem_access { Get($1) }                             (* Access memory *)
| expr ADD expr { Binop(Add, $1, $3) }               (* Addition *)
| expr SUB expr { Binop(Sub, $1, $3) }               (* Subtraction *)
| expr MUL expr { Binop(Mul, $1, $3) }               (* Multiplication *)
| expr DIV expr { Binop(Div, $1, $3) }               (* Division *)
| expr REM expr { Binop(Rem, $1, $3) }               (* Modulo *)
| expr EQ expr { Binop(Eq, $1, $3) }                 (* Equality *)
| expr NEQ expr { Binop(Neq, $1, $3) }               (* Inequality *)
| expr LT expr { Binop(Lt, $1, $3) }                 (* Less than *)
| expr GE expr { Binop(Ge, $1, $3) }                 (* Greater or equal *)
| expr GT expr { Binop(Gt, $1, $3) }                 (* Greater than *)
| expr LE expr { Binop(Le, $1, $3) }                 (* Less or equal *)
| expr AND expr { Binop(And, $1, $3) }               (* Logical AND *)
| expr OR expr { Binop(Or, $1, $3) }                 (* Logical OR *)
| IDENT { Get(Var($1)) }                             (* Variable access *)
| expr DOT IDENT { Get(Field($1, $3)) }              (* Field access *)
| expr DOT IDENT LPAR expr_list RPAR { MethCall($1, $3, $5) } (* Method call *)
| LPAR expr RPAR { $2 }                              (* Parenthesized expression *)
| SUPER LPAR expr_list RPAR { MethCall(This, "constructor", $3) } (* Superclass constructor call *)
| expr INSTANCEOF IDENT { InstanceOf($1, $3) }       (* Instanceof operator *)
;

expr_list:
| /* empty */ { [] }
| expr { [$1] }
| expr COMMA expr_list { $1 :: $3 }
;

(* Memory access *)
mem_access:
| IDENT { Var($1) }
| expr DOT IDENT { Field($1, $3) }
;