(lang dune 1.10)
(generate_opam_files true)

(name uugen)
(version 0.1.0)
(source (github ifazk/uugen))
(license CC0-1.0)
(authors "Ifaz Kabir")
(maintainers "ifazk@users.noreply.github.com")
(documentation https://ifazk.github.io/uugen/)

(package
 (name uugen)
 (synopsis "Generators for uutf and uuseg")
 (description "Convert uutf and uuseg decoders into generators")
 (depends
  (dune (and :build (> 1.10)))
  uutf
  uuseg
  gen
  (ocaml (> 4.01))))
