open MapData

open Geodetic

exception Not_Good_Transition

(* functions used in graphical *)

let mercator_projection lat lon =

  (* 100 meters = 25 px at the equator *)
  let worldwidth = 15028131.0 in
  let worldheight = 7386708.0 in

  let lat_rad = lat *. pi /. 180.0 in
  let mercN = log (tan ((pi /. 4.0) +. (lat_rad /. 2.0))) in

  let y =
    (worldheight /. 2.0) -. (worldwidth *. mercN /. (2.0 *. pi))
    |> int_of_float
  in
  let x = (lon +. 180.0) *. (worldwidth /. 360.0) |> int_of_float in
  (x, y)



(**	Converts the coordinates of latitude [lat] and longitude [lon]
    to the coordinates in pixels in the image. This uses the
    positions [o_lat] and [o_lon], respectively the latitude and
    the longitude of the origine of the image. It is the top-left
    position. *)
let point_from_coordinates (x0, y0) (lat, lon) =
  let (x, y) = mercator_projection lat lon in
  (x - x0, y0 - y)

let get_point roads origin id =
  coords_of_id roads id |> point_from_coordinates origin



(* DIRECTION *)

(* verify if direction is left or right *)
let direct_left (xa, ya) (xb, yb) (xc, yc) =
  let da = ya - yb in
  let db = xb - xa in
  let dc = da * xa + db * ya in
  let dd = da * xc + db * yc in
  dd > dc

(* print the direction considering bo and res *)
let verify_direction res bo name =
  if res > 145. then
    (print_endline (
      "\x1b[36m↑\x1b[0m Continuez tout droit sur \x1b[31m"^name^"\x1b[0m")
    )
  else
    begin
    if bo then
      (print_endline (
        "\x1b[36m↰\x1b[0m Prenez à gauche vers \x1b[31m"^name^"\x1b[0m")
      )
    else
      (print_endline (
        "\x1b[36m↱\x1b[0m Prenez à droite vers \x1b[31m"^name^"\x1b[0m")
      )
    end

(* calculate few things to know the direction and use print_direction *)
let print_direction id_o id_d id_p origin map name =
  let a = get_point map origin id_o in
  let b = get_point map origin id_p in
  let c = get_point map origin id_d in
  let bo = direct_left a b c in
  let vector_ab = ((fst b) - (fst a), (snd b) - (snd a)) in
  let vector_ac = ((fst c) - (fst a), (snd c) - (snd a)) in
  let mul_vect = (fst vector_ab) * (fst vector_ac) +
  (snd vector_ab) * (snd vector_ac) |>
  float_of_int in
  let seg_ab =
  (fst vector_ab) * (fst vector_ab) +
  (snd vector_ab) * (snd vector_ab)
  |> float_of_int |> sqrt
  in
  let seg_ac =
  (fst vector_ac) * (fst vector_ac) +
  (snd vector_ac) * (snd vector_ac)
  |> float_of_int |> sqrt
  in
  let res = mul_vect /. (seg_ab *. seg_ac) |>
  acos |>
  ( *. ) 180. in
  let res = res /. pi in
  verify_direction res bo name



(* util float functions *)

let epsilon = 1.0e-12
let ( =. ) a b = (abs_float (a -. b)) < epsilon

let reduce_float f =
  let f = f *. 100. |>
  int_of_float |>
  float_of_int in
  f /. 100.

let convert_hour f =
  let i = int_of_float f |> float_of_int in
  let r = f -. i |> ( *. ) 0.6 in
  r +. i



(* matching type cost and getter *)

let get_distance_cost = function
  | Distance f -> f

let get_time_cost = function
  | Time (Some f) -> f
  | Time None -> 0.



(* util functions for get id *)

let take_fst ids nid =
  match ids with
  | [] -> nid
  | _ -> List.hd ids

let take_last ids nid = take_fst (List.rev ids) nid



