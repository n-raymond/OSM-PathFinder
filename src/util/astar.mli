
(**	A* algorithm implementation

    This module fives an implementation of the A* search
    algorithm. It can be applied on specifics datas describing
    a raod network.

    A road network is a set of points joined together by roads. Travel
    from a point to another by a certain road has a cost. *)



module type Point =
sig

  type t
  (** The type of route's point  *)

  type cost
  (**	The type of the cost that represents the travel from a
      point to another. *)

  val ( $+ ) : cost -> cost -> cost
  (**	Cost addition *)

  val ( $- ) : cost -> cost -> cost
  (**	Cost soustraction *)

  val ( $< ) : cost -> cost -> bool
  (** Cost comparaison *)

  val int_of_cost : cost -> int
  (**	[Point.int_of_cost c] takes a cost [c] and convert it to int *)

  val heuristic : t -> t list -> cost
  (**	[Point.heuristic p goals] takes the point [p] and gives
      the cost obtain by applying the heuristic to [p] for
      certain [goals]. *)

  val road_cost : t -> t -> cost
  (**	[Point.roadcost p1 p2] gives the cost that represents
      the traject from the point [p1] to the point [p2] on a road
      that join the both. *)

  val nexts : t -> t list
  (**	[Point.nexts p] takes a point [p] and return the points
      accessible from it. *)

end
(** Input signature of functor {!Astar.Make}. Defines a point of
    a road network and his functionalities. *)


module type S =
sig

  type point
  (**	The type of the point in the road network *)

  type cost
  (**	The type of the cost than represents the travel from a
      point to another. *)

  exception Unattainable
  (** Raised when the goals aren't attainable from the starts. *)

  val astart :
    (point * cost) list -> point list -> (point * cost) list * cost
  (**	[Astar.astart starts goals] run the A* algorithm. The search
      begins from the starting points [starts] and return the couple
      of the shortest way to travel to a point of the [goals] and
      the cost that represents this travel. Raises [Unattainable]
      when no path exists betwin the starts and the goals. *)

end
(** Output signature of the functor {!Astar.Make}. *)

module Make (P : Point) :
  (S with type point = P.t and type cost = P.cost)
(** Functor that builds an implementation of a A* algorithm for
    a certain kind of road network point. *)
