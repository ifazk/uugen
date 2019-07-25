type raw = Uchar.t Gen.t
type safe = [ `Await | `Malformed of string | `Uchar of Uchar.t ] Gen.t
type safe_auto = [ `Malformed of string | `Uchar of Uchar.t ] Gen.t

exception Malformed of {line: int; col: int; byte_count: int; src: Uutf.src; bytes:string}
exception Await of {line: int; col: int; byte_count: int; src: Uutf.src}

type uutf_ret_no_end = [ `Await | `Malformed of string | `Uchar of Uchar.t ]

let malformed (decoder : Uutf.decoder) bytes =
  let line = Uutf.decoder_line decoder in
  let col = Uutf.decoder_col decoder in
  let byte_count = Uutf.decoder_count decoder in
  let src = Uutf.decoder_src decoder in
  Malformed {line;col;byte_count;src;bytes}

let await (decoder : Uutf.decoder) =
  let line = Uutf.decoder_line decoder in
  let col = Uutf.decoder_col decoder in
  let byte_count = Uutf.decoder_count decoder in
  let src = Uutf.decoder_src decoder in
  Await {line;col;byte_count;src}

let to_safe ~(decoder: Uutf.decoder) : [ `Await | `Malformed of string | `Uchar of Uchar.t ] Gen.gen =
  let g () =
    match Uutf.decode decoder with
    | `End -> None
    | #uutf_ret_no_end as e -> Some e
  in
  g

let safe_of_auto ~(decoder:Uutf.decoder) : safe_auto =
  let g () =
    match Uutf.decode decoder with
    | `End -> None
    | `Uchar _ as e -> Some e
    | `Await -> raise @@ await decoder
    | `Malformed _ as e -> Some e
  in
  g

let to_raw ~(decoder: Uutf.decoder): raw =
  let gen () =
    match Uutf.decode decoder with
    | `End -> None
    | `Uchar c -> Some c
    | `Await -> raise @@ await decoder
    | `Malformed bytes -> raise @@ malformed decoder bytes
  in
  gen

let to_replacing ~(decoder: Uutf.decoder): raw =
  let gen () =
    match Uutf.decode decoder with
    | `End -> None
    | `Uchar c -> Some c
    | `Await -> raise @@ await decoder
    | `Malformed _ -> Some Uutf.u_rep
  in
  gen

module Utf8 = struct
  let decoder ?nln ~src =
    Uutf.decoder ?nln ~encoding:`UTF_8 src

  let safe_of_auto ?nln ~(src:[< `Channel of in_channel | `String of string ]) =
    safe_of_auto ~decoder:(decoder ?nln ~src)

  let to_raw ?nln ~src : raw =
    to_raw ~decoder:(decoder ?nln ~src)

  let to_replacing ?nln ~src : raw =
    to_replacing ~decoder:(decoder ?nln ~src)

  module String = struct
    let to_safe ?nln str =
      safe_of_auto ?nln ~src:(`String str)

    let to_raw ?nln str : raw =
      to_raw ?nln ~src:(`String str)

    let to_replacing ?nln str : raw =
      to_replacing ?nln ~src:(`String str)
  end

  module Channel = struct
    let to_safe ?nln chan =
      safe_of_auto ?nln ~src:(`Channel chan)

    let to_raw ?nln chan : raw =
      to_raw ?nln ~src:(`Channel chan)

    let to_replacing ?nln chan : raw =
      to_replacing ?nln ~src:(`Channel chan)
  end

end
