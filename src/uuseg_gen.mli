type t = [ `LastUchar of Uchar.t | `Uchar of Uchar.t ] Gen.t
(** The type for segmented generators. These generators produce [`Uchar c] if
   [c] is not at the end of a segment or produce [`LastUchar c] if [c] is the
   last character of a segment. *)

val of_chars : boundary:[< Uuseg.boundary ] -> chars:Uchar.t Gen.t -> t
(** [of_chars ~boundary ~chars] segments ~chars by ~boundary. *)

val of_decoder_exn : boundary:[< Uuseg.boundary ] -> decoder:Uutf.decoder -> t
(** [of_decoder_exn ~boundary ~chars] segments ~chars by ~boundary. It uses
   [Uutf_gen.raw_of_decoder] internally, so calling the resulting generator can
   throw exceptions of the form [Uutf_gen.Malformed] or [Uutf_gen.Await]. *)

val of_decoder_replacing : boundary:[< Uuseg.boundary ] -> decoder:Uutf.decoder -> t
(** [of_decoder_replacing ~boundary ~chars] segments ~chars by ~boundary,
   replacing malformed sequences of bytes with the unicode replacement
   character. It uses [Uutf_gen.replacing_of_decoder] internally, so calling the
   resulting generator can throw exceptions of the form [Uutf_gen.Await]. *)
