

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

(* take a function, a string, a list and a phrase for fail, search the element
 * string in the list and applicate the function f to him and return it. if the
 * element is not in the list, fail with the phrase. *)
let rec find_tag f s failp =
  function
  | [] -> failwith failp
  | (r, x)::l -> if r=s then f x else find_tag f s failp l

exception Not_Known_Path


(*Util functions to construct the types of highway and zones *)



(* Function of matching gigantic to recuperate intersting datas. *)
(* Raise Not_known_path if the data of a known path is not interesting *)

let organise_tag l = function
  | ("k", "name")::("v", n)::[] ->
      ("name", n)::l
  | ("k", "maxspeed")::("v", y)::[] ->
      ("maxspeed", y)::l
  | ("k", "landuse")::("v", "basin")::[] ->
      ("landuse", "basin")::l
  | ("k", "landuse")::("v", "farmland")::[] ->
      ("landuse", "farmland")::l
  | ("k", "landuse")::("v", "forest")::[] ->
      ("landuse", "forest")::l
  | ("k", "landuse")::("v", "grass")::[] ->
      ("landuse", "grass")::l
  | ("k", "landuse")::("v", "greenfield")::[] ->
      ("landuse", "greenfield")::l
  | ("k", "landuse")::("v", "residential")::[] ->
      ("landuse", "residential")::l
  | ("k", "landuse")::("v", "industrial")::[] ->
      ("landuse", "industrial")::l
  | ("k", "landuse")::("v", "village_green")::[] ->
      ("landuse", "village_green")::l
  | ("k", "natural")::("v", "wood")::[] ->
      ("natural", "wood")::l
  | ("k", "natural")::("v", "grassland")::[] ->
      ("natural", "grassland")::l
  | ("k", "natural")::("v", "sand")::[] ->
      ("natural", "sand")::l
  | ("k", "natural")::("v", "water")::[] ->
      ("natural", "water")::l
  | ("k", "natural")::("v", "beach")::[] ->
      ("natural", "beach")::l
  | ("k", "natural")::("v", "bay")::[] ->
      ("natural", "bay")::l
  | ("k", "natural")::("v", "coastline")::[] ->
      ("natural", "coastline")::l
  | ("k", "waterway")::("v", "river")::[] ->
      ("waterway", "river")::l
  | ("k", "waterway")::("v", "riverbank")::[] ->
      ("waterway", "riverbank")::l
  | ("k", "waterway")::("v", "stream")::[] ->
      ("waterway", "stream")::l
  | ("k", "leisure")::("v", "park")::[] ->
      ("leisure", "park")::l
  | ("k", "leisure")::("v", "pitch")::[] ->
      ("leisure", "pitch")::l
  | ("k", "leisure")::("v", "garden")::[] ->
      ("leisure", "garden")::l
  | ("k", "leisure")::("v", "golf_course")::[] ->
      ("leisure", "golf_course")::l
  | ("k", "waterway")::("v", _)::[] ->
      raise Not_Known_Path
  | ("k", "leisure")::("v", _)::[] ->
      raise Not_Known_Path
  | ("k", "landuse")::("v", _)::[] ->
      raise Not_Known_Path
  | ("k", "natural")::("v", _)::[] ->
      raise Not_Known_Path
  | ("k", "highway")::("v", "motorway")::[] ->
      ("highway", "motorway")::l
  | ("k", "highway")::("v", "trunk")::[] ->
      ("highway", "trunk")::l
  | ("k", "highway")::("v", "primary")::[] ->
      ("highway", "primary")::l
  | ("k", "highway")::("v", "secondary")::[] ->
      ("highway", "secondary")::l
  | ("k", "highway")::("v", "tertiary")::[] ->
      ("highway", "tertiary")::l
  | ("k", "highway")::("v", "unclassified")::[] ->
      ("highway", "unclassified")::l
  | ("k", "highway")::("v", "residential")::[] ->
      ("highway", "residential")::l
  | ("k", "highway")::("v", "motorway_link")::[] ->
      ("highway", "motorway_link")::l
  | ("k", "highway")::("v", "trunk_link")::[] ->
      ("highway", "trunk_link")::l
  | ("k", "highway")::("v", "primary_link")::[] ->
      ("highway", "primary_link")::l
  | ("k", "highway")::("v", "secondary_link")::[] ->
      ("highway", "secondary_link")::l
  | ("k", "highway")::("v", "tertiary_link")::[] ->
      ("highway", "tertiary_link")::l
  | ("k", "highway")::("v", "living_street")::[] ->
      ("highway", "living_street")::l
  | ("k", "highway")::("v", "pedestrian")::[] ->
      ("highway", "pedestrian")::l
  | ("k", "highway")::("v", "road")::[] ->
      ("highway", "road")::l
  | ("k", "highway")::("v", "footway")::[] ->
      ("highway", "footway")::l
  | ("k", "highway")::("v", "cycleway")::[] ->
      ("highway", "cycleway")::l
  | ("k", "highway")::("v", "steps")::[] ->
      ("highway", "steps")::l
  | ("k", "highway")::("v", "path")::[] ->
      ("highway", "path")::l
  | ("k", "highway")::("v", "service")::[] ->
      ("highway", "service")::l
  | ("k", "highway")::("v", _)::[] ->
      raise Not_Known_Path
  | ("k", "oneway")::("v", "yes")::[] -> ("oneway", "yes")::l
  | ("k", "junction")::("v", "roundabout")::[] -> ("junction", "roundabout")::l
  | ("k", "bridge")::("v", "yes")::[] -> ("bridge", "yes")::l
  | _ -> l


