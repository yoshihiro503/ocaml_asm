open Util
open Asm

let asm_code = [
  Directive ".file\t\"hello.cb\"";
  Directive "\t.section\t.rodata";
  Label (NamedSymbol ".LC0")
]

let tbl = ()

let _ =
  println @@ Asm.to_string tbl asm_code
