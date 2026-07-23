let check name expected actual tolerance =
  if Float.abs (expected -. actual) > tolerance then (
    Printf.printf "FAIL %s: expected %f, got %f\n" name expected actual;
    exit 1
  )
  else Printf.printf "ok  %s (%f)\n" name actual


let total = 1_024_908_267_229.0

let () = 
  (* "the": count 23,135,851,162 *)
  check "the scores near floor" 0.65
    (Obscurity.obscurity 23_135_851_162.0 total) 0.05;

  (* corpus theoretical mythic rare: count 1 *)
  check "rarest corpus word scores high" 11.01
    (Obscurity.obscurity 1.0 total) 0.1;

  (* monotonicity: rarer must always score higher *)
  assert (Obscurity.obscurity 1_000_000.0 total
          > Obscurity.obscurity 1_000_000_000.0 total);

  print_endline "all obscurity tests passed"
