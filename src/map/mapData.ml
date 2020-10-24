
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


(**	MapData

    Module containing all the OpenStreetMap data
    structure. *)

(*******************)
(*      ROADS      *)
(*******************)


(* General abstract tree *)

type transition = distance cost * time cost * vehicules * way path

and vehicules = motorized vehicule * bicycle vehicule * pedestrian vehicule

and _ vehicule =
  | Motorized : bool -> motorized vehicule
  | Bicycle : bool -> bicycle vehicule
  | Pedestrian : bool -> pedestrian vehicule

and motorized = M

and bicycle = B

and pedestrian = P


(* Path *)

and _ path =
  | Way : way * name * node_id list -> way path
  | Zone : zone * coords list -> zone path

and way =
  | Highway of bridge * highway

and bridge =
  | Bridge of bool



(* M => Motorized
   B => Bicicle
   P => Pedestrian *)
and highway =         (* [ M B P ] *)
  | HmotorWay         (* [ *     ] *)
  | Htrunk            (* [ * *   ] *)
  | Hprimary          (* [ * *   ] *)
  | Hsecondary        (* [ * * * ] *)
  | Htertiary         (* [ * * * ] *)
  | Hunclassified     (* [ * * * ] *)
  | Hresidential      (* [ * * * ] *)
  | HmotorWayLink     (* [ *     ] *)
  | HtrunkLink        (* [ * *   ] *)
  | HprimaryLink      (* [ * *   ] *)
  | HsecondaryLink    (* [ * * * ] *)
  | HtertiaryLink     (* [ * * * ] *)
  | HlivingStreet     (* [ * * * ] *)
  | Hpedestrian       (* [     * ] *)
  | Hroad             (* [ * * * ] *)
  | Hfootway          (* [     * ] *)
  | Hcycleway         (* [   *   ] *)
  | Hsteps            (* [     * ] *)
  | Hpath             (* [   * * ] *)
  | Hservice          (* [   * * ] *)

and name =
  | Addr of string
  | Unnamed

and zone =
  | Zbassin
  | Zfarmland
  | Zforest
  | Zgrass
  | Zgreenfield
  | Zresidential
  | Zindustrial
  | Zwood
  | Zgrassland
  | Zsand
  | Zwater
  | Zbeach
  | Zbay
  | Zcoastline
  | Zriver
  | Zriverbank
  | Zstream
  | Zpark
  | Zpitch
  | Zgarden
  | Zgolf_course
  | Zvillage_green


(* Cost *)

and _ cost =
  | Distance : float -> distance cost
  | Time : float option -> time cost

and distance = D

and time = T


(* Node *)

and _ node =
  | IntersectionNode : coords -> coords node
  | PathNode : coords * sections -> sections node
  | PointOfInterest : coords * cityname -> cityname node

and node_id =
  NId of string

and coords = float * float

and cityname =
  | City of string
  | Town of string
  | Village of string

and sections = (node_id * node_id) list


(* Roads *)

module Roads = OrientedGraph.Make (
  struct
    type graph_node = [ `Inode of coords node | `Pnode of sections node ]
    type graph_node_id = node_id
    type graph_transition = transition

    let print_node (x : [`Inode of coords node | `Pnode of sections node]) =
      match x with
      | `Inode (IntersectionNode (x, y))
      | `Pnode (PathNode ((x, y), _))	->
      string_of_float x ^ "/" ^ string_of_float y

    let print_node_id (NId i) = i

    let print_transition (_, _, (m, b, p), _) =
      let aux : type a. a vehicule -> string = function
        | Motorized true  -> "m"
        | Bicycle true    -> "b"
        | Pedestrian true	-> "p"
        | _	-> ""
      in
      aux m ^ aux b ^ aux p

  end
)


(**************************)
(*      MAP METADATA      *)
(**************************)

type metadata =
  Metadata of zone path list * cityname node list * coords * coords



(*******************************)
(*      NEAREST NEIGHBOOR      *)
(*******************************)


(* TODO : Nearests *)
type nearest = Nearest


(*******************************)
(*      GENERAL STRUCTURE      *)
(*******************************)

type map = Roads.t * metadata * nearest option





(***********************************)
(*     USEFUL FUNCTIONALITIES      *)
(***********************************)

(**	[MapData.coords_of_node n] gives the coordinates of
    the node [n]. *)
let coords_of_node : type a. a node -> coords =
  function
  | IntersectionNode co -> co
  | PathNode (co, _) -> co
  | PointOfInterest (co, _) -> co

(**	[MapData.coords_of_id id] gives the coordinates of the
    node binded with a certain [id] in the [map]. *)
let coords_of_id map id =
  match Roads.get_node map id with
  | `Inode n -> coords_of_node n
  | `Pnode s -> coords_of_node s

(**	[MapData.transition_with_minimal_cost id1 id2 cost_type]
    gives the transition from [id1] to [id2] with a minimal
    cost depending of the [cost_type]. *)
let transition_with_minimal_cost map id1 id2 =
  try
    let transitions = Roads.find_transitions map id1 id2 in
    let first = List.hd transitions in
    function
    | `Distance ->
      List.fold_left (
        fun (Distance d, t, v, w) (Distance d2, t2, v2, w2) ->
          if d > d2 then (Distance d2, t2, v2, w2)
          else (Distance d, t, v, w)
      ) first transitions
    | `Time ->
      List.fold_left (
        fun (d, Time ot, v, w) (d2, Time ot2, v2, w2) ->
          begin
            match ot, ot2 with
            | Some t, Some t2 ->
              if t > t2 then (d2, Time ot2, v2, w2)
              else (d, Time ot, v, w)
            | Some t, None ->
              (d, Time ot, v, w)
            | None, _ ->
              (d2, Time ot2, v2, w2)
          end
      ) first transitions
  with (Failure _) -> assert false (* By Graph *)

(**	[MapData.distance_of_transition map id1 id2] gives the
    minimal distance needed to travel from [id1] to [id2]
    in the [map]. *)
let distance_of_transition map id1 id2 =
  let (Distance d, _, _, _) =
    transition_with_minimal_cost map id1 id2 `Distance
  in d

(**	[MapData.time_of_transition map id1 id2] gives the
    minimal time needed to travel from [id1] to [id2]
    in the [map] for motorized vehicule. *)
let time_of_transition map id1 id2 =
  let (_, Time t, _, _) =
    transition_with_minimal_cost map id1 id2 `Time
  in t

let calculate_dist l nid1 nid2 roads =
  let find_coord = function
    | `Inode(IntersectionNode x) -> x
    | `Pnode(PathNode (x, y)) -> x
  in
  let search_node nid =
    find_coord (Roads.get_node roads nid)
  in
  let convert_to_nodes l =
    List.map (fun x -> search_node x) l
  in
  let rec f n (x3, y3) =
  function
  | (x1, y1)::[] -> n+.(Geodetic.distance x1 y1 x3 y3)
  | (x1, y1)::(x2, y2)::l -> f (n+.(Geodetic.distance x1 y1 x2 y2)) (x3, y3) ((x2, y2)::l)
  | [] -> failwith "List can't be empty"
  in
  let calcul_fst n (x1, y1) (x2, y2) = function
    | [] -> Geodetic.distance x1 y1 x2 y2
    | (x, y)::l -> f (n+.(Geodetic.distance x1 y1 x y)) (x2, y2) ((x,y)::l)
  in
  calcul_fst 0. (search_node nid1) (search_node nid2) (convert_to_nodes l)

let calculate_time dist maxspeed =
  dist/.maxspeed

