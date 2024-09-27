let key_test =
  [| 0x88 ; 0x99 ; 0xaa ; 0xbb
  ; 0xcc ; 0xdd ; 0xee ; 0xff
  ; 0x00 ; 0x11 ; 0x22 ; 0x33
  ; 0x44 ; 0x55 ; 0x66 ; 0x77
  ; 0xfe ; 0xdc ; 0xba ; 0x98
  ; 0x76 ; 0x54 ; 0x32 ; 0x10
  ; 0x01 ; 0x23 ; 0x45 ; 0x67
  ; 0x89 ; 0xab ; 0xcd ; 0xef |] [@@ocamlformat "disable"]

let block_test =
  [| 0x11 ; 0x22 ; 0x33 ; 0x44
  ; 0x55 ; 0x66 ; 0x77 ; 0x00
  ; 0xff ; 0xee ; 0xdd ; 0xcc
  ; 0xbb ; 0xaa ; 0x99 ; 0x88 |][@@ocamlformat "disable"]

let enc_block_test =
  [| 0x7f ; 0x67 ; 0x9d ; 0x90
  ; 0xbe ; 0xbc ; 0x24 ; 0x30
  ; 0x5a ; 0x46 ; 0x8d ; 0x42
  ; 0xb9 ; 0xd4 ; 0xed ; 0xcd |] [@@ocamlformat "disable"]

open! Core
open Core_bench

let () =
  Command_unix.run
    (Core_bench.Bench.make_command
       [ Bench.Test.create_parameterised ~name:"Encrypt block"
           ~args:[("basic_gost_key", Kuznechik.Cipher.make key_test)]
           (fun cipher ->
             Staged.stage (fun () ->
                 ignore (Kuznechik.Cipher.encrypt_block cipher block_test) )
             )
       ; Bench.Test.create_parameterised ~name:"Decrypt block"
           ~args:[("basic_gost_key", Kuznechik.Cipher.make key_test)]
           (fun cipher ->
             Staged.stage (fun () ->
                 ignore
                   (Kuznechik.Cipher.decrypt_block cipher enc_block_test) )
             ) ] ) ;
  Gc.print_stat stdout
