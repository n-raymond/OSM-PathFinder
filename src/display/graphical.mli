
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

