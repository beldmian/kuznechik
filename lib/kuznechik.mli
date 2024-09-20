val generate_key : bytes
(** [generate_key] generates random 256-bit key to be used in encryption and decription*)

val encrypt_block :
  bytes (** 256-bit key value *) -> bytes (** 128-bit block value *) -> bytes
(** [encrypt_block key block] encrypts one [block] of 128-bit using provided [key]*)

val decrypt_block :
     bytes (** 256-bit key value *)
  -> bytes (** 128-bit encrypted block value *)
  -> bytes
(** [decrypt_block key enc_block] decrypts one encrypted block [enc_block] of 128-bit using provided [key]*)
