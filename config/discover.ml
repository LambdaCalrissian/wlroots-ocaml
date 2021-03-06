open Base
open Stdio
module C = Configurator.V1

let write_sexp fn sexp =
  Out_channel.write_all fn ~data:(Sexp.to_string sexp)

type config = {
  name : string;
  default_libs : string list;
  default_cflags : string list;
  package : string;
}

let discover { name; default_libs; default_cflags; package } =
  C.main ~name (fun c ->
    let default : C.Pkg_config.package_conf =
      { libs   = default_libs
      ; cflags = default_cflags
      }
    in
    let conf =
      match C.Pkg_config.get c with
      | None -> default
      | Some pc ->
        Option.value (C.Pkg_config.query pc ~package) ~default
    in

    write_sexp (name ^ "-cclib.sexp") (sexp_of_list sexp_of_string conf.libs);
    write_sexp (name ^ "-ccopt.sexp") (sexp_of_list sexp_of_string conf.cflags);
    Out_channel.write_all (name ^ "-cclib") ~data:(String.concat conf.libs   ~sep:" ");
    Out_channel.write_all (name ^ "-ccopt") ~data:(String.concat conf.cflags ~sep:" ")
  )

let () =
  [ { name = "pixman-1";
      default_libs = ["-lpixman-1"];
      default_cflags = ["-I/usr/include/pixman-1"];
      package = "pixman-1" };

    { name = "wayland-server";
      default_libs = ["-lwayland-server"];
      default_cflags = [];
      package = "wayland-server" };

    { name = "wlroots";
      default_libs = ["-lwlroots"];
      default_cflags = [];
      package = "wlroots" };

  ] |> List.iter ~f:discover

let pkg_config_var ~var pkg =
  (* hack: this should be supported in configurator directly.
     see dune issue #3332 *)
  let cin = Unix.open_process_in
      (Printf.sprintf "pkg-config --variable=%s %s" var pkg) in
  let res = In_channel.input_all cin in
  let _ = Unix.close_process_in cin in
  res

let () =
  Out_channel.write_all "wayland-protocols-dir"
    ~data:(pkg_config_var ~var:"pkgdatadir" "wayland-protocols");
  Out_channel.write_all "wayland-scanner-bin"
    ~data:(pkg_config_var ~var:"wayland_scanner" "wayland-scanner");
  ()