let construct_tag_list xml = List.fold_left (
  fun l x -> match x with
    | Xml.Element ("tag", sl, _) -> organise_tag l sl
    | _ -> failwith "No pcdata permitted")
  [] xml

let rec create_type_zone = function
  | ("landuse", "basin")::l -> Zbassin
  | ("landuse", "farmland")::l -> Zfarmland
  | ("landuse", "forest")::l -> Zforest
  | ("landuse", "grass")::l -> Zgrass
  | ("landuse", "greenfield")::l -> Zgreenfield
  | ("landuse", "residential")::l -> Zresidential
  | ("landuse", "industrial")::l -> Zindustrial
  | ("landuse", "village_green")::l -> Zvillage_green
  | ("natural", "wood")::l -> Zwood
  | ("natural", "grassland")::l -> Zgrassland
  | ("natural", "sand")::l -> Zsand
  | ("natural", "water")::l -> Zwater
  | ("natural", "beach")::l -> Zbeach
  | ("natural", "bay")::l -> Zbay
  | ("natural", "coastline")::l -> Zcoastline
  | ("waterway", "river")::l -> Zriver
  | ("waterway", "riverbank")::l -> Zriverbank
  | ("waterway", "stream")::l -> Zstream
  | ("leisure", "park")::l -> Zpark
  | ("leisure", "pitch")::l -> Zpitch
  | ("leisure", "garden")::l -> Zgarden
  | ("leisure", "golf_course")::l -> Zgolf_course
  | _::l -> create_type_zone l
  | [] -> raise Not_Known_Path

let create_type_highway = function
  | "motorway" ->
      (HmotorWay, (Motorized true, Bicycle false, Pedestrian false))
  | "trunk" ->
      (Htrunk, (Motorized true, Bicycle true, Pedestrian false))
  | "primary" ->
      (Hprimary, (Motorized true, Bicycle true, Pedestrian false))
  | "secondary" ->
      (Hsecondary, (Motorized true, Bicycle true, Pedestrian true))
  | "tertiary" ->
      (Htertiary, (Motorized true, Bicycle true, Pedestrian true))
  | "unclassified" ->
      (Hunclassified, (Motorized true, Bicycle true, Pedestrian true))
  | "residential" ->
      (Hresidential, (Motorized true, Bicycle true, Pedestrian true))
  | "motorway_link" ->
      (HmotorWayLink, (Motorized true, Bicycle false, Pedestrian false))
  | "trunk_link" ->
      (HtrunkLink, (Motorized true, Bicycle true, Pedestrian false))
  | "primary_link" ->
      (HprimaryLink, (Motorized true, Bicycle true, Pedestrian false))
  | "secondary_link" ->
      (HsecondaryLink, (Motorized true, Bicycle true, Pedestrian true))
  | "tertiary_link" ->
      (HtertiaryLink, (Motorized true, Bicycle true, Pedestrian true))
  | "living_street" ->
      (HlivingStreet, (Motorized true, Bicycle true, Pedestrian true))
  | "pedestrian" ->
      (Hpedestrian, (Motorized false, Bicycle false, Pedestrian true))
  | "road" ->
      (Hroad, (Motorized true, Bicycle true, Pedestrian true))
  | "footway" ->
      (Hfootway, (Motorized false, Bicycle false, Pedestrian true))
  | "cycleway" -> 
      (Hcycleway, (Motorized false, Bicycle true, Pedestrian false))
  | "steps" -> 
      (Hsteps, (Motorized false, Bicycle false, Pedestrian true))
  | "path" ->
      (Hpath, (Motorized false, Bicycle true, Pedestrian true))
  | "service" ->
      (Hservice, (Motorized false, Bicycle true, Pedestrian true))
  | _ -> failwith "create_type can't have over type_highway"

