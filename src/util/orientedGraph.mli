
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



(** Oriented graphs

    This module implements oriented graphs that are a data
    structure that uses oriented transitions to connects nodes *)




module type GraphElements =
sig
  type graph_node
  (** The type of a node in an oriented graph. *)

  type graph_node_id
  (**	The type of a node id. In a graph, the id of a node
      is unique by definition. *)

  type graph_transition
  (** The type of transition in an oriented graph. *)

  val print_node : graph_node -> string
  (** [GraphElements.print_node n] converts the node [n]
      to a string. *)

  val print_node_id : graph_node_id -> string
  (** [GraphElements.print_node_id id] converts the node_id
      [id] to a string. *)

  val print_transition : graph_transition -> string
  (** [GraphElements.print_transition t] converts the transition
      [t] to a string. *)
end
(** Input signature of functor {!OrientedGraph.Make}. Defines the
    elements into a graph. *)


module type S =
sig

  type node
  (** The type of a node in an oriented graph *)

  type node_id
  (**	The type of a node id. In a graph, the id of a node
      is unique by definition. *)

  type transition
  (** The type of transition in an oriented graph *)

  type t
  (**	The type of an oriented graph. *)

  exception Already_exists of node_id
  (** The [Already_exists] exception is raised when we try to
      add to a graph a node with a node id that is already presents
      in the graph. *)

  val create : int -> t
  (**	[OrientedGraph.create n] creates a new, empty graph, with
      initial size n. For best results, [n] should be on the
      order of the expected number of nodes that will be in
      the graph. The table grows as needed, so [n] is just an
      initial guess. *)

  val add_node : t -> node_id -> node -> unit
  (** [OrientedGraph.add_node g id n] bind the node_id [id] and
      the node [n], and add it to the graph [g]. Raises [Id_already_exists]
      if the id of the node is already presents in the graphe. *)

  val insecure_remove_node : t -> node_id -> unit
  (** [OrientedGraph.insercure_remove_node g id] remove the node [id]
      from the graph [g].

      This function is not secure : It only remove the node but it
      will not remove the transitions pointing on this node. *)

  val get_node : t -> node_id -> node
  (** [OrientedGraph.get_node g id] gives the node correspond
      of a certain node_id [id] in the graph [g]. Raises [Not_found]
      if [id] is not in the graph. *)

  val get_transitions : t -> node_id -> (node_id * transition list) list
  (** [OrientedGraph.get_transition g id] gives the list of the
      transitions and the node after that transitions that start
      from the node corresponding to a certain node_id [id] in
      the graph [g]. Raises [Not_found] if [id] is not in the graph. *)

  val add_transition : t -> node_id -> transition -> node_id -> unit
  (** [OrientedGraph.add_transition g id1 t id2] add the transition
      [t] from the node [id1] to the node [id2]. Raises [Not_found]
      if [id1] or [id2] is not in the graph. *)

  val remove_transition : t -> node_id -> transition -> node_id -> unit
  (** [OrientedGraph.remove_transition g id1 t id2] removes the transition
      [t] from the node [id1] to the node [id2] in the graph [g]. This
      function assumes that a couple ([t], [n]) can start from [id1] only
      once. Raises [Not_found] if the transition [id1] is not in [g]. If
      [id2] is not the result of a transition from [id1], the function
      does nothing. *)

  val exists_transition : t -> node_id -> node_id -> bool
  (** [OrientedGraph.transition_exists g id1 id2] check if a transition
      starting from [id1] to [id2] exists in the graph [g]. *)

  val find_transitions : t -> node_id -> node_id -> transition list
  (**	[OrientedGraph.find_transitions g id1 id2] gives the transitions
      starting from [id1] to [id2] in the graph [g]. Raises [Not_found]
      if the transition isn't in [g]. *)

  val iter :
    (node_id -> node * (node_id * transition list) list -> unit) -> t -> unit
  (** [OrientedGraph.iter f g] applies [f] to all bindings of node id
      and their associated node and transitions in [g]. Each node of
      the graph is visited and given exactly once to [f].

      The order in which the bindings are passed to [f] is unspecified,
      but from an call of iter to another, the order will always be the
      same. *)

  val fold :
    (node_id -> node * (node_id * transition list) list -> 'a -> 'a)->
    t -> 'a -> 'a
  (** [OrientedGraph.fold f g init] computes
      [(f idN (nN, lN) ... (f id1 (n1, l1) init)...)], where [id1 ... idN]
      are the node ids of all the nodes in the graph [g], [n1 ... nN]
      the nodes reprensted by their repsctive id, and [l1 ... lN] the
      lists of transitions pointing on another nodes that start from
      each node. Each node of the graph is visited and given exactly
      once to [f].

      The order in which the bindings are passed to [f] is unspecified,
      but from an call of iter to another, the order will always be the
      same. *)

  val print : t -> string
  (** [OrientedGraph.print g] caonverts the graph [g] to a string *)

end
(** Outpout signature of the functor {!OrderedGraph.Make}. *)


module Make (GE : GraphElements) :
  (S with type node = GE.graph_node
     and type node_id = GE.graph_node_id
     and type transition = GE.graph_transition)
(** Functor that builds an implementation of an oriented graph *)

