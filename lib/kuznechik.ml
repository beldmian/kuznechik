(* Utils and types *)
open! Core

(* X Transition *)

let x_trans (a : int array) (b : int array) : int array =
  Array.mapi a ~f:(fun i a_el -> a_el lxor Array.unsafe_get b i)

(* S Transition and Inverse S Transition*)

let s_generic_trans (l : int array) (a : int array) : int array =
  a |> Array.map ~f:(fun x -> Array.unsafe_get l x)

let s_trans : int array -> int array = s_generic_trans Trans_luts.pi_table

let s_inv_trans : int array -> int array =
  s_generic_trans Trans_luts.pi_inv_table

(* LS Transition and Inverse SL Transition*)

let rec _l_trans_inner (a : int array) (pos : int) (v : int) (i : int) : int
    =
  match i with
  | 0 -> v
  | _ ->
      _l_trans_inner a pos
        ( v
        lxor Bigarray.Array3.unsafe_get Trans_luts.l_trans_table
               (Array.unsafe_get a (i - 1))
               (i - 1) pos )
        (i - 1)

let l_trans (a : int array) : int array =
  Array.init 16 ~f:(fun i -> _l_trans_inner a i 0 16)

let rec _l_inv_trans_inner (a : int array) (pos : int) (v : int) (i : int) :
    int =
  match i with
  | 0 -> v
  | _ ->
      _l_inv_trans_inner a pos
        ( v
        lxor Bigarray.Array3.unsafe_get Trans_luts.l_inv_trans_table
               (Array.unsafe_get a (i - 1))
               (i - 1) pos )
        (i - 1)

let l_inv_trans (a : int array) : int array =
  Array.init 16 ~f:(fun i -> _l_inv_trans_inner a i 0 16)

let rec _slx_trans_inner (a : int array) (pos : int) (v : int) (i : int) :
    int =
  match i with
  | 0 -> v
  | _ ->
      _slx_trans_inner a pos
        ( v
        lxor Bigarray.Array3.unsafe_get Trans_luts.sl_trans_table
               (Array.unsafe_get a (i - 1))
               (i - 1) pos )
        (i - 1)

let slx_trans (key : int array) (a : int array) : int array =
  Array.init 16 ~f:(fun i ->
      _slx_trans_inner a i 0 16 lxor Array.unsafe_get key i )

let rec _slx_inv_trans_inner (a : int array) (pos : int) (v : int) (i : int)
    : int =
  match i with
  | 0 -> v
  | _ ->
      _slx_inv_trans_inner a pos
        ( v
        lxor Bigarray.Array3.unsafe_get Trans_luts.sl_inv_trans_table
               (Array.unsafe_get a (i - 1))
               (i - 1) pos )
        (i - 1)

let slx_inv_trans (key : int array) (a : int array) : int array =
  Array.init 16 ~f:(fun i ->
      _slx_inv_trans_inner a i 0 16 lxor Array.unsafe_get key i )

(* Round constants computation *)

let round_constants : int array array =
  Array.sub ~pos:1 ~len:32
    (Array.init 33 ~f:(fun i ->
         Array.append (Array.create ~len:15 0) (Array.create ~len:1 i)
         |> l_trans ) )

(* Key extension *)

let f_trans (k1 : int array) (k2 : int array) (iter_const : int array) :
    int array * int array =
  (k1 |> x_trans iter_const |> slx_trans k2, k1)

let make_iter_keys (k1 : int array) (k2 : int array)
    (round_const : int array array) : int array array =
  Sequence.take
    ( Sequence.append
        (Sequence.singleton ((k1, k2), 0))
        (Sequence.unfold
           ~init:((k1, k2), 0)
           ~f:(fun ((ik1, ik2), i) ->
             let new_val =
               (f_trans ik1 ik2 (Array.get round_const i), i + 1)
             in
             Option.some (new_val, new_val) ) )
    |> Sequence.filter ~f:(fun (_, i) -> i mod 8 = 0) )
    5
  |> Sequence.map ~f:(fun ((ik1, ik2), _) -> [ik1; ik2])
  |> Sequence.to_list |> List.concat |> Array.of_list

(* Encrypt and Decrypt *)

module Cipher = struct
  type t = {key: int array; ik: int array array; ik_inv: int array array}

  let make (key : int array) : t =
    let ik =
      make_iter_keys
        (Array.sub key ~pos:0 ~len:16)
        (Array.sub key ~pos:16 ~len:16)
        round_constants
    in
    {key; ik; ik_inv= Array.map ik ~f:l_inv_trans}

  let rec _encrypt_block_inner (ik : int array array) (x : int array)
      (i : int) : int array =
    match i with
    | 10 -> x
    | _ ->
        _encrypt_block_inner ik
          (x |> slx_trans (Array.unsafe_get ik i))
          (i + 1)

  let encrypt_block (cipher : t) (msg : int array) : int array =
    _encrypt_block_inner cipher.ik
      (msg |> x_trans (Array.unsafe_get cipher.ik 0))
      1

  let rec _decrypt_block_inner (ik_inv : int array array) (x : int array)
      (i : int) : int array =
    match i with
    | 9 -> x
    | _ ->
        _decrypt_block_inner ik_inv
          (x |> slx_inv_trans (Array.unsafe_get ik_inv (9 - i)))
          (i + 1)

  let decrypt_block (cipher : t) (msg : int array) : int array =
    _decrypt_block_inner cipher.ik_inv (msg |> s_trans) 0
    |> s_inv_trans
    |> x_trans (Array.unsafe_get cipher.ik 0)
end
