open Util

type symbol =
  | NamedSymbol of string
  | UnnamedSymbol
  | SuffixedSymbol of symbol * string (* base,suffix *)

let is_zero symbol = false (*TODO*)
type literal =
  | Int of int64
  | Symbol of symbol

type operand =
  | ImmediateValue of literal
  | DirectMemRef of literal
  | IndirectMemRef of symbol * register
  | Register of register
  | AbsoluteAddress of register
and register =
  | OperandPattern of operand

(* ============================== *)
type directive = string
type instruction = {
    mnemonic : string;
    need_relocation : bool;
    operands : operand list;
    suffix : string;
  }

(* ============================== *)
type asm_code = asm list
and asm =
  | Instruction of instruction
  | Directive of directive
  | Label of symbol
  | Comment of string

let to_string tbl code =
  let rec symb_to_string = function
    | NamedSymbol name -> name
    | UnnamedSymbol -> failwith "UnnamedSymbol"
    | SuffixedSymbol (base_symb, suffix) -> symb_to_string base_symb ^ suffix
  in
  let literal_to_string tbl = function
    | Int i -> Int64.to_string i
    | Symbol symb -> symb_to_string symb
  in
  let rec op_to_string tbl = function
    | ImmediateValue lit -> "$" ^ literal_to_string tbl lit
    | DirectMemRef lit -> literal_to_string tbl lit
    | IndirectMemRef (offset, base) ->
        if is_zero offset then "" else symb_to_string offset
        ^ !%"(%s)" (reg_to_string tbl base)
    | Register register -> reg_to_string tbl register
    | AbsoluteAddress register ->
        "*" ^ reg_to_string tbl register
  and reg_to_string tbl = function
    | OperandPattern op -> op_to_string tbl op
  in
  let inst_to_string tbl inst =
    inst.mnemonic ^ inst.suffix ^ "\t"
    ^ slist ", " (op_to_string tbl) inst.operands
  in
  let asm_to_string tbl = function
    | Instruction inst ->
        inst_to_string tbl inst
    | Directive dir -> dir
    | Label symb ->
        symb_to_string symb ^ ":"
    | Comment s -> "#" ^ s
  in
  slist "\n" (asm_to_string tbl) code
