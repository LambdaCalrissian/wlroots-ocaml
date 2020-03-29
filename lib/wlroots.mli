open Wlroots_common.Sigs

type event = ..

module Wl : sig
  module Event_loop : sig
    type t
    include Comparable0 with type t := t
  end

  module Listener : sig
    type t
    include Comparable0 with type t := t

    val create : unit -> t
    val state : t -> [`attached | `detached]
    val detach : t -> unit
  end

  module Signal : sig
    type 'a t
    include Comparable1 with type 'a t := 'a t

    val subscribe : 'a t -> Listener.t -> ('a -> unit) -> unit
  end

  module Display : sig
    type t
    include Comparable0 with type t := t

    val create : unit -> t
    val get_event_loop : t -> Event_loop.t
    val run : t -> unit
    val destroy : t -> unit
    val add_socket_auto : t -> string
    val init_shm : t -> int
  end

  module Resource : sig
    type t
    include Comparable0 with type t := t
  end

  module Output_transform : sig
    type t
    include Comparable0 with type t := t
  end
end

module Texture : sig
  type t
  include Comparable0 with type t := t
end

module Surface : sig
  type t
  include Comparable0 with type t := t

  val from_resource : Wl.Resource.t -> t
  val has_buffer : t -> bool

  module State : sig
    type t
    include Comparable0 with type t := t
    val width : t -> int
    val height : t -> int
    val transform : t -> Wl.Output_transform.t
  end

  val current : t -> State.t
  val pending : t -> State.t
  val send_frame_done : t -> Mtime.t -> unit
end

module Box : sig
  type t = { x : int; y : int; width : int; height : int }
  include Comparable0 with type t := t
end

module Matrix : sig
  type t
  include Comparable0 with type t := t
  val project_box : Box.t -> Wl.Output_transform.t -> rotation:float -> t -> t
end

module Output : sig
  type t
  include Comparable0 with type t := t

  type event +=
    | Frame of t
    | Destroy of t

  module Mode : sig
    type t
    include Comparable0 with type t := t

    val width : t -> int32
    val height : t -> int32
    val refresh : t -> int32 (* mHz *)
    val preferred : t -> bool
  end

  (* Setting an output mode *)
  val modes : t -> Mode.t list
  val set_mode : t -> Mode.t -> unit
  val best_mode : t -> Mode.t option
  val set_best_mode : t -> unit

  val transform_matrix : t -> Matrix.t
  val create_global : t -> unit
  val attach_render : t -> bool
  val commit : t -> bool
end

module Keyboard : sig
  type t
  include Comparable0 with type t := t
end

module Pointer : sig
  type t
  include Comparable0 with type t := t
end

module Touch : sig
  type t
  include Comparable0 with type t := t
end

module Tablet_tool : sig
  type t
  include Comparable0 with type t := t
end

module Tablet_pad : sig
  type t
  include Comparable0 with type t := t
end

module Input_device : sig
  type t
  include Comparable0 with type t := t

  type event +=
    | Destroy of t

  type typ =
    | Keyboard of Keyboard.t
    | Pointer of Pointer.t
    | Touch of Touch.t
    | Tablet of Tablet_tool.t
    | Tablet_pad of Tablet_pad.t

  val typ : t -> typ
  val vendor : t -> int
  val product : t -> int
  val name : t -> string
end

module Renderer : sig
  type t
  include Comparable0 with type t := t

  val begin_ : t -> width:int -> height:int -> unit
  val end_ : t -> unit
  val clear : t -> float * float * float * float -> unit
end

module Backend : sig
  type t
  include Comparable0 with type t := t

  val autocreate : Wl.Display.t -> t
end

module Compositor : sig
  type t

  type event +=
    | New_output of Output.t
    | New_input of Input_device.t

  val create :
    ?manage_outputs:bool ->
    ?manage_inputs:bool ->
    unit ->
    t

  val display : t -> Wl.Display.t
  val event_loop : t -> Wl.Event_loop.t
  val renderer : t -> Renderer.t
end

module Main : sig
  val run :
    state:'a ->
    handler:(event -> 'a -> 'a) ->
    Compositor.t ->
    unit

  val terminate : Compositor.t -> unit
end

module Log : sig
  type importance =
    | Silent
    | Error
    | Info
    | Debug

  val init : importance -> unit
end
