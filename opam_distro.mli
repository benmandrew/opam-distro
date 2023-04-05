(*
 * Copyright (c) 2016-2018 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

(** Run Opam commands across a matrix of Docker containers. Each of these
    containers represents a different version of OCaml, Opam and an OS
    distribution (such as Debian or Alpine). *)

(** {2 Known distributions and OCaml variants} *)

module Basic : sig
  type win10_release =
    [ `V1507
    | `V1511
    | `V1607
    | `V1703
    | `V1709
    | `V1803
    | `V1809
    | `V1903
    | `V1909
    | `V2004
    | `V20H2
    | `V21H1
    | `V21H2 ]
  [@@deriving sexp]

  type win10_ltsc = [ `Ltsc2015 | `Ltsc2016 | `Ltsc2019 | `Ltsc2022 ]
  [@@deriving sexp]

  type win_all = [ win10_release | win10_ltsc ] [@@deriving sexp]

  type win10_lcu =
    [ `LCU
    | `LCU20230214
    | `LCU20230110
    | `LCU20221213
    | `LCU20221108
    | `LCU20221011
    | `LCU20220913
    | `LCU20220809
    | `LCU20220712
    | `LCU20220614
    | `LCU20220510
    | `LCU20220412
    | `LCU20220308
    | `LCU20220208
    | `LCU20220111
    | `LCU20211214
    | `LCU20211109
    | `LCU20211012
    | `LCU20210914
    | `LCU20210810
    | `LCU20210713
    | `LCU20210608 ]
  [@@deriving sexp]

  val win10_current_lcu : win10_lcu

  type win10_revision = win10_release * win10_lcu option [@@deriving sexp]

  type distro =
    [ `Alpine of
      [ `V3_3
      | `V3_4
      | `V3_5
      | `V3_6
      | `V3_7
      | `V3_8
      | `V3_9
      | `V3_10
      | `V3_11
      | `V3_12
      | `V3_13
      | `V3_14
      | `V3_15
      | `V3_16
      | `V3_17 ]
    | `Archlinux of [ `Latest ]
    | `CentOS of [ `V6 | `V7 | `V8 ]
    | `Debian of [ `V11 | `V10 | `V9 | `V8 | `V7 | `Testing | `Unstable ]
    | `Fedora of
      [ `V21
      | `V22
      | `V23
      | `V24
      | `V25
      | `V26
      | `V27
      | `V28
      | `V29
      | `V30
      | `V31
      | `V32
      | `V33
      | `V34
      | `V35
      | `V36
      | `V37 ]
    | `OracleLinux of [ `V7 | `V8 ]
    | `OpenSUSE of
      [ `V42_1 | `V42_2 | `V42_3 | `V15_0 | `V15_1 | `V15_2 | `V15_3 | `V15_4 ]
    | `Ubuntu of
      [ `V12_04
      | `V14_04
      | `V15_04
      | `V15_10
      | `V16_04
      | `V16_10
      | `V17_04
      | `V17_10
      | `V18_04
      | `V18_10
      | `V19_04
      | `V19_10
      | `V20_04
      | `V20_10
      | `V21_04
      | `V21_10
      | `V22_04
      | `V22_10 ]
    | `Cygwin of win10_release
    | `Windows of [ `Mingw | `Msvc ] * win10_release ]
  [@@deriving sexp]

  type t =
    [ `Alpine of
      [ `V3_3
      | `V3_4
      | `V3_5
      | `V3_6
      | `V3_7
      | `V3_8
      | `V3_9
      | `V3_10
      | `V3_11
      | `V3_12
      | `V3_13
      | `V3_14
      | `V3_15
      | `V3_16
      | `V3_17
      | `Latest ]
    | `Archlinux of [ `Latest ]
    | `CentOS of [ `V6 | `V7 | `V8 | `Latest ]
    | `Debian of
      [ `V11 | `V10 | `V9 | `V8 | `V7 | `Stable | `Testing | `Unstable ]
    | `Fedora of
      [ `V21
      | `V22
      | `V23
      | `V24
      | `V25
      | `V26
      | `V27
      | `V28
      | `V29
      | `V30
      | `V31
      | `V32
      | `V33
      | `V34
      | `V35
      | `V36
      | `V37
      | `Latest ]
    | `OracleLinux of [ `V7 | `V8 | `Latest ]
    | `OpenSUSE of
      [ `V42_1
      | `V42_2
      | `V42_3
      | `V15_0
      | `V15_1
      | `V15_2
      | `V15_3
      | `V15_4
      | `Latest ]
    | `Ubuntu of
      [ `V12_04
      | `V14_04
      | `V15_04
      | `V15_10
      | `V16_04
      | `V16_10
      | `V17_04
      | `V17_10
      | `V18_04
      | `V18_10
      | `V19_04
      | `V19_10
      | `V20_04
      | `V20_10
      | `V21_04
      | `V21_10
      | `V22_04
      | `V22_10
      | `Latest
      | `LTS ]
    | `Cygwin of win_all
    | `Windows of [ `Mingw | `Msvc ] * win_all ]
  [@@deriving sexp]

  type os_family = [ `Cygwin | `Linux | `Windows ] [@@deriving sexp]

  val os_family_of_distro : t -> os_family
  val os_family_to_string : os_family -> string
  val opam_repository : os_family -> string
  val personality : os_family -> Ocaml_version.arch -> string option
  val is_same_distro : t -> t -> bool
  val compare : t -> t -> int
  val resolve_alias : t -> distro
  val distros : t list
  val latest_distros : t list
  val win10_latest_release : win10_release
  val win10_latest_image : win10_release
  val master_distro : t
  val builtin_ocaml_of_distro : t -> string option
  val human_readable_string_of_distro : t -> string
  val human_readable_short_string_of_distro : t -> string

  type package_manager =
    [ `Apk  (** Alpine Apk *)
    | `Apt  (** Debian Apt *)
    | `Yum  (** Fedora Yum *)
    | `Zypper  (** OpenSUSE Zypper *)
    | `Pacman  (** Archlinux Pacman *)
    | `Cygwin  (** Cygwin package manager *)
    | `Windows  (** Native Windows, WinGet, Cygwin *) ]
  [@@deriving sexp]

  val package_manager : t -> package_manager
  val bubblewrap_version : t -> (int * int * int) option
  val tag_of_distro : t -> string
  val distro_of_tag : string -> t option
  val latest_tag_of_distro : t -> string

  type win10_docker_base_image =
    [ `NanoServer  (** Windows Nano Server *)
    | `ServerCore  (** Windows Server Core *)
    | `Windows  (** Windows Server "with Desktop Experience" *) ]

  val win10_base_tag :
    ?win10_revision:win10_lcu ->
    win10_docker_base_image ->
    win_all ->
    string * string

  val base_distro_tag :
    ?win10_revision:win10_lcu ->
    ?arch:Ocaml_version.arch ->
    t ->
    string * string

  val win10_release_to_string : win10_release -> string
  val win10_release_of_string : string -> win_all option
  val win10_revision_to_string : win10_revision -> string
  val win10_revision_of_string : string -> win10_revision option
  val distro_arches : Ocaml_version.t -> t -> Ocaml_version.arch list
  val distro_supported_on : Ocaml_version.arch -> Ocaml_version.t -> t -> bool

  type win10_release_status = [ `Deprecated | `Active ]

  val win10_release_status : win_all -> win10_release_status
  val active_distros : Ocaml_version.arch -> t list
  val active_tier1_distros : Ocaml_version.arch -> t list
  val active_tier2_distros : Ocaml_version.arch -> t list
  val active_tier3_distros : Ocaml_version.arch -> t list
end

module Extended : sig
  type win10_release = Basic.win10_release
  type win10_ltsc = Basic.win10_ltsc
  type win_all = Basic.win_all
  type win10_lcu = Basic.win10_lcu

  val win10_current_lcu : win10_lcu

  type win10_revision = Basic.win10_revision
  type distro = [ Basic.distro | `Macos of [ `V12 | `V13 ] ] [@@deriving sexp]
  type t = [ Basic.t | `Macos of [ `Latest | `V12 | `V13 ] ] [@@deriving sexp]
  type os_family = [ Basic.os_family | `Macos ] [@@deriving sexp]

  val os_family_of_distro : t -> os_family
  val os_family_to_string : os_family -> string
  val opam_repository : os_family -> string
  val personality : os_family -> Ocaml_version.arch -> string option
  val is_same_distro : t -> t -> bool
  val compare : t -> t -> int
  val resolve_alias : t -> distro
  val distros : t list
  val latest_distros : t list
  val win10_latest_release : win10_release
  val win10_latest_image : win10_release
  val master_distro : t
  val builtin_ocaml_of_distro : t -> string option
  val human_readable_string_of_distro : t -> string
  val human_readable_short_string_of_distro : t -> string

  type package_manager =
    [ Basic.package_manager | `Homebrew  (** MacOS homebrew *) ]
  [@@deriving sexp]

  val package_manager : t -> package_manager
  val bubblewrap_version : t -> (int * int * int) option
  val tag_of_distro : t -> string
  val distro_of_tag : string -> t option
  val latest_tag_of_distro : t -> string

  type win10_docker_base_image = Basic.win10_docker_base_image

  val win10_base_tag :
    ?win10_revision:win10_lcu ->
    win10_docker_base_image ->
    win_all ->
    string * string

  val base_distro_tag :
    ?win10_revision:win10_lcu ->
    ?arch:Ocaml_version.arch ->
    t ->
    string * string

  val win10_release_to_string : win10_release -> string
  val win10_release_of_string : string -> win_all option
  val win10_revision_to_string : win10_revision -> string
  val win10_revision_of_string : string -> win10_revision option
  val distro_arches : Ocaml_version.t -> t -> Ocaml_version.arch list
  val distro_supported_on : Ocaml_version.arch -> Ocaml_version.t -> t -> bool

  type win10_release_status = Basic.win10_release_status

  val win10_release_status : win_all -> win10_release_status
  val active_distros : Ocaml_version.arch -> t list
  val active_tier1_distros : Ocaml_version.arch -> t list
  val active_tier2_distros : Ocaml_version.arch -> t list
  val active_tier3_distros : Ocaml_version.arch -> t list
end
