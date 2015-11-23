
(**	RoadMap displayer

    This module offers some functionalities to diplay
    a map and an itinerary. *)

val display : Options.vehiculeMode -> Options.requestMode -> MapData.map -> (float * (MapData.node_id * float) list ) -> unit
(**	[RoadMap.display map i] displays the itinerary [i]
    of the [map]. It prints a roadmap of the itinerary. *)


