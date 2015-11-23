
module type GraphElements =
sig
  type graph_node
  type graph_node_id
  type graph_transition
  val print_node : graph_node -> string
  val print_node_id : graph_node_id -> string
  val print_transition : graph_transition -> string
end


module type S =
sig
  type node
  type node_id
  type transition
  type t
  exception Already_exists of node_id
  val create : int -> t
  val add_node : t -> node_id -> node -> unit
  val insecure_remove_node : t -> node_id -> unit
  val get_node : t -> node_id -> node
  val get_transitions : t -> node_id -> (node_id * transition list) list
  val add_transition : t -> node_id -> transition -> node_id -> unit
  val remove_transition : t -> node_id -> transition -> node_id -> unit
  val exists_transition : t -> node_id -> node_id -> bool
  val find_transitions : t -> node_id -> node_id -> transition list
  val iter :
    (node_id -> node * (node_id * transition list) list -> unit) -> t -> unit
  val fold :
    (node_id -> node * (node_id * transition list) list -> 'a -> 'a)->
    t -> 'a -> 'a
  val print : t -> string
end




module List =
struct
  include List

  (** Finds the first element that satisfy the predicate [p]
      and remove it. Not tail-recursive *)
  let rec remove : ('a -> bool) -> 'a list -> 'a list =
    fun p -> function
      | [] -> []
      | a::l when p a -> l
      | a::l -> a::(remove p l)

  (** Takes a conversion function from 'a to string and converts
      the 'a list into a string *)
  let print : ('a -> string) -> 'a list -> string =
    fun f -> function
    | []	-> "[]"
    | [a] -> "[" ^ f a ^ "]"
    | a::l -> "[" ^ f a ^ List.fold_left (fun x y -> x ^ "; " ^ f y) "" l ^ "]"

end



module Make (GE : GraphElements) =
struct

  type node = GE.graph_node
  type node_id = GE.graph_node_id
  type transition = GE.graph_transition
  type t = (node_id, node * (node_id * transition list) list) Hashtbl.t

  exception Already_exists of node_id

  let create n = Hashtbl.create n


  (* Nodes *)

  let add_node g id n =
    try
      (* Check if the node id is in the graph *)
      let _ = Hashtbl.find g id in
      raise (Already_exists id)
    with Not_found ->
      Hashtbl.add g id (n, [])


  let get_node g id =
    let (n, _) = Hashtbl.find g id in n


  let insecure_remove_node g id =
    Hashtbl.remove g id



  (* Transitions *)

  let get_transitions g id =
    let (_, l) =  Hashtbl.find g id in l


  let add_transition g id1 t id2 =
    (* Raises End if id2 not in the transitions *)
    let rec aux z =
      match ListZipper.element z with
      | (id, l) when id = id2 ->
        ListZipper.delete z |> ListZipper.insert (id, t::l)
      | _	-> ListZipper.next z |> aux
    in

    (* Check if the node id2 is in the graph *)
    let _ = Hashtbl.find g id2 in
    let (n, l) = Hashtbl.find g id1 in

    let nl =
      try ListZipper.from_list l |> aux |> ListZipper.to_list
      with ListZipper.End -> (id2, [t])::l
    in
    Hashtbl.replace g id1 (n, nl)



  let remove_transition g id1 t id2 =
    (* Raises End if id2 not in the transitions *)
    let rec aux z =
      match ListZipper.element z with
      | (id, l) when id = id2 ->
        begin
          match List.remove (fun x -> x = t) l with
          | [] -> ListZipper.delete z
          | nl -> ListZipper.delete z |> ListZipper.insert (id, nl)
        end
      | _ -> ListZipper.next z |> aux
    in
    let (n, l) = Hashtbl.find g id1 in
    let nl =
      try ListZipper.from_list l |> aux |> ListZipper.to_list
      with ListZipper.End -> l
    in
    Hashtbl.replace g id1 (n, nl)



  let exists_transition g id1 id2 =
    try
      let (_, l) = Hashtbl.find g id1 in
      List.exists (fun (x, _) -> x = id2) l
    with Not_found -> false



  let find_transitions g id1 id2 =
    let (_, l) = Hashtbl.find g id1 in
    List.assoc id2 l



  (* Iterations *)

  let iter = Hashtbl.iter

  let fold = Hashtbl.fold




  (* Printers *)


  let print g =
    let printer id (n, l) s =
      s ^ (GE.print_node_id id)
      ^ " {" ^ (GE.print_node n) ^ "} : "
      ^ List.print (fun (nid, lt) -> (List.print GE.print_transition lt) ^ "->" ^ (GE.print_node_id nid)) l
      ^ "\n"
    in
    Hashtbl.fold printer g ""

end










