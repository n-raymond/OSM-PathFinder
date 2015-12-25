

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

module type Position =
sig

  type t
  type ts
  type map
  val create : map -> ts
  val get_coordinates : t -> (float * float)
  val remove_position : ts -> t -> ts
  val split_median_position : ts -> (ts * t * ts)
  val sort_by_axis : ts -> ts
  val sort_by_ordinate : ts -> ts
  val number_elements : ts -> int
  val get_node_id : t -> MapData.node_id

end


module type S =
sig

  type t
  type positions_set
  type position
  type map
  val create : map -> t
  val find : float -> float -> t -> position
  val get_node_id_from_position : position -> MapData.node_id

end



module Make (P : (Position with type map = Roads.t)) =
struct

  type positions_set = P.ts
  type position = P.t
  type map = P.map
  exception LException
  type direction = Axis | Ordinate

  type t = Node of position * t * t
    | Leaf

  let create set =
    let set = P.create set in
    let rec create_by_axis set =
      let set = P.sort_by_axis set in
      let (left, med, right) = P.split_median_position set in
      match P.number_elements set with
        | 0 -> Leaf
        | _ -> Node (med, create_by_ordinate left, create_by_ordinate right)
    and create_by_ordinate set =
      let set = P.sort_by_ordinate set in
      let (left, med, right) = P.split_median_position set in
      match P.number_elements set with
        | 0 -> Leaf
        | _ -> Node (med, create_by_axis left, create_by_axis right)
    in
    create_by_axis set

  let find x y tree =
    let min (sum1, nd1) (sum2, nd2) =
      if sum1 > sum2
      then (sum2, nd2)
      else (sum1, nd1)
    in
    let calculate n x1 y1 =
      ((abs_float (x-.x1)) +. (abs_float (y1 -.y)), n)
    in
    let verify_r sum x1 y1 = function
      | Axis -> x+.sum > x1
      | Ordinate -> y+.sum > y1
    in
    let rec search_node sum nd c ori = function
      | Leaf -> (sum, nd)
      | Node (med, ltree, rtree) ->
        let (x1, y1) = P.get_coordinates med in
        if verify_r sum x1 y1 c then
          min
          (search_node sum nd  ori c ltree)
          (search_node sum nd  ori c rtree) |>
          min
          (calculate med x1 y1) |>
          min
          (sum, nd)
        else
          (sum, nd)
    in
    let rec insert_node f c = function
      | Leaf -> raise LException
      | Node (med, ltree, rtree) ->
        try
          let (x1, y1) = P.get_coordinates med in
          begin match c with
            | Axis ->
              if x > x1 then
                (let (sum, nd) = insert_node f Ordinate rtree in
                search_node sum nd Axis Ordinate (Node (med, ltree, rtree)))
              else
                (let (sum, nd) = insert_node f Ordinate ltree in
                search_node sum nd Axis Ordinate (Node (med, ltree, rtree)))
            | Ordinate ->
              if y > y1 then
                (let (sum, nd) = insert_node f Axis rtree in
                search_node sum nd Ordinate Axis (Node (med, ltree, rtree)))
              else
                (let (sum, nd) = insert_node f Axis ltree in
                search_node sum nd Ordinate Axis (Node (med, ltree, rtree)))
          end
        with
          | LException -> let (x1, y1) = P.get_coordinates med
          in
            calculate med x1 y1
      in
      let rec insert_node_axis =
        lazy (insert_node insert_node_ordinate Axis)
      and insert_node_ordinate =
        lazy (insert_node insert_node_axis Ordinate)
      in
        let (f, pos) = Lazy.force insert_node_axis tree in
        pos

  let get_node_id_from_position =
    P.get_node_id



end


