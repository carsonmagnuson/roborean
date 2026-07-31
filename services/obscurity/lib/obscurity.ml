(**
   [obscurity count total] maps a word's corpus frequency to an obscurity score that acts similar to the inverse of a Zipf score.
 *)
let obscurity count total = count /. total *. 1e9 |> log10 |> ( -. ) 8.

let min_fpm = 1e-6

(** [obscurity_of_fpm f] maps a Datamuse frequency (occurrences per million
    words) onto the same scale as [obscurity]. Per-million x 1e3 = per-billion,
    which is the unit [obscurity] normalizes to internally. *)
let obscurity_of_fpm f = 
  let f = if f < min_fpm then min_fpm else f in 8. -. log10 (f *. 1e3)

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


let http_get uri =
  let* (resp, body) =
    Cohttp_lwt_unix.Client.get uri
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
Muse uri encoder
*)
let muse_uri word =
  Uri.make
    ~scheme:"https"
    ~host:"api.datamuse.com"
    ~path:"/words"
    ~query:[ ("sp", [word]); ("md", ["f"]); ("max", ["1"]) ]
    ()


(*
Datamuse API call for chosen word frequency
*)
let muse_entries word = http_get (muse_uri word)


(*
MW uri encoder
*)
let mw_uri ~api_key word =
  Uri.make 
    ~scheme:"https" 
    ~host:"www.dictionaryapi.com" 
    ~path:("/api/v3/references/collegiate/json/" ^ Uri.pct_encode ~component: `Generic word) 
    ~query: [ ("key", [api_key])]
  ()

(*
MW API call with the api key and chosen word.
*)
let mw_entries ~api_key word = 
  http_get (mw_uri ~api_key word)

(** 'special' words with no Merriam-Webster entry that we still want to define. Checked
    before the upstream call.
*)
let local_entries =
  [ ("roborean",
     [ ("adjective", [ "strong; like an oak. Coincidentally, also the name of this website." ]) ]) ]

let local_def word =
  List.assoc_opt (String.lowercase_ascii word) local_entries



(** [short_def body] extracts the first entry's short definitions from a raw
    Merriam-Webster collegiate JSON response. Returns [Ok defs] on success,
    [Error `Not_found_with_suggestions] when MW returns spelling suggestions,
    or [Error `Bad_response] on any unexpected shape. *)
let short_def word body =
  let open Yojson.Basic.Util in 
  let headword_matches entry =
    match entry |> member "meta" |> member "id" with
    | `String id ->
        (match String.split_on_char ':' id with
         | base :: _ -> String.lowercase_ascii base = String.lowercase_ascii word
         | [] -> false)
    | _ -> false
  in
  let strings_of = function
    | `List l -> List.filter_map (function `String s -> Some s | _ -> None) l
    | _ -> []
  in
  match Yojson.Basic.from_string body with
  | `List (`Assoc _ :: _ as entries) ->
      let matched =
        List.filter_map
          (fun entry ->
            if headword_matches entry then
              let pos =
                match entry |> member "fl" with `String s -> s | _ -> ""
              in
              Some (pos, strings_of (entry |> member "shortdef"))
            else None)
          entries
      in
      Ok matched
  | `List (`String _ :: _) -> Error `Not_found_with_suggestions
  | _ -> Error `Bad_response
  | exception Yojson.Json_error _ -> Error `Bad_response

(** [muse_freq word body] extracts the frequency (occurrences per million words)
    for [word] from a raw Datamuse JSON response. Returns [Ok f] on success,
    [Error `Not_in_vocab] when Datamuse has no matching entry,
    [Error `No_frequency] when the entry carries no [f:] tag, or
    [Error `Bad_response] on any unexpected shape. 
*)
let frequency word body =
  let open Yojson.Basic.Util in
  let freq_of_tag tag =
    match String.split_on_char ':' tag with
    | [ "f"; value ] -> float_of_string_opt value
    | _ -> None
  in
  match Yojson.Basic.from_string body with
  | `List [] -> Error `Not_in_vocab
  | `List ((`Assoc _ as entry) :: _) ->
      let matches =
        match entry |> member "word" with
        | `String w -> String.lowercase_ascii w = String.lowercase_ascii word
        | _ -> false
      in
      if not matches then Error `Not_in_vocab
      else (
        match entry |> member "tags" with
        | `List tags -> (
            match List.find_map freq_of_tag (filter_string tags) with
            | Some f -> Ok f
            | None -> Error `No_frequency)
        | _ -> Error `No_frequency)
  | _ -> Error `Bad_response
  | exception Yojson.Json_error _ -> Error `Bad_response