let match_speed = function
  | HmotorWay -> "130.0"
  | Htrunk | Hprimary -> "110.0"
  | HtrunkLink | HprimaryLink | HmotorWayLink | Htertiary | Hsecondary -> "90.0"
  | HsecondaryLink | HtertiaryLink -> "80.0"
  | Hunclassified | Hroad-> "60.0"
  | Hresidential -> "50.0"
  | HlivingStreet -> "30.0"
  | Hservice | Hpedestrian | Hfootway | Hcycleway | Hsteps | Hpath -> "none"


(* Util function for isolate all of the good interesting element in a highway *)

let isolate_element_tag_highway l =
  let bri =
    if List.exists (fun x -> (fst x)="bridge") l then
      Bridge true
    else
      Bridge false
  in
  let onew =
    if (List.exists (fun x -> (fst x)="oneway") l ||
    List.exists (fun x -> (fst x)="junction") l)
    then true
    else false
  in
  let high =
    try (let high = List.find (fun x -> (fst x)="highway") l in
          create_type_highway (snd high))
    with | Not_found -> failwith "Absurd"
  in
  let maxspeed =
    try (let (mx, sp) = List.find (fun x -> (fst x)="maxspeed") l in
         let _ =
           begin try float_of_string sp with _ -> raise Not_found
           end in
         (mx, sp))
    with | Not_found -> ("maxspeed", match_speed (fst high))
  in
  let name =
    try (let addr = List.find (fun x -> (fst x)="name") l
         in Addr (snd addr))
    with | Not_found -> Unnamed
  in
  (bri, high, snd maxspeed, name, onew)



let construct_zone ln lt h =
  let type_z = create_type_zone lt
in Zone (
type_z,
List.map (fun x ->
  match x with
  | Xml.Element ("nd", sl, _) ->
    let nid = find_tag (fun x -> x) "ref" "nd must have ref" sl
    in
    snd (Hashtbl.find h nid)
  | _ -> failwith "Not possible") ln
)




(* Util functions to construct the transition and the zones during the second
 * pass *)

let construct_intersection_node s h roads =
  try (let _ = Roads.get_node roads (NId s) in (NId s)) with
  | Not_found ->
    (`Inode (IntersectionNode (snd (Hashtbl.find h s)))) |>
    Roads.add_node roads (NId s);
    (NId s)


let construct_path_nodes nid1 nid2 h roads lndp onew =
  let sections = if onew then [(nid1, nid2)] else [(nid1, nid2); (nid2, nid1)]
  in
  List.iter (fun x ->
    try (let _ = Roads.get_node roads (NId x) in ())
    with
  | Not_found ->
  Roads.add_node roads (NId x) (`Pnode (PathNode (snd (Hashtbl.find
  h x), sections)))) lndp; List.map (fun x -> (NId x)) lndp

let construct_transition lnid nid1 nid2 roads brid high name vehicules maxspeed
oneway =
  let dist = calculate_dist lnid nid1 nid2 roads
  in
  let time = try Some (calculate_time dist (float_of_string maxspeed))
             with _ -> None
  in
  let transition = (Distance dist), (Time time), vehicules, (Way ((Highway (brid,
  high)), name, lnid))
  in
  let transition2 = (Distance dist), (Time time), vehicules, (Way ((Highway (brid,
  high)), name, (List.rev lnid)))
  in
  Roads.add_transition roads nid1 transition nid2;
  if oneway then
  ()
  else Roads.add_transition roads nid2 transition2 nid1




let construct_nidls ln h =
List.map (fun x ->
  match x with
    | Xml.Element ("nd", sl, _) ->
      find_tag (fun x -> x) "ref" "nd must have ref" sl
    | _ -> failwith "Not possible") ln


