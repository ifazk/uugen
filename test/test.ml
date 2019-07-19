(** Tests for [Uutf_gen] *)

let abc = "abc"
let abc_list = Uchar.[of_char 'a'; of_char 'b'; of_char 'c']

let malformed = "\255"

let abc_mal = abc ^ malformed
let abc_rep_list = abc_list @ [Uutf.u_rep]

let test1 () =
  let decoder = Uutf.decoder (`String abc) in
  let list = Gen.to_list (Uugen.Uutf_gen.to_raw ~decoder) in
  if list = abc_list then
    ()
  else
    failwith "test1 failed"

let test2 () =
  let decoder = Uutf.decoder (`String malformed) in
  try
    let _ = Gen.to_list (Uugen.Uutf_gen.to_raw ~decoder) in
    failwith "test2 failed"
  with
  | Uugen.Uutf_gen.Malformed _ -> ()

let test3 () =
  let decoder = Uutf.decoder (`String abc_mal) in
  let list = Gen.to_list (Uugen.Uutf_gen.to_replacing ~decoder) in
  if list = abc_rep_list then
    ()
  else
    failwith "test3 failed"

let () =
  ( test1 ()
  ; test2 ()
  ; test3 ()
  )

(** Tests for [Uuseg_gen] *)

let abc_abc = abc ^ " " ^ abc
let abc_list = Uchar.[`Uchar (of_char 'a'); `Uchar (of_char 'b'); `LastUchar (of_char 'c')]
let space_list = Uchar.[`LastUchar (of_char ' ')]
let abc_abc_list = abc_list @ space_list @ abc_list

let abc_mal_abc_mal = abc_mal ^ " " ^ abc_mal
let abcr_list = Uchar.[`Uchar (of_char 'a'); `Uchar (of_char 'b'); `LastUchar (of_char 'c'); `LastUchar Uutf.u_rep]
let abcr_abcr_list = abcr_list @ space_list @ abcr_list

let test4 () =
  let decoder = Uutf.decoder (`String abc_abc) in
  let boundary = `Word in
  let chars = Uugen.Uutf_gen.to_raw ~decoder in
  let gen = Uugen.Uuseg_gen.of_chars ~boundary ~chars in
  let list = Gen.to_list gen in
  if list = abc_abc_list then
    ()
  else
    failwith "test4 failed"

let test5 () =
  let decoder = Uutf.decoder (`String abc_mal_abc_mal) in
  let boundary = `Word in
  let chars = Uugen.Uutf_gen.to_replacing ~decoder in
  let gen = Uugen.Uuseg_gen.of_chars ~boundary ~chars in
  let list = Gen.to_list gen in
  if list = abcr_abcr_list then
    ()
  else
    failwith "test5 failed"

let test6 () =
  let decoder = Uutf.decoder (`String abc_mal_abc_mal) in
  let boundary = `Word in
  let chars = Uugen.Uutf_gen.to_raw ~decoder in
  let gen = Uugen.Uuseg_gen.of_chars ~boundary ~chars in
  try
    let _ = Gen.to_list gen in
    failwith "test6 failed"
  with
  | Uugen.Uutf_gen.Malformed _ -> ()

let () =
  ( test4 ()
  ; test5 ()
  ; test6 ()
  )
