
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
