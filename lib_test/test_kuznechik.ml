(* Testing *)

let key_test_data =
  [ 0x88 ; 0x99 ; 0xaa ; 0xbb
  ; 0xcc ; 0xdd ; 0xee ; 0xff
  ; 0x00 ; 0x11 ; 0x22 ; 0x33
  ; 0x44 ; 0x55 ; 0x66 ; 0x77
  ; 0xfe ; 0xdc ; 0xba ; 0x98
  ; 0x76 ; 0x54 ; 0x32 ; 0x10
  ; 0x01 ; 0x23 ; 0x45 ; 0x67
  ; 0x89 ; 0xab ; 0xcd ; 0xef] [@@ocamlformat "disable"]

let key_test : bytes =
  Bytes.of_seq (List.to_seq key_test_data |> Seq.map (fun x -> Char.chr x))

let block_test_data =
  [ 0x11 ; 0x22 ; 0x33 ; 0x44
  ; 0x55 ; 0x66 ; 0x77 ; 0x00
  ; 0xff ; 0xee ; 0xdd ; 0xcc
  ; 0xbb ; 0xaa ; 0x99 ; 0x88 ][@@ocamlformat "disable"]

let block_test : bytes =
  Bytes.of_seq (List.to_seq block_test_data |> Seq.map (fun x -> Char.chr x))

let enc_block_test_data =
  [ 0x7f ; 0x67 ; 0x9d ; 0x90
  ; 0xbe ; 0xbc ; 0x24 ; 0x30
  ; 0x5a ; 0x46 ; 0x8d ; 0x42
  ; 0xb9 ; 0xd4 ; 0xed ; 0xcd ] [@@ocamlformat "disable"]

let enc_block_test : bytes =
  Bytes.of_seq
    (List.to_seq enc_block_test_data |> Seq.map (fun x -> Char.chr x))

let () =
  assert (
    Bytes.equal (Kuznechik.encrypt_block key_test block_test) enc_block_test )
;;

assert (
  Bytes.equal (Kuznechik.decrypt_block key_test enc_block_test) block_test )
;;

assert (
  Bytes.equal
    ( Kuznechik.encrypt_block key_test block_test
    |> Kuznechik.decrypt_block key_test )
    block_test )
