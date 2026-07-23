(**
   [obscurity count total] maps a word's corpus frequency to an obscurity score that acts similar to the inverse of a Zipf score.
 *)
let obscurity count total = count /. total *. 1e9 |> log10 |> ( -. ) 8.

(** 
    [load_table path] reads a tab-separated [word\tcount] frequency file
    and returns a hashtable mapping each word to its total occurrences. 
    *)
let load_table path = 
  let lines = In_channel.with_open_text path In_channel.input_lines in
  let table = Hashtbl.create 400_000 in
  List.iter
    (fun line ->
      match String.split_on_char '\t' line with
      | [word; count] -> (
        match int_of_string_opt count with
        | Some n -> Hashtbl.add table word n
        | None -> ())
      | _ -> ())
    lines;
  table  



