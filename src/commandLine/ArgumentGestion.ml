

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



(** Command line arguments analysis. *)

let options names kind doc =
  List.map (fun n -> (n, kind, doc)) names

let rec generic_options = Arg.(align (List.flatten [
  options
    ["--file"; "-f"]
    (String Options.set_filename)
    " Set which osm file need to be used.";

  options
    ["--motorized"; "-m"]
    (Unit Options.set_vm_motorized)
    " Set the route for motorized vehicles. (default)";

  options
    ["--bicycle"; "-b"]
    (Unit Options.set_vm_bicycle)
    " Set the route for bicycles.";

  options
    ["--pedestrian"; "-p"]
    (Unit Options.set_vm_pedestrian)
    " Set the route for pedestrian.";

  options
    ["--distance"; "-d"]
    (Unit Options.set_rm_distance)
    " Set the route for the shortest distance. (default)";

  options
    ["--time"; "-t"]
    (Unit Options.set_rm_time)
    " Set the route for the shortest.";

  options
    ["--roadmap"; "-r"]
    (Unit Options.set_gm_roadmap)
    " Display the route in roadmap mode. (default)";

  options
    ["--graphic"; "-g"]
    (String Options.set_gm_graphical)
    " Display the route in graphical mode.";

  options
    ["--nodes"; "-n"]
    (Rest Options.set_extrimity_nodes)
    " Define the starting and ending points with Open Street Map nodes.";

  options
    ["--addresses"; "-a"]
    (Rest Options.set_extrimity_adresses)
    " Define the starting and ending points with addresses.";

  options
    ["--coordinates"; "-c"]
    (Rest Options.set_extrimity_coordinates)
    " Define the starting and ending points with coordinates in \
      latitude/longitide.";

  options
    ["--preprocessing"; "-P"]
    (Unit Options.set_preprocessing_flag)
    " Carry out preprocessing operations"

]))

let invalid_opt opt =
  raise (
    Options.InvalidOption
      ("Invalid argument :",
      Printf.sprintf "%s" opt)
  )

let usage_msg =
  "\nosm_pathfinder [-b | -m | -p] [-t | -d] [-r | -g <image>.jpg] \
  -f <map.osm> -a <address1> <address2>\n"
  ^
  "osm_pathfinder [-b | -m | -p] [-t | -d] [-r | -g <image>.jpg] \
  -f <map.osm> -c <latitude1/longitude1> <latitude2/longitude2>\n"
  ^
  "osm_pathfinder [-b | -m | -p] [-t | -d] [-r | -g <image>.jpg] \
  -f <map.osm> -n <nodeID1> <nodeID2>\n"
  ^
  "osm_pathfinder -P -f <map.osm>\n"

let parse () =
  Arg.parse generic_options invalid_opt usage_msg

