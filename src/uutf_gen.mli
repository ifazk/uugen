type raw = Uchar.t Gen.t
type safe = [ `Await | `Malformed of string | `Uchar of Uchar.t ] Gen.t
type safe_auto = [ `Malformed of string | `Uchar of Uchar.t ] Gen.t
(** Types for [Uchar.t] generators. The functions in this module convert
   [Uutf.decoder]s into one of the above type of generators. *)

exception Malformed of {line: int; col: int; byte_count: int; src: Uutf.src; bytes:string}
(** Generators which are not allowed to return [`Malformed bytes] may throw a
   [Malformed] exception if calling [Uutf.decode] on the decoder returns some
   [`Malformed bytes]. *)

exception Await of {line: int; col: int; byte_count: int; src: Uutf.src}
(** Generators which are not allowed to return [`Await] may throw an [Await]
   exception if calling [Uutf.decode] on the decoder returns [`Await]. *)

val to_safe : decoder:Uutf.decoder -> safe
(** [to_safe ~decoder] converts [decoder] into a [safe] generator. *)

val safe_of_auto: decoder:Uutf.decoder -> safe_auto
(** [safe_of_auto ~decoder] converts [decoder] into a [safe_auto] generator.
   This is meant to be used on decoder created from a [`Channel of in_channel]
   or [`String of string]. See [Uutf] documentation for detals.

    Throws an [Await] exception if calling [Uutf.decode] on the decoder returns
   [`Await]. *)

val to_raw: decoder:Uutf.decoder -> raw
(** [to_raw ~decoder] converts [decoder] into a [raw] generator.

    Throws an [Await] exception if calling [Uutf.decode] on the decoder returns
   [`Await]. Does not throw [Await _] if decoder was created from a [`Channel of
   in_channel] or [`String of string]. See [Uutf] documentation for detals.

    Throws an [Malformed] exception if calling [Uutf.decode] on the decoder
   returns some [`Malformed bytes]. *)


val to_replacing: decoder:Uutf.decoder -> raw
(** [to_raw ~decoder] converts [decoder] into a [raw] generator. If the
   generator encounters some malformed bytes, it returns a unicode replacement
   character intsead.

    Throws an [Await] exception if calling [Uutf.decode] on the decoder returns
   [`Await]. Does not throw [Await _] if decoder was created from a [`Channel of
   in_channel] or [`String of string]. See [Uutf] documentation for detals. *)
