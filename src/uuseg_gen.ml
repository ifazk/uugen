(* Auxilary types *)
type uuseg_add = [ `Await | `End | `Uchar of Uchar.t ]
type bounded = [ `Boundary | `Uchar of Uchar.t ]

type t = [ `LastUchar of Uchar.t | `Uchar of Uchar.t ] Gen.t

let next_char (chars: Uchar.t Gen.gen) : [`End | `Uchar of Uchar.t] =
  match Gen.next chars with
  | Some c -> `Uchar c
  | None -> `End

let bounded_gen (b: [< Uuseg.boundary ]) (chars: Uchar.t Gen.gen): bounded Gen.gen =
  let seg = Uuseg.create b in
  let seg_state: [`Out | `Await | `End] ref = ref `Await in
  let rec gen (): bounded option =
    match !seg_state with
    | `Await ->
      begin match Uuseg.add seg (next_char chars :> uuseg_add) with
        | `Await -> gen ()
        | `End -> (seg_state := `End; None)
        | (`Uchar _ as e) | (`Boundary as e) -> (seg_state := `Out; Some e)
      end
    | `End -> None
    | `Out ->
      begin match Uuseg.add seg `Await with
        | `Await as e -> (seg_state := e; gen ())
        | `End as e -> (seg_state := e; None)
        | (`Uchar _ as e) | (`Boundary as e) -> (seg_state := `Out; Some e)
      end
  in
  gen

let of_bounded_gen (chars: bounded Gen.gen): t =
  let next : Uchar.t option ref = ref None in
  let rec gen () =
    match !next with
    | None ->
      begin match Gen.next chars with
      | None -> None
      | Some `Boundary -> gen ()
      | Some (`Uchar c) -> (next := Some c; gen ())
      end
    | Some c ->
      begin match Gen.next chars with
        | None | Some `Boundary -> (next := None; Some (`LastUchar c))
        | Some (`Uchar c_nxt) -> (next := Some c_nxt); Some (`Uchar c)
      end
  in
  gen

let of_chars ~boundary ~chars =
  of_bounded_gen (bounded_gen boundary chars)

let of_decoder_exn ~boundary ~decoder =
  of_chars ~boundary ~chars:(Uutf_gen.to_raw ~decoder)

let of_decoder_replacing ~boundary ~decoder =
  of_chars ~boundary ~chars:(Uutf_gen.to_replacing ~decoder)
