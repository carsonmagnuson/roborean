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
      let* result = Obscurity.fetch_entry ~api_key word in
      match result with
      | Ok body -> Dream.json body
      | Error e -> Dream.json (Printf.sprintf {|{"error": "%s"}|} e))
  ]


