


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



(**	Graphical displayer

    This module offers some functionalities to diplay
    a map and an itinerary. *)

val display :
  Options.requestMode ->
  MapData.map ->
   (MapData.node_id * float) list ->
  MapData.node_id -> MapData.node_id -> unit
(**	[Graphical.display map i start goal] displays the itinerary [i]
    of the [map]. It draws the itinerary and
    creates a picture saved on the map directory. *)

val draw_map : MapData.map -> string -> unit
(**	[Graphic.display map dir] draws the [map].

    If the [dir] contains the file [Map.jpg], the function
    draws this picture. Else, it draws the map from the
    [map] datas and save the result into the [Map.jpg] file. *)

