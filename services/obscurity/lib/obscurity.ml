let obscurity count total = count /. total *. 10e9 |> log10 |> ( -. ) 9.

let load_table path = 
  let lines = In_channel.with_open_text path In_channel.input_lines in
  let table = Hashtbl.create 400_000 in
  List.iter
    (fun line ->
      match String.split_on_char '\t' line with
      | [word; count] -> (
        match float_of_string_opt count with
        | Some n -> 
            obscurity n 1.02e12 |>
            Float.to_int |>
            Hashtbl.add table word
        | None -> ())
      | _ -> ())
    lines;
  table




  