let save_all_informations n1 n2 h l o b hi na ve max roads =
  let nid1 = construct_intersection_node n1 h roads
  in
  let nid2 = construct_intersection_node n2 h roads
  in
  let nidl = construct_path_nodes nid1 nid2 h roads l o
  in
  construct_transition nidl nid1 nid2 roads b hi na ve max o


let construct_road tag_l h roads =
    let (b, hi, max, na, o) = isolate_element_tag_highway tag_l
    in
    let rec construct_node_list n1 n2 lnd ltmp = function
      | [] ->
        begin match ltmp with
          | [] -> ()
          | x::l -> let l = lnd@l
          in
          save_all_informations n1 x h l o b (fst hi) na (snd hi) max roads;
        end
      | x::l ->
        begin match fst (Hashtbl.find h x) with
          | 1 -> construct_node_list n1 n2 (x::lnd) ltmp l
          | _ -> save_all_informations n1 x h lnd o b (fst hi) na (snd hi) max roads;
          construct_node_list x n2 [] ltmp l
        end
    in
    let rec fst_construct_road ltmp = function
      | [] -> raise Not_Known_Path
      | x::l ->
        begin match fst (Hashtbl.find h x) with
          | 1 -> fst_construct_road (x::ltmp) l
          | _ -> construct_node_list x x [] ltmp l
        end
    in
  function
  | [_] | [] -> raise Not_Known_Path
  | x::l ->
    match fst (Hashtbl.find h x) with
      | 1 -> fst_construct_road [x] l
      | _ -> construct_node_list x "" [] [] l



(* Create zone and path *)

let create_path zones ln lt h roads =
  try
    let tag_l = construct_tag_list lt   in
    if List.exists (fun x -> (fst x) = "highway") tag_l
    then (construct_road tag_l h roads (construct_nidls ln h); zones)
    else (construct_zone ln tag_l h)::zones
  with
    | Not_Known_Path -> zones



(****************)
(*  SECOND PASS *)
(****************)

(* This pass is useful to construct all of the structure taking the hashtable
 * construct in the first pass and the xml *)
