
(**	Data Marshalling

    This module proposes functionalities to marshal and
    unmarshal a map data structure. *)

val from_map : MapData.map -> string -> unit
(**	[Data_marshalling.from_map map f] takes the [map] data
    structure, marshal it, and stock the result in file [f]. *)

val to_map : string -> MapData.map
(** [Data_marshalling.to_map f] takes the marshaling datas
    in the file [f], unmarshal it, and gives the map structure
    obtained. Raises [Not_found] if the file [f] does not exists
    and [Invalid_data]. *)

