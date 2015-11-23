
(** Nearest Neighboor

    Module to construct a data structure which can be used
    to find the nearest node. *)


module type S =
sig

  type t

  val find : float -> float -> t -> MapData.node_id
  (** [Nearest.find x y near] finds the nearest node_id with the
      given coordinates [x] [y] and the structure [near]. *)

end

module Basic : (S with type t = MapData.Roads.t)

module Preprocesed : (S with type t = NearTree.Nearee.t)
