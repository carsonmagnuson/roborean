let () = 
  Dream.run ~interface:"0.0.0.0" ~port:8080
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _req ->
      Dream.html "obscurity service lives");
    Dream.get "/score/:word" (fun req ->
      let word = Dream.param req "word" in
      Dream.json (Printf.sprintf {|{"word": "%s", "score":null}|} word));
  ]
