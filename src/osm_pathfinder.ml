
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



(* CommandLine displayers *)

let string_of_vmode vmode = match !vmode with
  | Options.Bicycle -> "bicycle"
  | Options.Motorized -> "motorized"
  | Options.Pedestrian	-> "pedestrian"

let string_of_rmode rmode = match !rmode with
  | Options.Time	-> "time"
  | Options.Distance	-> "distance"

let string_of_gmode gmode = match !gmode with
  | Options.RoadMap	-> "roadmap"
  | Options.Graphical -> "graphical"

let string_of_extrimity extrimity= match !extrimity with
  | Options.Adresses (s1, s2)	-> Printf.sprintf "adresses %s %s" s1 s2
  | Options.Coordinates	(i1, i2, i3, i4)->
    Printf.sprintf "coordinates %f/%f %f/%f" i1 i2 i3 i4
  | Options.Nodes	(s1, s2)-> Printf.sprintf "nodes %s %s" s1 s2



(* CommandLine Parsing *)

let cmdparsing () =
  try
    ArgumentGestion.parse ();
    Options.check_cmdline ()
  with (Options.InvalidOption (kind, msg)) ->
    at_exit (fun () -> ArgumentGestion.(Arg.usage generic_options usage_msg));
    Error.(err "Command Line" kind msg commandLine)

let _ = cmdparsing ()




(* Data Marshaling / OSM parsing *)

let mapdir =
  let basename = Filename.basename !Options.filename in
  let dirname = Filename.dirname !Options.filename in
  Filename.chop_suffix basename ".osm" |> ( ^ ) "."
  |> Filename.concat dirname

let get_data () =
  let marshal_file = Filename.concat mapdir "data.marshal" in
  try
    print_string "Extracting marshalized datas ... ";
    flush stdout;
    let map = DataMarshaling.to_map marshal_file in
    print_endline "\x1b[32mDone !\x1b[0m";
    map
  with (Sys_error _) ->
    print_endline "\n \x1b[31m/!\\ No marshalized datas have been founded.\x1b[0m";
    print_string "Parsing Open Street Map file ... ";
    flush stdout;
    let map = OsmParsing.map_of_osm !Options.filename in
    print_endline "\x1b[32mDone !\x1b[0m";
    if Sys.file_exists mapdir |> not then
      Unix.mkdir mapdir 0o770;
    print_string "Marshalization of data ... ";
    flush stdout;
    DataMarshaling.from_map map marshal_file;
    print_endline "\x1b[32mDone !\x1b[0m";
    map

let (roads, mdata, n) = get_data ()




(* Itinerary Module *)

module MapItinerary = Itinerary.Make(
  struct

    let cost_type = Options.(
      match !rmode with
      | Time	-> `Time
      | Distance -> `Distance
    )

    let vehicule_type = Options.(
      match !vmode with
      | Motorized	-> `Motorized
      | Bicycle -> `Bicycle
      | Pedestrian -> `Pedestrian
    )

    let map = roads

  end
)



(* Start, Goal *)

let nodes () =

  let check_bounds lat lon metadata =
    let MapData.Metadata (_, _, (minlat, minlon), (maxlat, maxlon)) =
      metadata
    in
    if lat < minlat || lat > maxlat || lon < minlon || lon > maxlon then
      begin
        print_endline
          "\n \x1b[31m/!\\ Start or Goal points are out of the map..\x1b[0m";
        exit 1
      end
    else
      ()
  in
  Options.(
    match !extrimity with
    | Adresses _ ->
      failwith "Functionality not implemented yet..."
    | Coordinates (latstart, lonstart, latgoal, longoal) ->
      check_bounds latstart lonstart mdata;
      check_bounds latgoal longoal mdata;
      begin
        match n with
        | None ->
          let start_id = Nearest.Basic.find latstart lonstart roads in
          let goal_id = Nearest.Basic.find latgoal longoal roads in
          (start_id, goal_id)
        | Some _ ->
          failwith "kd-tree"
      end
    | Nodes (n1, n2) ->
      (MapData.NId n1, MapData.NId n2)
  )




(* Shortest way on the map *)

let shortest_way () =


  if not !Options.preprocessing_flag then begin
    let (start, goal) =
      print_string "Checking start and goal points ... ";
      let res = nodes () in
      print_endline "\x1b[32mDone !\x1b[0m";
      res
    in
    let itinerary () =
      MapItinerary.from_map start goal
    in
    try
      print_string "Calculating the itinerary ... ";
      let (cost, it) = itinerary () in
      print_endline "\x1b[32mDone !\x1b[0m";

      Options.(
        match !gmode with
        | Graphical ->
          Filename.concat mapdir "Map.jpg" |> Graphical.draw_map (roads, mdata, n);
          Graphical.display (!rmode) (roads, mdata, n) it start goal
        | RoadMap ->
          Roadmap.display (!vmode) (!rmode) (roads, mdata, n) (cost, it)
      )

    with MapItinerary.Unattainable ->
      print_endline "\n \x1b[31m/!\\ No itinerary has been founded.\x1b[0m"
  end else
    print_string "Preprocessing : \x1b[32mDone !\x1b[0m\n"



let _ = shortest_way ()






