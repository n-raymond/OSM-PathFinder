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
        | _ -> assert false (* By MapData *)
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
