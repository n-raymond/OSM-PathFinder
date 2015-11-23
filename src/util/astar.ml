

module type Point =
sig
  type t
  type cost
  val ( $+ ) : cost -> cost -> cost
  val ( $- ) : cost -> cost -> cost
  val ( $< ) : cost -> cost -> bool
  val int_of_cost : cost -> int
  val heuristic : t -> t list -> cost
  val road_cost : t -> t -> cost
  val nexts : t -> t list
end


module type S =
sig
  type point
  type cost
  exception Unattainable
  val astart :
    (point * cost) list -> point list -> (point * cost) list * cost
end


module List =
struct
  include List

  let rec find_and_extract : ('a -> bool) -> 'a list -> 'a * 'a list =
    fun f -> function
      | []	-> raise Not_found
      | a::l ->
        if f a then
          (a, l)
        else
          let (elt, li) = find_and_extract f l in
          (elt, a::li)

end


module Make (P: Point) =
struct

  type point = P.t
  type cost = P.cost

  exception Unattainable

  let ( $+ ) = P.( $+ )
  let ( $- ) = P.( $- )
  let ( $< ) = P.( $< )


  (* Positions *)

  type position = {

    point : point;
    (**	The point of a certain position in a network *)

    previous : position option;
    (** The previous position on the shortest way to reach
        the current position *)

    cost : cost;
    (** The real cost of the travel from the starting position
        to the current position *)

    estimated_cost : cost
    (** The estimated cost of the travel from the starting
        position to the current position, acknowleging the
        heuristic applied to it. *)
  }



  let position_from_point prev goal (pnt, cst) = {
    point = pnt;
    previous = prev;
    cost = cst;
    estimated_cost = cst $+ P.heuristic pnt goal
  }

  let compare_cost pos1 pos2 =
    pos1.cost $- pos2.cost |> P.int_of_cost


  (** Takes a conversion function from 'a to string and converts
      the 'a list into a string *)
  let printlist : ('a -> string) -> 'a list -> string =
    fun f -> function
    | []	-> "[]"
    | [a] -> "[" ^ f a ^ "]"
    | a::l -> "[" ^ f a ^ List.fold_left (fun x y -> x ^ "; " ^ f y) "" l ^ "]"


  (* A* algorithm *)

  let astart starts goals =

    (** The main loop *)
    let rec search_loop openset closeset =
      match List.sort compare_cost openset with
      | [] -> raise Unattainable
      | current::l ->
        if List.exists (fun x -> x = current.point) goals then
          reconstruct_path current
        else
          let closeset = current::closeset in
          let openset = updates_openset current l closeset
          in search_loop openset closeset


    (**	Returns the new positions reached from current. *)
    and updates_openset current openset closeset =
      let construct openset pnt =
        let score = current.cost $+ P.road_cost current.point pnt in

        if List.exists (fun x -> x.point = pnt) closeset |> not then
          try
            match List.find_and_extract (fun x -> x.point = pnt) openset with
            | (pos, openset) when score $< pos.cost ->
              (position_from_point (Some current) goals (pnt, score))::openset
            | _ -> openset
          with Not_found ->
            (position_from_point (Some current) goals (pnt, score))::openset
        else
          openset
      in
      P.nexts current.point |> List.fold_left construct openset

    (** Construct the solution *)
    and reconstruct_path current =
      let rec aux path = function
        | None	-> path
        | Some current	->
          aux ((current.point, current.cost)::path) current.previous
      in
      (aux [(current.point, current.cost)] current.previous, current.cost)

    in
    let openset = List.map (position_from_point None goals) starts in
    search_loop openset []







end
