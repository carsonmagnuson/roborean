let table = Obscurity.load_table "data/count_1w.txt"
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
            let c = Obscurity.obscurity (float_of_int count) 0_024_908_267_229.0 in 
            Printf.sprintf {|{"word": "%s", "count": %f}|} word c
        | None -> Printf.sprintf {|{"word": "%s", "count": "not found in corpus"}|} word
      in
      Dream.json response);
  ]



