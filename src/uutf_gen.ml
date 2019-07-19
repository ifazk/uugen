exception Malformed of {line: int; col: int; byte_count: int; src: Uutf.src; str:string}
exception Await of {line: int; col: int; byte_count: int; src: Uutf.src}

type uutf_ret_no_end = [ `Await | `Malformed of string | `Uchar of Uchar.t ]

let malformed (decoder : Uutf.decoder) str =
  let line = Uutf.decoder_line decoder in
  let col = Uutf.decoder_col decoder in
  let byte_count = Uutf.decoder_count decoder in
  let src = Uutf.decoder_src decoder in
  Malformed {line;col;byte_count;src;str}

let await (decoder : Uutf.decoder) =
  let line = Uutf.decoder_line decoder in
  let col = Uutf.decoder_col decoder in
  let byte_count = Uutf.decoder_count decoder in
  let src = Uutf.decoder_src decoder in
  Await {line;col;byte_count;src}

let char_gen_of_decoder (decoder : Uutf.decoder) : [ `Await | `Malformed of string | `Uchar of Uchar.t ] Gen.gen =
  let g () =
    match Uutf.decode decoder with
    | `End -> None
    | #uutf_ret_no_end as e -> Some e
  in
  g

let char_gen_exn_of_decoder (decoder : Uutf.decoder) : Uchar.t Gen.gen =
  let gen () =
    match Uutf.decode decoder with
    | `End -> None
    | `Uchar c -> Some c
    | `Await -> raise @@ await decoder
    | `Malformed s -> raise @@ malformed decoder s
  in
  gen
