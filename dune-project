(lang dune 3.16)

(name kuznechik)

(generate_opam_files true)

(source
 (github beldmian/kuznechik))

(authors "Belousov Dmitry")

(maintainers "Belousov Dmitry")

(license MIT)

(documentation https://github.com/beldmian/kuznechik)

(package
 (name kuznechik)
 (synopsis "Implementation of Kuzneechik cipher")
 (description "Implementation of Kuznechik block cipher from Russian GOST standart")
 (depends ocaml dune))
