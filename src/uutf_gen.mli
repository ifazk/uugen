exception Malformed of {line: int; col: int; byte_count: int; src: Uutf.src; str:string}
exception Await of {line: int; col: int; byte_count: int; src: Uutf.src}

val char_gen_of_decoder: Uutf.decoder -> [ `Await | `Malformed of string | `Uchar of Uchar.t ] Gen.t
val char_gen_exn_of_decoder: Uutf.decoder -> Uchar.t Gen.t
