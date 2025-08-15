open Kawa

type value =
  | VInt  of int
  | VBool of bool
  | VObj  of obj
  | Null
and obj = {
  cls:    string;
  fields: (string, value) Hashtbl.t;
}

exception Error of string
exception Return of value


let exec_prog (p: program): unit =
  let env = Hashtbl.create 16 in
  List.iter (fun (x, _) -> Hashtbl.add env x Null) p.globals;
  
  (* Evaluate a method call *)
  let rec eval_call f this args =
    (* Trouver la classe correspondante *)
    let rec find_class cname =
      try List.find (fun cls -> cls.class_name = cname) p.classes
      with Not_found -> raise (Error ("Class not found: " ^ cname))
    in

    (* Trouver la méthode dans la hiérarchie de classes *)
    let rec find_method cname =
      let cls = find_class cname in
      match List.find_opt (fun m -> m.method_name = f) cls.methods with
      | Some m -> m
      | None -> 
        (match cls.parent with
         | Some pname -> find_method pname
         | None -> raise (Error ("Method not found: " ^ f)))
    in
  
    (* Retrieve la methode et prepare its environment *)
    let meth = find_method this.cls in
    let lenv = Hashtbl.create 16 in
    (* Ajouter l'objet courant (this) *)
    Hashtbl.add lenv "this" (VObj this);
    (* Ajouter les paramètres *)
    List.iter2 (fun (param, _) arg -> Hashtbl.add lenv param arg) meth.params args;
    (* Ajouter les variables locales *)
    List.iter (fun (local, _) -> Hashtbl.add lenv local Null) meth.locals;
    (* Exécuter le corps de la méthode *)
    try
      exec_seq meth.code lenv;
      Null
    with
    | Return v -> v

  (* Execute a sequence of instructions *)
  and exec_seq s lenv =
    let rec evali e = match eval e with
      | VInt n -> n
      | _ -> assert false
    and evalb e = match eval e with
      | VBool b -> b
      | _ -> assert false
    and evalo e = match eval e with
      | VObj o -> o
      | _ -> assert false
        
    and eval (e: expr): value = match e with
      | Int n -> VInt n
      | Bool b -> VBool b
      | Unop (Opp, e) -> VInt (- evali e)
      | Unop (Not, e) -> VBool (not (evalb e))
      | Binop (op, e1, e2) -> begin
          match op, eval e1, eval e2 with
          | Add, VInt v1, VInt v2 -> VInt (v1 + v2)
          | Sub, VInt v1, VInt v2 -> VInt (v1 - v2)
          | Mul, VInt v1, VInt v2 -> VInt (v1 * v2)
          | Div, VInt v1, VInt v2 -> if v2 = 0 then raise (Error "Division by zero") else VInt (v1 / v2)
          | Rem, VInt v1, VInt v2 -> 
            if v2 = 0 then raise (Error "Modulo by zero") else VInt (v1 mod v2)
          | And, VBool b1, VBool b2 -> VBool (b1 && b2)
          | Or, VBool b1, VBool b2 -> VBool (b1 || b2)
          | Eq, v1, v2 -> VBool (v1 = v2)
          | Neq, v1, v2 -> VBool (v1 <> v2)
          | Lt, VInt v1, VInt v2 -> VBool (v1 < v2)
          | Le, VInt v1, VInt v2 -> VBool (v1 <= v2)
          | Gt, VInt v1, VInt v2 -> VBool (v1 > v2)
          | Ge, VInt v1, VInt v2 -> VBool (v1 >= v2)
          | _ -> raise (Error "Invalid operands")
        end
        | Get mem_access -> begin
          match mem_access with
          | Var x -> 
              (try Hashtbl.find lenv x 
               with Not_found -> raise (Error ("Undefined variable: " ^ x)))
          | Field (obj_expr, field) -> 
              (match evalo obj_expr with
              | { cls; fields } -> 
                  (try Hashtbl.find fields field 
                   with Not_found -> raise (Error ("Undefined field: " ^ field))))
        end
      | This -> (try Hashtbl.find lenv "this" with Not_found -> raise (Error "This is not defined"))
      | New cname ->
          let obj = { cls = cname; fields = Hashtbl.create 16 } in
          VObj obj
      | NewCstr (cname, args) ->
          let obj = eval (New cname) in
          (match obj with
          | VObj o -> 
            let _ = eval_call "constructor" o (List.map eval args) in
            obj        
           | _ -> raise (Error "Constructor call failed"))
      | MethCall (obj_expr, mname, args) ->
          let obj = evalo obj_expr in
          if mname = "constructor" && obj.cls <> "" then
            let parent_cls =
              try List.find (fun c -> c.class_name = obj.cls) p.classes
              with Not_found -> raise (Error"Parent class not found for object")
            in
            eval_call mname obj (List.map eval args)
          else
            eval_call mname obj (List.map eval args)
        | InstanceOf (obj_expr, tname) ->
          let obj = eval obj_expr in
          (match obj with
          | VObj { cls } ->
              let rec is_subtype child parent =
                if child = parent then true
                else
                  match List.find_opt (fun cls -> cls.class_name = child) p.classes with
                  | Some cls -> (match cls.parent with Some pname -> is_subtype pname parent | None -> false)
                  | None -> false
              in
              VBool (is_subtype cls tname)
          | Null -> VBool false
          | _ -> raise (Error "Left operand of instanceof must be an object"))
          
    in
    
    (* Execute a single instruction *)
    let rec exec (i: instr): unit = match i with
      | Print e -> Printf.printf "%d\n" (evali e)
      | Set (mem, e) -> begin
        match mem with
        | Var x -> Hashtbl.replace lenv x (eval e)
        | Field (obj_expr, field) -> begin
            match evalo obj_expr with
            | { fields; _ } -> Hashtbl.replace fields field (eval e)
          end
      end
    | If (cond, s1, s2) ->
        if evalb cond then exec_seq s1 else exec_seq s2
    | While (cond, s) ->
        while evalb cond do
          exec_seq s
        done
    | Return e -> raise (Return (eval e))
    | Expr e -> ignore (eval e)
    and exec_seq s = 
      List.iter exec s
    in

    exec_seq s
  in
  
  exec_seq p.main (Hashtbl.create 1)