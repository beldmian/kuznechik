(lang dune 3.16)

(name kuznechik)

(generate_opam_files true)

(source
 (github beldmian/kuznechik))

(authors "Belousov Dmitry <me@beldmian.ru>")

(maintainers "Belousov Dmitry <me@beldmian.ru>")

(license MIT)

(documentation https://github.com/beldmian/kuznechik)

(package
 (name kuznechik)
 (synopsis "Implementation of Kuzneechik cipher")
 (description "Implementation of Kuznechik block cipher from Russian GOST standart")
 (depends
  (ocaml (>= "5.1.0"))
  dune
  (core (>= "v0.17.0"))
  (core_bench (>= "v0.17.0" :with-test))
  ))
