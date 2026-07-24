let check name expected actual tolerance =
  if Float.abs (expected -. actual) > tolerance then (
    Printf.printf "FAIL %s: expected %f, got %f\n" name expected actual;
    exit 1
  )
  else Printf.printf "ok  %s (%f)\n" name actual


let total = 1_024_908_267_229.0

let fail name = Printf.printf "FAIL %s\n" name; exit 1
let pass name = Printf.printf "ok   %s\n" name

let () = 
  (* "the": count 23,135,851,162 *)
  check "the scores near floor" 0.65
    (Obscurity.obscurity 23_135_851_162.0 total) 0.05;

  (* corpus theoretical mythic/legendary/lost: count 1 *)
  check "rarest corpus word scores high" 11.01
    (Obscurity.obscurity 1.0 total) 0.1;

  (* monotonicity: rarer must always score higher *)
  assert (Obscurity.obscurity 1_000_000.0 total
          > Obscurity.obscurity 1_000_000_000.0 total);


  let body =
      In_channel.with_open_text "fixtures/rocket.json" In_channel.input_all
    in
    (match Obscurity.short_def "rocket" body with
     | Ok entries ->
         if List.length entries <> 3 then fail "rocket: expected 3 homographs"
         else pass "rocket: 3 homographs, compounds filtered";
         (match entries with
          | (pos1, senses1) :: _ ->
              if pos1 <> "noun" then fail "rocket: first entry should be noun";
              if not (List.exists
                        (fun s -> s = "arugula")
                        senses1)
              then fail "rocket: first noun senses look wrong"
              else pass "rocket: first homograph senses intact"
          | [] -> fail "rocket: empty entries");
         if List.exists (fun (pos, _) -> pos = "verb") entries
         then pass "rocket: verb homograph present"
         else fail "rocket: verb homograph missing"
     | Error `Bad_response -> fail "rocket fixture: bad response shape"
     | Error `Not_found_with_suggestions -> fail "rocket fixture: parsed as suggestions?!");

  print_endline "all obscurity tests passed"



