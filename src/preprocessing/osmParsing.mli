
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



(**	Parsing of an Open Street Map file

    This module gives functionalities to extract datas from
    an open street map file. This file must have the extention
    .osm . *)

val map_of_osm : string -> MapData.map
(**	[Osm_parsing.map_of_osm osm] takes the .osm file [osm], parse
    it and creates a specific data structure used to perform
    operations on the map. *)
