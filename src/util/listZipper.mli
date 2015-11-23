
(**	List Zippers

    This module give an implementation of list zippers. *)



type 'a t
(**	The type of list zippers *)

exception Start
(**	Raised when the start of the zipper is reached *)

exception End
(**	Raised when the end of the zipper is reached *)

val empty : unit -> 'a t
(**	[ListZipper.empty ()] creates a new empty list zipper. *)

val from_list : 'a list -> 'a t
(**	[ListZipper.from_list l] creates a new zipper from the
    list [l]. *)

val to_list : 'a t -> 'a list
(**	[ListZipper.to_list z] creates a list from the zipper [z]. *)

val next : 'a t -> 'a t
(**	[ListZipper.next z] gives the zipper resulting when forwarding
    one step in the zipper [z]. Raises [End] when the zipper is
    at the final position. *)

val previous : 'a t -> 'a t
(**	[ListZipper.previous z] gives the zipper resulting when backwarding
    one step in the zipper [z]. Raises [Start] when the zipper is at the
    starting position. *)

val element : 'a t -> 'a
(**	[ListZipper.element z] gives the element at the position of
    zipper [z]. *)

val insert : 'a -> 'a t -> 'a t
(** [ListZipper.insert e z] inserts the element [e] in the zipper [z]
    at the actual position of the zipper. *)

val delete : 'a t -> 'a t
(**	[ListZipper.delete z] removes the element at the actual position
    in the zipper [z]. *)
