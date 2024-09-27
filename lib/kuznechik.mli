module Cipher : sig
  type t = {key: int array; ik: int array array}

  val make : int array -> t
  (** [make key] creates instance of [Cipher.t] using provided [key]*)

  val encrypt_block :
       t (** cipher instance *)
    -> int array (** 128-bit block value *)
    -> int array
  (** [encrypt_block cipher block] encrypts one [block] of 128-bit using provided [cipher]*)

  val decrypt_block :
       t (** cipher instance *)
    -> int array (** 128-bit encrypted block value *)
    -> int array
  (** [decrypt_block cipher enc_block] decrypts one encrypted block [enc_block] of 128-bit using provided [cipher]*)
end
