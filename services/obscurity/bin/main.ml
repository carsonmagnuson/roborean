let table = Obscurity.load_table "data/count_1w.txt"
let ( let* ) = Lwt.bind 


let () = Dotenv.export () |> ignore
let api_key = 
  match Sys.getenv_opt "MW_API_KEY" with
  | Some value -> value
  | None -> failwith "No API Key"

let () = 
  Dream.run ~interface:"0.0.0.0" ~port:8080
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _req ->
      Dream.html "obscurity service lives");

    Dream.get "/freq/:word" (fun req ->
      let word = Dream.param req "word" in
      let response =
        match Hashtbl.find_opt table word with
        | Some count -> Printf.sprintf {|{"word": "%s", "count": %d}|} word count
        | None -> Printf.sprintf {|{"word": "%s", "count": "not found in corpus"}|} word
      in
      Dream.json response);

    Dream.get "/score/:word" (fun req ->
      let word = Dream.param req "word" in
      let response =
        match Hashtbl.find_opt table word with
        | Some count -> 
            let c = Obscurity.obscurity (float_of_int count) 1_024_908_267_229.0 in 
            Printf.sprintf {|{"word": "%s", "score": %f}|} word c
        | None -> Printf.sprintf {|{"word": "%s", "score": "not found in corpus"}|} word
      in
      Dream.json response);

    Dream.get "/define/:word" (fun req ->
      let word = Dream.param req "word" in
      let* result = Obscurity.mw_entries ~api_key word in
      match result with
      | Ok body -> (
        match Obscurity.short_def word body with
        | Ok entries ->
          let entry_json (pos, senses) =
            `Assoc [ ("pos", `String pos);
                     ("senses", `List (List.map (fun s -> `String s) senses)) ]
          in
          Dream.json (Yojson.Basic.to_string
            (`Assoc [ ("word", `String word);
                      ("entries", `List (List.map entry_json entries)) ]))

        | Error `Not_found_with_suggestions ->
            Dream.json ~status:`Not_Found {|{"error": "no entry"}|}
        | Error `Bad_response ->
            Dream.json ~status:`Bad_Gateway {|{"error": "upstream shape"}|})
      | Error e -> Dream.json ~status:`Internal_Server_Error  (Printf.sprintf {|{"error": "%s"}|} e))
  ]
