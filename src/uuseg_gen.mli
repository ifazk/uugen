type t = [ `LastUchar of Uchar.t | `Uchar of Uchar.t ] Gen.t

val of_chars : boundary:[< Uuseg.boundary ] -> chars:Uchar.t Gen.t -> t
val of_decoder_exn : boundary:[< Uuseg.boundary ] -> decoder:Uutf.decoder -> t
