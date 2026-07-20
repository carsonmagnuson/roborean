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
  



