
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


