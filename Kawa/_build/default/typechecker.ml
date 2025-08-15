open Kawa

exception Error of string
let error s = raise (Error s)
let type_error ty_actual ty_expected =
  error (Printf.sprintf "expected %s, got %s"
           (typ_to_string ty_expected) (typ_to_string ty_actual))

module Env = Map.Make(String)
type tenv = typ Env.t

let add_env l tenv =
  List.fold_left (fun env (x, t) -> Env.add x t env) tenv l

(* Vérification du programme *)
let typecheck_prog p =

  let tenv = add_env p.globals Env.empty in

  (* Function to check the type of an expression against an expected type *)
  let rec check e typ tenv =
    let typ_e = type_expr e tenv in
    if not (typ_e = typ || (match typ_e, typ with
        | TClass child, TClass parent ->
          let rec find_parent cname =
            match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
            | Some cls -> (match cls.parent with
                           | Some pname -> pname = parent || find_parent pname
                           | None -> false)
            | None -> false
          in find_parent child
        | _ -> false))
    then type_error typ_e typ

  (* Vérification des expressions *)
  and type_expr e tenv = match e with
    | Int _ -> TInt
    | Bool _ -> TBool
    | Unop (Not, e) ->
      let t = type_expr e tenv in
      if t = TBool then TBool
      else type_error t TBool
    | Unop (Opp, e) ->
      let t = type_expr e tenv in
      if t = TInt then TInt else type_error t TInt
    (* Handle binary operations *)
    | Binop (op, e1, e2) ->
      let t1 = type_expr e1 tenv in
      let t2 = type_expr e2 tenv in
      Printf.printf "DEBUG: Binop '%s' -> t1: %s, t2: %s\n"
      (match op with
       | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/" | Rem -> "%"
       | Lt -> "<" | Le -> "<=" | Gt -> ">" | Ge -> ">=" | Eq -> "==" | Neq -> "!="
       | And -> "&&" | Or -> "||")
      (typ_to_string t1) (typ_to_string t2);
      begin match op with
      | Add | Sub | Mul | Div | Rem ->
          if t1 = TInt && t2 = TInt then TInt
          else error (Printf.sprintf "Arithmetic operation expects int, but got %s and %s"
                        (typ_to_string t1) (typ_to_string t2))
      | Lt | Le | Gt | Ge -> 
          if t1 = TInt && t2 = TInt then TBool
          else error (Printf.sprintf "Comparison expects int, but got %s and %s"
                        (typ_to_string t1) (typ_to_string t2))
      | Eq | Neq ->
        if t1 = t2 || (match t1, t2 with
          | TClass c1, TClass c2 ->
            let rec find_parent cname =
              match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
              | Some cls -> (match cls.parent with
                             | Some pname -> pname = c2 || find_parent pname
                             | None -> false)
              | None -> false
            in find_parent c1 || find_parent c2
          | _ -> false)
        then TBool
        else error (Printf.sprintf "Equality comparison expects compatible types, but got %s and %s"
                  (typ_to_string t1) (typ_to_string t2))
      | And | Or ->
          if t1 = TBool && t2 = TBool then TBool
          else error (Printf.sprintf "Logical operation expects bool, but got %s and %s"
                        (typ_to_string t1) (typ_to_string t2))
      end
      | This -> 
        (* Handle the 'this' keyword, ensuring it's used within a class *)
        (match Env.find_opt "this" tenv with
         | Some (TClass cname) -> TClass cname
         | _ -> error "'this' used outside of a class")
      (* Handle object instantiation and constructor calls *)
      | New cname ->
        if List.exists (fun cls -> cls.class_name = cname) p.classes then TClass cname
        else error ("Undefined class: " ^ cname)
      | NewCstr (cname, args) ->
        (* Check for constructor validity and argument compatibility *)
        (match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
        | Some cls ->
            (match List.find_opt (fun m -> m.method_name = "constructor") cls.methods with
            | Some ctor ->
                if List.length ctor.params <> List.length args then
                  error ("Constructor for class " ^ cname ^ " expects "
                          ^ string_of_int (List.length ctor.params) ^ " arguments, got "
                          ^ string_of_int (List.length args))
                else
                  List.iter2 (fun (_, expected) arg ->
                    let actual = type_expr arg tenv in
                    if not (actual = expected || (match actual, expected with
                    | TClass child, TClass parent ->
                      let rec find_parent cname =
                        match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
                        | Some cls -> (match cls.parent with
                                        | Some pname -> pname = parent || find_parent pname
                                        | None -> false)
                        | None -> false
                      in find_parent child
                    | _ -> false))
                    then type_error actual expected
                  ) ctor.params args;
                TClass cname
            | None -> error ("Class " ^ cname ^ " does not have a constructor"))
        | None -> error ("Undefined class: " ^ cname))
      (* Handle method calls and type-check their parameters *)
      | MethCall (obj, mname, args) ->
          (match type_expr obj tenv with
          | TClass cname ->
              (match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
              | Some cls ->
                  (match List.find_opt (fun m -> m.method_name = mname) cls.methods with
                  | Some meth ->
                      if List.length meth.params <> List.length args then
                        error ("Method " ^ mname ^ " in class " ^ cname
                                ^ " expects " ^ string_of_int (List.length meth.params)
                                ^ " arguments, got " ^ string_of_int (List.length args))
                      else
                        List.iter2 (fun (_, expected) arg ->
                          let actual = type_expr arg tenv in
                          if not (actual = expected || (match actual, expected with
                          | TClass child, TClass parent ->
                            let rec find_parent cname =
                              match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
                              | Some cls -> (match cls.parent with
                                              | Some pname -> pname = parent || find_parent pname
                                              | None -> false)
                              | None -> false
                            in find_parent child
                          | _ -> false))
                          then type_error actual expected
                        ) meth.params args;
                      meth.return
                  | None -> error ("Undefined method: " ^ mname ^ " in class " ^ cname))
              | None -> error ("Undefined class: " ^ cname))
          | _ -> error ("Method call " ^ mname ^ " on non-object type"))
      | Get mem -> type_mem_access mem tenv
      (* Handle instanceof checks *)
      | InstanceOf (obj_expr, tname) ->
        let obj_type = type_expr obj_expr tenv in
        (match obj_type with
        | TClass cname ->
            if List.exists (fun cls -> cls.class_name = tname) p.classes then TBool
            else error ("Undefined class in instanceof: " ^ tname)
        | _ -> error "Left operand of instanceof must be an object")
  (* Vérification des accès mémoire *)
  and type_mem_access m tenv = match m with
    | Var v ->
        (match Env.find_opt v tenv with
        | Some t -> t
        | None -> error ("Undefined variable: " ^ v))
    | Field (obj, field) ->
      (* Handle field access, respecting visibility rules *)
        (match type_expr obj tenv with
        | TClass cname ->
            let rec find_in_hierarchy cname =
              match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
              | Some cls ->
                  (match List.find_opt (fun (name, _, _, vis) -> name = field) cls.attributes with
                  | Some (_, t, _, Public) -> Some t
                  | Some (_, t, _, Private) ->
                      (match Env.find_opt "this_cls" tenv with
                        | Some (TClass this_cls) when cname = this_cls -> Some t
                        | _ -> error ("Cannot access private attribute '" ^ field ^ "' in class '" ^ cname ^ "'"))
                  | Some (_, t, _, Protected) ->
                    (match Env.find_opt "this_cls" tenv with
                    | Some (TClass this_cls) when this_cls = cname -> Some t
                    | Some (TClass this_cls) ->
                        let rec is_subclass current target =
                          if current = target then true
                          else match List.find_opt (fun cls -> cls.class_name = current) p.classes with
                               | Some cls -> (match cls.parent with
                                              | Some parent -> is_subclass parent target
                                              | None -> false)
                               | None -> false
                        in
                        if is_subclass this_cls cname then Some t
                        else error ("Cannot access protected attribute '" ^ field ^ "' in class '" ^ cname ^ "'"))
                  | None -> (match cls.parent with
                            | Some parent_name -> find_in_hierarchy parent_name
                            | None -> None))
              | None -> None
            in
            (match find_in_hierarchy cname with
            | Some t -> t
            | None -> error ("Undefined field: " ^ field ^ " in class " ^ cname))
        | _ -> error "Field access on non-object type")

  in
  (* Vérification des instructions *)
  let rec check_instr i ret tenv = match i with
    | Print e -> check e TInt tenv
    | Set (mem, e) ->
      let t_mem = type_mem_access mem tenv in
      let t_expr = type_expr e tenv in
      if not (t_mem = t_expr || (match t_expr, t_mem with
      | TClass child, TClass parent ->
        let rec find_parent cname =
          match List.find_opt (fun cls -> cls.class_name = cname) p.classes with
          | Some cls -> (match cls.parent with
                        | Some pname -> pname = parent || find_parent pname
                        | None -> false)
          | None -> false
        in find_parent child
      | _ -> false))
      then type_error t_expr t_mem
    | If (cond, s1, s2) ->
        check cond TBool tenv;
        check_seq s1 ret tenv;
        check_seq s2 ret tenv
    | While (cond, s) ->
        check cond TBool tenv;
        check_seq s ret tenv
    | Return e ->
        check e ret tenv
    | Expr e ->
        ignore (type_expr e tenv)

  (* Vérification des séquences d'instructions *)
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  
  in

  (* Vérification des attributs `final` dans le constructeur *)
  let check_final_attributes cls constructor =
    (* Récupérez les attributs marqués comme `final` *)
    let final_attrs = List.filter (fun (_, _, is_final, _) -> is_final) cls.attributes in
    (* Vérifiez que chaque attribut final est initialisé dans le constructeur *)
    List.iter (fun (name, _, _, _) ->
      if not (List.exists (fun instr ->
        match instr with
        | Set (Field (This, attr), _) when attr = name -> true
        | _ -> false
      ) constructor.code) then
        error (Printf.sprintf "Final attribute '%s' is not initialized in the constructor of class '%s'" name cls.class_name)
    ) final_attrs

  in 
 
  (* Verify class definitions, including inheritance constraints *)
  let check_class cls classes =
    begin match cls.parent with
    | Some parent_name ->
        let parent = 
          try List.find (fun c -> c.class_name = parent_name) classes
          with Not_found -> error ("Parent class not found: " ^ parent_name)
        in
        (* Vérifiez que les attributs hérités ne sont pas redéfinis *)
        List.iter (fun (name, _, _, _) ->
          if List.exists (fun (n, _, _, _) -> n = name) parent.attributes then
            error ("Attribute " ^ name ^ " is redefined in " ^ cls.class_name)
        ) cls.attributes;

        (* Vérifiez les méthodes héritées *)
        List.iter (fun meth ->
          if meth.method_name = "constructor" then ()
          else match List.find_opt (fun m -> m.method_name = meth.method_name) parent.methods with
          | Some parent_meth ->
              if meth.params <> parent_meth.params || meth.return <> parent_meth.return then
                error ("Method " ^ meth.method_name ^ " in " ^ cls.class_name ^ " does not match the parent class signature.")
          | None -> ()
        ) cls.methods;
    | None -> ()
    end;

    (* Vérifiez le constructeur de la classe *)
    match List.find_opt (fun m -> m.method_name = "constructor") cls.methods with
    | Some constructor -> check_final_attributes cls constructor
    | None -> ()  (* Pas de constructeur, rien à vérifier *)


    and check_mdef mdef cls_name =
      let tenv = Env.add "this" (TClass cls_name) Env.empty in
      let tenv = Env.add "this_cls" (TClass cls_name) tenv in  (* Ajout de la classe courante *)
      let tenv = add_env mdef.params (add_env mdef.locals tenv) in
      List.iter (fun instr -> check_instr instr mdef.return tenv) mdef.code    
  in

  (* Vérifiez les classes *)
  List.iter (fun cls -> check_class cls p.classes) p.classes;

  (* Vérifiez les méthodes *)
  List.iter (fun cls -> List.iter (fun m -> check_mdef m cls.class_name) cls.methods) p.classes;

  (* Vérification de la séquence principale *)
  check_seq p.main TVoid tenv
