open! Hardcaml_waveterm

let write_vcd_if_requested waves =
  match Sys.getenv_opt "HARDCAML_VCD_PATH" with
  | Some path -> Waveform.Serialize.marshall_vcd waves path
  | None -> ()
