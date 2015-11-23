

module M = MapData

module type ItineraryType =
sig
  val cost_type : [ `Distance | `Time ]
  val vehicule_type : [ `Motorized | `Bicycle | `Pedestrian ]
  val map : M.Roads.t
end

module type S =
sig
  type t = float * (MapData.node_id * float) list
  exception Unattainable
  val from_map: M.node_id -> M.node_id -> t
end


module List =
struct
  include List

  (**	[List.split_and_remove e l] split the list [l] in
      a couple of list [(l1, l2)] where [l1] contains all
      the element of [l] before and without [e] and [l2]
      contains all the element of [l] after and without
      [e]. *)
  let rec split_and_remove : 'a -> 'a list -> 'a list * 'a list =
    fun e -> function
    | [] ->
      ([], [])
    | a::l when a = e ->
      ([], l)
    | a::l ->
      let (l1, l2) = split_and_remove e l in
      (a::l1, l2)

end




module Make (IT : ItineraryType) =
struct

  type t = float * (M.node_id * float) list
  exception Unattainable


  (* A Star parametrization *)

  module MapAstar = Astar.Make (
    struct

      type t = M.node_id

      type cost = float

      let ( $+ ) x y = ( +. ) x y

      let ( $- ) x y = ( -. ) x y

      let ( $< ) x y = ( < ) x y

      let int_of_cost c = c *. 1000.0 |> int_of_float

      let distance_of_node id1 id2 =
        let (lat1, lon1) = M.coords_of_id IT.map id1
        and (lat2, lon2) = M.coords_of_id IT.map id2 in
        Geodetic.distance lat1 lon1 lat2 lon2


      (* This assumes that there is a unique goal *)
      let heuristic id =
        let distance_to_goal = function
          | [x] -> distance_of_node id x
          | _ -> assert false (* By precondition *)
        in
        match IT.cost_type with
        | `Distance	->
          distance_to_goal
        | `Time ->
          begin
            match IT.vehicule_type with
            | `Motorized ->
              (* Actualy does real Dijkstra algorithm. *)
              fun _ -> 0.0
            (* Assuming pedestrian and bicycle move with a constant
             * speed, we use distance. *)
            | `Bicycle | `Pedestrian ->
              distance_to_goal
          end

      let road_cost id1 id2 = match IT.cost_type with
        | `Distance ->
          M.distance_of_transition IT.map id1 id2
        | `Time ->
          begin
            match IT.vehicule_type with
            | `Motorized ->
              begin
                match M.time_of_transition IT.map id1 id2 with
                | None -> assert false (* By Roads.t *)
                | Some f -> f
              end
            (* Assuming pedestrian and bicycle move with a constant
             * speed, we use distance. *)
            | `Bicycle | `Pedestrian ->
              M.distance_of_transition IT.map id1 id2
          end

      let nexts id =
        let aux res (n, l) = M.(
          match IT.vehicule_type with
          | `Motorized ->
              if List.exists (fun (_, _, (Motorized m, _, _), _) -> m) l then
                n::res
              else res
          | `Bicycle ->
              if List.exists (fun (_, _, (_, Bicycle b, _), _) -> b) l then
                n::res
              else res
          | `Pedestrian ->
              if List.exists (fun (_, _, (_, _, Pedestrian p), _) -> p) l then
                n::res
              else res
        ) in
        M.Roads.get_transitions IT.map id |> List.fold_left aux []

    end
  )



  (*	Shortest way searching *)

  let from_map id1 id2 =

    (** [transform_pnode_to_inode map id] operates mofifications on
        the [map] to transform the node binded with the [id] into a
        pnode if it is an inode *)
    let transform_pnode_to_inode = M.(
      let find_transition_of_pathnode p tl =
        List.find (
          fun (_, _, _, Way (_, _, nodes)) -> List.exists (fun x -> x = p) nodes
        ) tl
      in
      fun map id -> match M.Roads.get_node map id with
      | `Inode _ -> ()
      | `Pnode (PathNode ((x, y), s)) ->
        Roads.insecure_remove_node map id;
        Roads.add_node map id (`Inode (IntersectionNode (x, y)));
        List.iter (
          fun (id1, id2) ->
            let (Distance d, t, v, Way (w, n, l)) =
              Roads.find_transitions map id1 id2
              |> find_transition_of_pathnode id in
            Roads.remove_transition map id1 (Distance d, t, v, Way (w, n, l)) id2;
            let (l1, l2) = List.split_and_remove id l in
            let d1 = M.calculate_dist l1 id1 id map in
            let d2 = M.calculate_dist l2 id id2 map in
            let (t1, t2) = match t with
              | Time None ->
                (Time None, Time None)
              | Time (Some f) ->
                Time (Some ((f *. d1) /. d)), Time (Some ((f *. d2) /. d))
            in
            Roads.add_transition
              map id1 (Distance d1, t1, v, Way(w, n, l2)) id;
            Roads.add_transition
              map id (Distance d2, t2, v, Way(w, n, l1)) id2;
        ) s
    )
    in

    transform_pnode_to_inode IT.map id1;
    transform_pnode_to_inode IT.map id2;

    (* Lists of all the intersections *)
    try
      let (intersections, itinerary_cost) = MapAstar.astart [(id1, 0.0)] [id2] in
      (itinerary_cost, intersections)
    with MapAstar.Unattainable ->
      raise Unattainable

end

