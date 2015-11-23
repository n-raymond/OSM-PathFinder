

open MapData

open Geodetic

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


let draw_zones origin (width, height) (Metadata (zones, citynames, _, _)) =
  Graphics.(rgb 245 246 238 |> set_color);
  Graphics.fill_rect 0 0 width height;
  List.iter (
    fun (Zone (zone, pts)) ->
      let points =
        List.map (point_from_coordinates origin) pts |>
        Array.of_list
      in
      match zone with
      | Zbassin | Zwater | Zbay | Zriverbank ->
        (* A light blue color *)
        Graphics.(rgb 191 217 255 |> set_color);
        Graphics.fill_poly points
      | Zresidential | Zindustrial ->
        (* A light grey color *)
        Graphics.(rgb 230 230 230 |> set_color);
        Graphics.fill_poly points
      | Zsand | Zbeach ->
        (* A light yellow color *)
        Graphics.(rgb 253 255 155 |> set_color);
        Graphics.fill_poly points
      | Zgreenfield | Zgrassland | Zgrass | Zfarmland
      | Zforest | Zwood | Zpark | Zpitch | Zgarden
      | Zgolf_course | Zvillage_green ->
        (* A light green color *)
        Graphics.(rgb 181 225 201 |> set_color);
        Graphics.fill_poly points
      | Zriver -> ()
      | Zstream -> ()
      | Zcoastline -> ()
  ) zones





let draw_roads origin roads =
  let draw_transition from_id to_id =
    fun (_, _, _, Way (Highway (b, h), _, ids)) ->
      let points =
        List.fold_left
          (fun res id -> (get_point roads origin id)::res)
          [get_point roads origin to_id]
          ids
        |> ( @ ) [get_point roads origin from_id]
        |> Array.of_list
      in
      Graphics.(rgb 188 188 188 |> set_color);
      begin
        match h with
        | HmotorWay | Htrunk | Hprimary
        | HmotorWayLink | HtrunkLink | HprimaryLink ->
          Graphics.set_line_width 5
        | Hsecondary | Htertiary | HsecondaryLink
        | HtertiaryLink ->
          Graphics.set_line_width 3
        | Hunclassified | Hresidential | HlivingStreet
        | Hroad ->
          Graphics.set_line_width 1
        | Hpedestrian | Hfootway | Hsteps
        | Hcycleway | Hpath | Hservice ->
          Graphics.set_line_width 1
      end;
      Graphics.draw_poly_line points

  in

  Roads.iter (
    fun from_id (n, children) ->
      List.iter (
        fun (to_id, transitions) ->
          List.iter
            (fun t -> draw_transition from_id to_id t)
            transitions
      ) children
  ) roads


let get_itinerary_points roads cost_type origin nodes =
  let rec aux z res =
    try
      let prec = ListZipper.element z in
      let z = ListZipper.next z in
      let actual = ListZipper.element z in
      let (_, _, _, Way (_, _, l)) = match cost_type with
      | Options.Time ->
        transition_with_minimal_cost roads prec actual `Time
      | Options.Distance ->
        transition_with_minimal_cost roads prec actual `Distance
      in
      let transition_coords =
        List.map (get_point roads origin) l |>
        List.rev
      in
      res@((get_point roads origin prec)::transition_coords) |> aux z
    with ListZipper.End ->
      res @ [ListZipper.element z |> get_point roads origin]
  in aux (ListZipper.from_list nodes) []

let display cost_type map itinerary start goal =

  let (roads, metadata, _) = map in
  let Metadata (_, _, (latmin, lonmin), (latmax, lonmax)) = metadata in

  let origin = mercator_projection latmin lonmin in
  let (width, height) = point_from_coordinates origin (latmax, lonmax) in

  let draw_extrimity id =
    let (x, y) = get_point roads origin id in
    Graphics.draw_circle x y 10
  in

  print_string "Drawing the itinerary ... ";
  flush stdout;
  Graphics.set_line_width 5;
  Graphics.(rgb 240 57 57 |> set_color);
  let points =
    List.map (fun (id, _) -> id) itinerary |>
    get_itinerary_points roads cost_type origin |>
    Array.of_list
  in
  Graphics.draw_poly_line points;
  Graphics.(rgb 72 226 139 |> set_color);
  draw_extrimity start;
  Graphics.(rgb 24 71 165 |> set_color);
  draw_extrimity goal;
  Images.Rgb24 (Graphic_image.get_image 0 0 width height) |>
    Jpeg.save "map.jpg" [];
  print_endline "\x1b[32mDone !\x1b[0m";
  print_endline "\x1b[36mItinerary saved in map.jpg !\x1b[0m"




let draw_map map file =
  let (roads, metadata, _) = map in
  let Metadata (_, _, (latmin, lonmin), (latmax, lonmax)) = metadata in

  let origin = mercator_projection latmin lonmin in
  let (width, height) = point_from_coordinates origin (latmax, lonmax) in

  " " ^ (string_of_int width) ^ "x" ^ (string_of_int height) |>
  Graphics.open_graph; Graphics.resize_window width height;

  if Sys.file_exists file then
    begin
      print_string "Drawing the map ... ";
      flush stdout;
      Graphic_image.draw_image (Jpeg.load file []) 0 0;
      print_endline "\x1b[32mDone !\x1b[0m";
    end
  else
    begin
      print_string "Generating the map ... ";
      flush stdout;
      draw_zones origin (width, height) metadata;
      draw_roads origin roads;
      Images.Rgb24 (Graphic_image.get_image 0 0 width height) |>
        Jpeg.save file [];
      print_endline "\x1b[32mDone !\x1b[0m";
    end










