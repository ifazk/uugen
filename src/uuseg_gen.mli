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

module Grapheme_cluster : sig
  (** This module includes some convenience functions for working with grapheme
     cluster boundaries. These generators produce [`Uchar c] if [c] is not the
     last character of a grapheme cluster and produce [`LastUchar c] if [c] is
     the last character of a grapheme cluster. *)

  val of_chars : chars:Uchar.t Gen.t -> t
  val of_decoder_exn : decoder:Uutf.decoder -> t
  val of_decoder_replacing : decoder:Uutf.decoder -> t

  module Utf8 : sig
    (** This module includes some convenience functions for working with utf8
       encoded strings and channels with grapheme cluster boundaries. These
       generators produce [`Uchar c] if [c] is not the last character of a
       grapheme cluster and produce [`LastUchar c] if [c] is the last character
       of a grapheme cluster. *)

      val of_string_exn : ?nln:[< Uutf.nln ] -> string -> t
      (** [of_string_exn ?nln str] generates the unicode codepoints of the utf8
         encoded string [str], normalizing newlines with [?nln] and indicating
         the grapheme cluster boundaries. It uses [Uutf_gen.raw_of_decoder]
         internally, so calling the resulting generator can throw exceptions of
         the form [Uutf_gen.Malformed] if [str] contains malformed bytes. *)

      val of_string_replacing : ?nln:[< Uutf.nln ] -> string -> t
      (** [of_string_replacing ?nln str] generates the unicode codepoints of the
         utf8 encoded string [str], normalizing newlines with [?nln] and
         indicating the grapheme cluster boundaries. If [str] contains malformed
         bytes, it will replace them with the unicode replacement character. *)

      val of_in_channel_exn : ?nln:[< Uutf.nln ] -> in_channel -> t
      (** [of_in_channel_exn ?nln chan] generates the unicode codepoints of the utf8
         encoded channel [chan], normalizing newlines with [?nln] and indicating
         the grapheme cluster boundaries. It uses [Uutf_gen.raw_of_decoder]
         internally, so calling the resulting generator can throw exceptions of
         the form [Uutf_gen.Malformed] if [chan] contains malformed bytes. *)

      val of_in_channel_replacing : ?nln:[< Uutf.nln ] -> in_channel -> t
      (** [of_in_channel_replacing ?nln chan] generates the unicode codepoints
         of the utf8 encoded channel [chan], normalizing newlines with [?nln]
         and indicating the grapheme cluster boundaries. If [chan] contains
         malformed bytes, it will replace them with the unicode replacement
         character. *)

    end
end
