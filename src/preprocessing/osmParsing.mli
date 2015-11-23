
(**	Parsing of an Open Street Map file

    This module gives functionalities to extract datas from
    an open street map file. This file must have the extention
    .osm . *)

val map_of_osm : string -> MapData.map
(**	[Osm_parsing.map_of_osm osm] takes the .osm file [osm], parse
    it and creates a specific data structure used to perform
    operations on the map. *)
