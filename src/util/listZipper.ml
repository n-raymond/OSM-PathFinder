

type 'a stack = 'a list

type 'a t = 'a stack * 'a list

exception Start

exception End

let empty () = ([], [])

let from_list l = ([], l)

let to_list (c, l) =
  let rec revapp l = function
    | []	  -> l
    | h::r  -> revapp (h::l) r
  in revapp l c

let next = function
  | (_, [])	  -> raise End
  | (s, a::l)	-> (a::s, l)

let previous = function
  | ([], _)   -> raise Start
  | (a::s, l) -> (s, a::l)

let element = function
  | (_, [])   -> raise End
  | (_, a::l) -> a

let insert e (s, l) = (s, e::l)

let delete = function
  | (_, [])	  -> raise End
  | (s, a::l) -> (s, l)

