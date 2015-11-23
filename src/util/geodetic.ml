(** Geodetic

    Regroups different geodetic functionalities *)

(** The value of pi *)
let  pi = 4.0 *. atan 1.0

(** The average radius of the Earth in km *)
let r = 6371.0

(** Converts an angle in degree to an angle in radian *)
let to_radian x = x *. pi /. 180.0

(** Calculate a distance between two points *)
let distance lat1 lon1 lat2 lon2 =
  let latitude1 = to_radian lat1
  and latitude2 = to_radian lat2
  and diff_lon = lon1 -. lon2 |> to_radian in
  sin latitude1 *. sin latitude2
  +. cos latitude1 *. cos latitude2 *. cos diff_lon
  |> acos |> ( *. ) r

(**	Calculate the direction of a vector from his coordinates
    and retrun the result in an angle in degrees, considering
    that north pole corresponds to 0°. *)
let vector lat1 lon1 lat2 lon2 =
  let v1 = (sin(lon1-.lon2) *. cos(lat2)) in
  let v2 = (cos(lat1) *. sin(lat2)
          -. sin(lat1) *. cos(lat2) *. cos(lon1-.lon2)) in
  mod_float (atan2 v1 v2) (2.0 *. pi)





