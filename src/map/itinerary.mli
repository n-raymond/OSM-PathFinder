
(** Itinerary

    Module which takes a map data structure and
    generate the shortest way data structure. *)



module type ItineraryType =
sig

  val cost_type : [ `Distance | `Time ]
  (* The kind of cost required for the itinerary *)

  val vehicule_type : [ `Motorized | `Bicycle | `Pedestrian ]
  (* The kind of vehicule required for the itinerary *)

  val map : MapData.Roads.t
  (* The map on which the itinerary search is operated *)

end

module type S =
sig
  type t = float * (MapData.node_id * float) list
  (** The type of itinerary give a data structure representing
      the shortest way between two points *)

  exception Unattainable

  val from_map: MapData.node_id -> MapData.node_id -> t
  (** [Itinerary.from_map map beg end] creates a new itinerary,
      representing the shortest way considering the current map
      [map] between a beginning node_id [beg] and an ending node_id
      [end]. Raises [Astar.Unatainable] if the goal is not
      atainable. *)

end

module Make (IT : ItineraryType) : S

