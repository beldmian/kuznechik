let rec _gf_mul_step (a : int) (b : int) (c : int) (i : int) : int =
  match i with
  | 0 -> c
  | _ ->
      let a' =
        (a lsl 1)
        lxor ( a land 0x80
             lor ((a land 0x80) lsr 1)
             lor ((a land 0x80 lor ((a land 0x80) lsr 1)) lsr 2)
             lor ( a land 0x80
                 lor ((a land 0x80) lsr 1)
                 lor ((a land 0x80 lor ((a land 0x80) lsr 1)) lsr 2) )
                 lsr 4
             land 0xc3 )
      in
      let b' = b lsr 1 in
      let c' =
        c
        lxor ( b land 1
             lor ((b land 1) lsl 1)
             lor ((b land 1 lor ((b land 1) lsl 1)) lsl 2)
             lor ( b land 1
                 lor ((b land 1) lsl 1)
                 lor ((b land 1 lor ((b land 1) lsl 1)) lsl 2) )
                 lsl 4
             land a )
      in
      _gf_mul_step a' b' c' (i - 1)

let gf_mul (a : int) (b : int) = _gf_mul_step a b 0 8 mod 256

let gf_mul_table : int list list =
  List.init 256 (fun i -> List.init 256 (fun j -> gf_mul i j))

let () =
  let oc = open_out "gf_mul_table.ml" in
  Printf.fprintf oc
    "let gf_mul_table = Bigarray.Array1.of_array Bigarray.Int8_unsigned \
     Bigarray.C_layout [|" ;
  List.iter
    (fun subl -> List.iter (fun a -> Printf.fprintf oc "%d; " a) subl)
    gf_mul_table ;
  Printf.fprintf oc "|]"
