open NearestTree
open MapData

module Nearee = Make(
  struct

    type t =  node_id * coords

    type ts = t list

    type map = Roads.t

    let get_node_id (nid, co) =
      nid

    let create map =
      let get_coord = function
        | `Inode (IntersectionNode co) -> co
        | `Pnode (PathNode (co,_)) -> co
      in
      Roads.fold (fun nid (n, _) l -> (nid, get_coord n)::l) map []

    let get_coordinates (nd, xy) = xy

    let rec remove_position l (nd, xy) =
      match l with
        | [] -> l
        | (nd1, xy1)::l1 -> (
          if nd1 = nd then
            l1
          else
            (nd1, xy1)::(remove_position l1 (nd, xy))
        )

    let number_elements =
      List.length

    let sort_by_ordinate l =
      List.sort (fun (nd, (_, y)) (nd1, (_, y1)) ->
        if y > y1 then
          1
        else
          -1
      ) l

    let sort_by_axis l =
      List.sort (fun (nd, (x, _)) (nd1, (x1, _)) ->
        if x > x1 then
          1
        else
          -1
      ) l

    let split_median_position l =
      let rec f len n l = function
        | [] -> failwith "try again"
        | a::l1 -> (
          if len = n then
            (l1, a, l)
          else
            f len (n+1) (a::l) l1
        )
      in
      f (List.length l) 0 [] l

  end
)
