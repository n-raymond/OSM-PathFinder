
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


(**	Nearest Neighboor preprocessing

    Module that offers the possibility to precompute a map data
    and generate tree that structure to facilitate the search
    of the nearest neighboor. *)


module type Position =
sig

  type t
  (**	The type of a position. *)

  type ts
  (**	The type of a positions set. *)

  type map
  (** type of original map *)

  val create : map -> ts
  (** [Position.create] create a new position set which can be used *)

  val get_coordinates : t -> (float * float)
  (** [Position.get_coordinates pos] take a position [pos] and return his
      coordinates lat first and lon second. *)

  val remove_position : ts -> t -> ts
  (** [Position.remove_position set pos] remove the position [pos] of the set
      [set]. *)

  val split_median_position : ts -> ( ts * t * ts)
  (** [Position.get_median_position set] take the set [set] and return the
      position element which is the median of the set and the two different list
      at the left, with the lower elements, and the right, with the bigger
      elements, of the element. If they are only two elements,
      then return the median and the list right with one element end let list is
      empty.*)

  val sort_by_axis : ts -> ts
  (** [Position.sort_by_axis set] take the set [set] and return the same
      set sort by axis. *)

  val sort_by_ordinate : ts -> ts
  (** [Position.sort_by_ordonate set] take the set [set] and return the same
      set sort by ordonate. *)

  val  number_elements : ts -> int
  (** [Position.one_last_element set] take a set [set] and return the number
      of elements in this set. *)

  val get_node_id : t -> MapData.node_id
  (** [Position.get_node_id_from position p] take the position
      [p] and return the corresponding node_id. *)


end



module type S =
sig

  type t
  (**	The type of the nearest neighboor tree generated on a
      generic kind of positions set *)

  type positions_set
  (** The type of the positions set *)

  type position
  (**	The type of a position *)

  type map
  (** type of original structure *)

  val create : map -> t
  (** [NearestTree.create map] creates a new nearest tree
      data structure. It takes a node set [map] and construct
      the appropriate structure. *)

  val find : float -> float -> t -> position
  (** [NearestTree.find x y t] finds the nearest position of
      the coordinates [x] and [y] from the nearest tree [t] *)

  val get_node_id_from_position : position -> MapData.node_id
  (** [Nearesttree.get_node_id_from position p] take the position
      [p] and return the corresponding node_id. *)

end



module Make (P : (Position with type map = MapData.Roads.t)) :
  (S with type positions_set = P.ts
     and type position = P.t
     and type map = P.map)

