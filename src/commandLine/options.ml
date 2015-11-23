
(*********************************)
(*  Options of the command line  *)
(*********************************)



exception InvalidOption of string * string

let invalid_option kind msg =
  raise (InvalidOption (kind, msg))



(* Flags *)

let vmode_flag = ref false

let rmode_flag = ref false

let gmode_flag = ref false

let boils_flag = ref false

let preprocessing_flag = ref false



(* Set a mode *)

let set_mode_flag mode_flag str_mode =
  if !mode_flag then
    invalid_option
      "Invalid Option"
      ("The " ^ str_mode ^ " mode was set twice.")
  else
    mode_flag := true

let set_basic_mode mode_flag str_mode mode cons =
  set_mode_flag mode_flag str_mode;
  mode := cons



(** Filename : Represents the osm file which represents a map *)
let filename = ref ""

let set_filename f =
  if Filename.check_suffix f ".osm" then
    filename := f
  else
    invalid_option
      "Invalid filename"
      "The filename must end with the extention .osm"



(**
 * VehiculeMode : Represents the kind of the vehicule used
 * to evaluate the shortest way on the map
 *)
type vehiculeMode =
| Bicycle
| Motorized
| Pedestrian

let vmode = ref Motorized

let set_vmode = set_basic_mode vmode_flag "vehicule" vmode

let set_vm_bicycle () =
  set_vmode Bicycle

let set_vm_motorized () =
  set_vmode Motorized

let set_vm_pedestrian () =
  set_vmode Pedestrian


(** RequestMode : Represents the kind of the request itself *)
type requestMode =
| Time
| Distance

let rmode = ref Distance

let set_rmode = set_basic_mode rmode_flag "request" rmode

let set_rm_time () =
  set_rmode Time

let set_rm_distance () =
  set_rmode Distance


(**	VisualMode : Represents how the shortest way is presented *)
type graphicMode =
| RoadMap
| Graphical

let gmode = ref RoadMap

let set_gmode = set_basic_mode gmode_flag "display" gmode

let set_gm_roadmap () =
  set_gmode RoadMap

let set_gm_graphical () =
  set_gmode Graphical


(**	BoilsMode : Represents the two boils of the shortest way *)
type boilsMode =
| Adresses of string * string
| Coordinates of float * float * float * float
| Nodes of string * string

let boils = ref (Nodes ("", ""))

let boils_arg = ref []

exception NotEnought

let incompatible_options () =
  invalid_option
    "Incompatible Option"
    "When option -P is defined, options -abcdgmnprt can't be used"

let couple_of_list rest kind msg=
  boils_arg := rest::!boils_arg;
  match !boils_arg with
  | []      -> assert false (* By precondition *)
  | [a]     -> raise NotEnought
  | [a; b]  -> (b, a)
  | _       -> invalid_option kind msg

let start_end_points rest =
  couple_of_list rest "Invalid number of points" "Two points are required."

let set_boils setter rest =
  if !preprocessing_flag then
    incompatible_options ()
  else
    setter rest

let setter_boils_adresses rest =
  try
    let (addr1, addr2) = start_end_points rest in
    set_mode_flag boils_flag "route's boils";
    boils := Adresses (addr1, addr2)
  with NotEnought -> ()

let setter_boils_coordinates rest =
  let coord c =
    try
      match Str.(split (regexp "/") c) |> List.map float_of_string with
      | [a; b] -> (a, b)
      | _ ->
        invalid_option
          "Invalid coordinate"
          "Coordinates must have this format : \"latitude/longitude\"."
    with Failure _ ->
      invalid_option
        "Invalid coordinate"
        "Lagitude or Longitude must be a float."
  in
  try
    let (co1, co2) = start_end_points rest in
    let (c1lat, c1lon) = coord co1 in
    let (c2lat, c2lon) = coord co2 in
    set_mode_flag boils_flag "route's boils";
    boils := Coordinates (c1lat, c1lon, c2lat, c2lon)
  with
  | NotEnought -> ()
  | Failure _ ->
      invalid_option
        "Invalid coordinate"
        "Latitude and longitude must be integers"

let setter_boils_nodes rest =
  try
    let (node1, node2) = start_end_points rest in
    set_mode_flag boils_flag "route's boils";
    boils := Nodes (node1, node2)
  with NotEnought -> ()

let set_boils_adresses =
  set_boils setter_boils_adresses

let set_boils_coordinates =
  set_boils setter_boils_coordinates

let set_boils_nodes =
  set_boils setter_boils_nodes



(* Preprocessing operations *)

let set_preprocessing_flag () =
  if !boils_flag  || !vmode_flag || !rmode_flag || !gmode_flag then
    incompatible_options ()
  else
    preprocessing_flag:= true



(* Command line checking *)

let check_cmdline () =
  if (not !boils_flag) &&(not !preprocessing_flag) then
    invalid_option
      "Missing Option"
      "One of those options are expected : -a, -n, -c or -p."
  else if (!filename = "") then
    invalid_option
      "Missing Option"
      "A filename must be defined with option -t"