(* functions to get the good transition in the list *)

let verify_transition f d t tcost = function
  | Options.Motorized ->
    begin match tcost with
      | Options.Time ->
        get_time_cost t =. f
      | Options.Distance ->
        get_distance_cost d =. f
    end
  | _ -> get_distance_cost d =. f

let recup_transition fo ff nidd nida map tcost veh =
  let tsl = Roads.find_transitions map nidd nida in
  let f = ff -. fo in
  let rec trans = function
   | [] -> failwith "impossible"
   | (d, t, _, (Way (_, n, ids)))::l ->
     if verify_transition f d t tcost veh then
       (get_distance_cost d, n, ids)
     else
       trans l
  in
  trans tsl



(* functions to get the name of a road and print distance 
 * before changing road *)

let find_name = function
  | Addr n -> n
  | Unnamed -> "la route"

let verify_name name n r b =
  if name = n then
    false
  else
    begin
    if name = " " then
      false
    else
      begin match b with
      | true ->
        let _ =
        print_endline (
          "\x1b[32mPrendre "^
          name^
          " sur environ "^
          (string_of_float (reduce_float r))^
          " km\x1b[0m"
        ); print_endline ""
        in
        true
      | false ->
        let _ =
        print_endline (
          "Continuez sur "^
          name^
          " sur environ \x1b[33m"^
          (string_of_float (reduce_float r))^
          " km\x1b[0m"
        ); print_endline ""
        in
        true
      end
    end



(* function to pass on the next step of itinerary *)

let rec print_next_step map name result fo id idp opt veh origin b =
  function
  | [] ->
      print_endline (
        "Continuez sur "^
        name^
        " sur environ \x1b[33m"^
        (string_of_float (reduce_float result))^
        " km\x1b[0m"
      ); print_endline ""
  | (nid, f)::l -> (
    let (d, n, ids) = recup_transition fo f id nid map opt veh in
    let idf = take_fst ids nid in
    let idpr = take_last ids id in
    let n = find_name n in
    if verify_name name n result b then
      begin
      let _ = print_direction id idp idf origin map n in
      print_next_step map n d f nid idpr opt veh origin false l
      end
    else
      begin
      print_next_step map n (result +. d) f nid idpr opt veh origin b l
      end
    )




(* functions to calculate total duration or distance of itinerary *)

let print_time f =
  print_endline "";
  "Durée totale estimé : \x1b[33m"^
  (string_of_float (reduce_float f))^
  " h\x1b[0m" |>
  print_endline;
  print_endline "";
  print_endline ""

let calculate_bicycle dist =
  dist /. 13.0 |>
  convert_hour

let calculate_pedestr dist =
  dist /. 5.0 |>
  convert_hour

let total_cost v f = function
  | Options.Time ->
      begin match v with
        | Options.Motorized ->
          print_time (convert_hour f)
        | Options.Bicycle ->
          print_time (calculate_bicycle f)
        | Options.Pedestrian ->
          print_time (calculate_pedestr f)
      end
    | Options.Distance ->
      print_endline "";
      "Distance totale estimé : \x1b[33m"^
      (string_of_float (reduce_float f))^
      " km\x1b[0m" |>
      print_endline;
      print_endline "";
      print_endline ""




(* main function of roadmap *)

let display v t map (f, it) =
  let (roads, metadata, _) = map in
  let Metadata (_, _, (latmin, lonmin), (latmax, lonmax)) = metadata in

  let origin = mercator_projection latmin lonmin in
  let recup_fst_id = function
    | (nid, f)::l -> (nid, l)
    | [] -> failwith "empty"
  in
  let (nid, l) = recup_fst_id it in
  total_cost v f t;
  print_next_step roads " " 0. 0. nid nid t v origin true l;
  print_endline "";
  print_endline "\x1b[34mVous êtes arrivés à destination\x1b[0m";
  print_endline ""




