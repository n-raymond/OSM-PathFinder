
(*
 * Open Street Map PathFinder - Find your way with OpenStreetMap maps
 * Copyright (C) 2015 - Nicolas TORTRAT / Nicolas Raymond

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)


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

