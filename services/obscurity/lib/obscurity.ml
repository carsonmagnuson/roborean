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


let ( let* ) = Lwt.bind

(*
This function performs an HTTP GET request to a given URL and handles the response.
It returns a Result type: Ok with the response body if successful, or Error with an error message.
--from OCaml docs
*)

let http_get url =
  let* (resp, body) =
    Cohttp_lwt_unix.Client.get (Uri.of_string url)
  in
  let code = resp
             |> Cohttp.Response.status
             |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code
  then
    let* b = Cohttp_lwt.Body.to_string body in
    Lwt.return (Ok b)
  else
    Lwt.return (Error (
      Cohttp.Code.reason_phrase_of_code code
    ))



(*
API call with the api key and chosen word.
*)
let fetch_entry ~api_key word = 
  let url =
    Printf.sprintf
      "https://www.dictionaryapi.com/api/v3/references/collegiate/json/%s?key=%s"
      (Uri.pct_encode word) api_key
  in
  let* result = http_get url in 
  match result with
  | Error e -> Lwt.return (Error e)
  | Ok body -> Lwt.return (Ok body)


let short_def body =
  let json = Yojson.Basic.from_string body in
  let open Yojson.Basic.Util in 
  json |> to_list |> List.hd |> member "shortdef" |> to_list |> List.map to_string


  



