module type CLOCK = sig
  type tm = {
      tm_sec : int;
      tm_min : int;
      tm_hour : int;
      tm_mday : int;
      tm_mon : int;
      tm_year : int;
      tm_wday : int;
      tm_yday : int;
      tm_isdst : bool;
    }
  val time : unit -> float
  val gmtime : float -> tm
end

module type HASH = sig
  type p
  type t
  val init : p -> t
  val add_string : t -> string -> t
  val result : t -> string
end

module type MAC = sig
  include HASH with type p := string
  module Digest : HASH with type p := unit
end

module type RANDOM = sig
  val self_init : unit -> unit
  val int : int -> int
  val int32 : int32 -> int32
end
