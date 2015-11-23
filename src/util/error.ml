
(* Error gestion *)

let err_msg place kind msg =
  output_string stderr (Printf.sprintf " in %s :\n\t%s : %s\n" place kind msg)


let err place kind msg =
  output_string stderr "Error";
  err_msg place kind msg;
  exit

let warn () =
  output_string stderr "/!\\ Warning";
  err_msg


(* Error Codes *)

let commandLine = 10