let second_pass h roads xml =

  (*****************)
  (* CITYNAME LIST *)
  (*****************)

  (* Isolate and construct the cityname node list with node in xml_structure
   * and h *)
  let rec construct_citynames l citynames h =

    (* function that take a list of tag that interest us for the cityname list
     * and add to the list this tag. Useful to isolate all of the element which
     * can be unordered *)
    let rec find_cityname l = function
      | Xml.Element ("tag", ("k", "name")::("v", y)::[], _) -> ("name", y)::l
      | Xml.Element ("tag", ("k", "place")::("v", "city")::[], _) -> ("place",
      "city")::l
      | Xml.Element ("tag", ("k", "place")::("v", "town")::[], _) -> ("place",
      "town")::l
      | Xml.Element ("tag", ("k", "place")::("v", "village")::[], _) ->
          ("place", "village")::l
      | _ -> l
    in

    (* Construct the cityname_node no matter the order of data give by the list *)
    let rec construct_cityname h coords =

      (* matching to have the type of city with his name *)
      let create_type_city x = function
        | "city" -> City x
        | "town" -> Town x
        | "village" -> Village x
        | _ -> failwith "Absurd : can't be other type of place"
      in
    function
      | ("name", x)::("place", y)::[] -> PointOfInterest (coords,
      create_type_city x y)
      | ("place", x)::("name", y)::[] -> PointOfInterest (coords,
      create_type_city y x)
      | _ -> failwith "Absurd : list construct with this two elements"

    in
  function
    | Xml.Element (_, [], _) -> failwith "Absurd : node have id"
    | Xml.Element (_, ("id", y)::l', []) ->
      begin match List.length l with
        | 2 -> (construct_cityname h (snd (Hashtbl.find h y)) l)::citynames
        | _ -> citynames
      end
    | Xml.Element (ss, ("id", y)::l', x::xl) ->
      begin match fst (Hashtbl.find h y) with
        | 0 -> construct_citynames (find_cityname l x) citynames h (Xml.Element (ss, ("id", y)::l', xl))
        | _ -> citynames
      end
    | Xml.Element (ss, y::l', xl) -> construct_citynames l citynames h (Xml.Element (ss, l', xl))
    | _ -> failwith "truly possible ?"
  in


  let rec match_nd_tag zones h roads = function
    | Xml.Element (_, _, []) -> failwith "Absurd way empty"
    | Xml.Element (s, ls, xl) ->
      let cpl_el = List.partition (fun x ->
        match x with
          | Xml.Element (y, _, _) -> y="nd"
          | _ -> failwith "No pcdata permitted")
      xl(*;*)
      in
      create_path zones (fst cpl_el) (snd cpl_el) h roads
    | _ -> failwith "No pc data attempt"
  in

  (*******************************************************)
  (*  GENERAL CHOICE AND FIRST MATCHING INTO SECOND PASS *)
  (*******************************************************)

  let match_node_way roads h xml =
    let rec f citynames zones roads h = function
      | Xml.Element (_, _, []) -> (zones, citynames)
      | Xml.Element (s, sl, (Xml.Element (ss, l1, l2))::l) ->
          begin match ss with
            | "node" -> f (construct_citynames [] citynames h
            (Xml.Element (ss, l1, l2))) zones roads h
            (Xml.Element (s, sl, l))
            | "way" -> f
            citynames (match_nd_tag zones h roads (Xml.Element (ss, l1, l2))) roads h (Xml.Element (s, sl, l))
            | _ -> f citynames zones roads h (Xml.Element (s, sl, l))
          end
      | _ -> failwith "pcdata in match_way"
    in
  f [] [] roads h xml
  in

  match_node_way roads h xml









(************************)
(* FIRST_PASS FUNCTIONS *)
(************************)

let first_pass h xml =

  let matching_ref_lst tmp id (s1, v) = match s1 with
    | "ref" ->
        let element =
          begin try Hashtbl.find tmp v with
            | Not_found -> failwith (" node_lst "^v)
          end in
        if v=id
            then (
              Hashtbl.replace tmp v (((fst element)-1), snd element);
              true
            )
            else (
                Hashtbl.replace tmp v (((fst element)+2), snd element);
                true
            )
    | _ -> false
  in

  let matching_ref_fst tmp (s1, v) = match s1 with
    | "ref" ->
      let element =
        begin try Hashtbl.find tmp v with
          | Not_found -> failwith " Element must exist "
        end
        in
      Hashtbl.replace tmp v (((fst element)+2), snd element); v
    | _ -> "-1"
  in

  let matching_ref tmp (s1, v) = match s1 with
    | "ref" ->
      let element =
        begin try Hashtbl.find tmp v with
          | Not_found -> failwith "Element must exist "
        end in
      Hashtbl.replace tmp v (((fst element)+1), snd element); true
    | _ -> false
  in

 let rec find_first_id_nd h = function
    | Xml.Element (_, [], _) ->
        failwith "Absurd : fst nd obligate to have a ref"
    | Xml.Element (nd, s::l, xl) ->
        let id = matching_ref_fst h s in
          if id = "-1"
          then find_first_id_nd h (Xml.Element (nd, l, xl))
          else id
    | _ -> failwith "pcdata in find_id_first "
 in

 let rec find_nd h = function
    | Xml.Element (_, [], _) -> failwith "Absurd : nd obligate to have a ref"
    | Xml.Element (nd, s::l, xl) ->
        if matching_ref h s
        then ()
        else find_nd h (Xml.Element (nd,l,xl))
    | _ -> failwith "pcdata in find_nd "
 in

  let rec find_nd_lst id h = function
    | Xml.Element (_, [], _) -> failwith "Absurd : nd obligate to have a ref"
    | Xml.Element (nd, s::l, xl) ->
        if matching_ref_lst h id s
        then ()
        else find_nd_lst id h (Xml.Element (nd,l,xl))
    | _ -> failwith "pcdata in find_nd_lst "
  in


  let rec match_nd id h = function
    | Xml.Element (_, _, []) -> ()
    | Xml.Element (s, ls, (Xml.Element (ss1, sl1, xl1)::[])) ->
        begin match ss1 with
          | "nd" -> find_nd_lst id h (Xml.Element (ss1, sl1, xl1))
          | _ -> ()
        end
    | Xml.Element (s, ls,
      (Xml.Element (ss1, sl1, xl1))::(Xml.Element (ss2, sl2, xl2)::l)) ->
        begin match ss1, ss2 with
          | "nd","nd" ->
            find_nd h (Xml.Element (ss1, sl1, xl1));
            match_nd id h (Xml.Element (s, ls, (Xml.Element (ss2, sl2,
            xl2))::l))
          | "nd", _ ->
              find_nd_lst id h (Xml.Element (ss1, sl1, xl1))
          | _, _ -> failwith "find_nd_way : unexpected case"
        end
    | _ -> failwith "PCData in find_nd_way"
  in

  let rec match_first_nd h = function
    | Xml.Element (_, _, []) -> failwith "Absurd : way can't be empty"
    | Xml.Element (s, ls, (Xml.Element (ss, l1, l2))::l) ->
        begin match ss with
          | "nd" ->
            let id = find_first_id_nd h (Xml.Element (ss, l1, l2)) in
            match_nd id h (Xml.Element (s, ls, l))
          | _ -> match_first_nd h (Xml.Element (s, ls, l))
        end
    | _ -> failwith "PCData in find_first_nd_way"
  in

  let rec add_node l h = function
    | Xml.Element (_, [], _) ->
        begin
          match List.length l with
          | 3 ->
            Hashtbl.add h (find_tag (fun x -> x) "id" "Absurd : have id" l)
            (0,
            (find_tag float_of_string "lat" "Absurd : have lat" l,
            find_tag float_of_string "lon" "Absurd : have lon" l)
            )
          | _ -> failwith "Node must have longitude and latitude"
        end
    | Xml.Element (ss, ("lon", x)::l', xl) -> add_node (("lon", x)::l) h
    (Xml.Element (ss, l', xl))
    | Xml.Element (ss, ("lat", x)::l', xl) ->
        add_node (("lat", x)::l) h (Xml.Element (ss, l', xl))
    | Xml.Element (ss, ("id", x)::l', xl) ->
        add_node (("id", x)::l) h (Xml.Element (ss, l', xl))
    | Xml.Element (ss, _::l', xl) -> add_node l h (Xml.Element (ss, l', xl))
    | _ -> failwith "PCData in add_node"
  in


  let rec match_node_way lt h =
    (*function to search the limit of the map *)
    let rec search_limit l = function
      | Xml.Element (_, [], _) -> l
      | Xml.Element ("bounds", ("minlat", x)::l, r) ->
          ("minlat", x)::(search_limit l (Xml.Element ("bounds", l, r)))
      | Xml.Element ("bounds", ("minlon", x)::l, r) ->
          ("minlon", x)::(search_limit l (Xml.Element ("bounds", l, r)))
      | Xml.Element ("bounds", ("maxlat", x)::l, r) ->
          ("maxlat", x)::(search_limit l (Xml.Element ("bounds", l, r)))
      | Xml.Element ("bounds", ("maxlon", x)::l, r) ->
          ("maxlon", x)::(search_limit l (Xml.Element ("bounds", l, r)))
      | _ -> failwith "Absurd no PcData"
    in
    function
      | Xml.Element (_, _, []) ->
        let minlat = find_tag float_of_string "minlat" "Absurd" lt in
        let minlon = find_tag float_of_string "minlon" "Absurd" lt in
        let maxlat = find_tag float_of_string "maxlat" "Absurd" lt in
        let maxlon = find_tag float_of_string "maxlon" "Absurd" lt in
        ((minlat, minlon), (maxlat, maxlon))
      | Xml.Element (s, sl, (Xml.Element (ss, l1, l2))::l) ->
          begin match ss with
            | "node" -> add_node [] h (Xml.Element (ss, l1, l2));
              match_node_way lt h (Xml.Element (s, sl, l))
            | "way" -> match_first_nd h (Xml.Element (ss, l1, l2));
              match_node_way lt h (Xml.Element (s, sl, l))
            | "bounds" ->
              let lt = search_limit [] (Xml.Element (ss, l1, l2)) in
              match_node_way lt h (Xml.Element (s, sl, l))
            | _ -> match_node_way lt h (Xml.Element (s, sl, l))
          end
      | _ -> failwith "pcdata in match_way"
  in
  match_node_way [] h xml



  (* Function to create a map data considering an osm file *)
let rec map_of_osm file =
  let h = Hashtbl.create 1000000 in
  let xml_structure = Xml.parse_file file in

  let roads = Roads.create 1000000 in

  let nearest = None in

  (* the first pass construct a hashtbl to know if a node is an intersection
   * node or a path node, and it return the limit of the map *)
  let coords = first_pass h xml_structure in

  (* The second pass construct all of the transitions and zone, it also
   * construct the hasthbl util for road.t considering the precedent
   * pass.*)
  let ct_zn = second_pass h roads xml_structure in

  (roads, Metadata (fst ct_zn, snd ct_zn, fst coords, snd coords), nearest)
