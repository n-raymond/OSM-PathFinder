
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


open MapData
open NearestTree

module type S =
sig

  type t

  val find : float -> float -> t -> MapData.node_id
  (** [Nearest.find x y near] finds the nearest node_id with the
      given coordinates [x] [y] and the structure [near]. *)

end

module Basic : (S with type t = Roads.t) =
struct
  type t = Roads.t

  let find x y road =
    let (sum, fnid) =
      let comparison nid1 nid2 sdiff xc yc =
        let xdiff = abs_float (xc -. x)
        in
        let ydiff = abs_float (yc -. y)
        in
        let sdiff2 = xdiff+.ydiff
        in
        if sdiff > sdiff2
        then (sdiff2, nid2)
        else (sdiff, nid1)
      in
      Roads.fold (fun nid (nod, _) (sd, n) ->
      begin match nod with
        | `Inode (IntersectionNode (x, y)) ->
          comparison n nid sd x y
        | `Pnode (PathNode ((x,y), _)) ->
          comparison n nid sd x y
      end
      ) road (541., (NId "fst element which will be replace"))
      (* For the first element, have no over choice, but difflat max = 180
       * and difflon max = 360 so diff max = 540 and this element is
       * obligate to be replace *)
    in
    fnid

end

module Preprocesed : (S with type t = NearTree.Nearee.t) =
struct
  type t = NearTree.Nearee.t
  let find x y t = NearTree.Nearee.(get_node_id_from_position (find x y t))

end
