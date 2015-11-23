

let from_map map file =
  let oc = open_out file in
  Marshal.to_channel oc map [];
  close_out oc

let to_map file =
  let ic = open_in file in
  let map = (Marshal.from_channel ic : MapData.map) in
  let _ = close_in ic in
  map

