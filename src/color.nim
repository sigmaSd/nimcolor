import std/strformat
import std/macros
import std/strutils

type ColorGround* = enum
    Fg, Bg

proc `$`*(ground: ColorGround): string =
    const FG_DEL = "38;2"
    const BG_DEL = "48;2"
    case ground
        of Fg: FG_DEL
        of Bg: BG_DEL

type ColorDesc* = object
    r, g, b: uint8
    ground: ColorGround

proc `$`*(desc: ColorDesc): string =
    fmt"{desc.ground};{desc.r};{desc.g};{desc.b}"


type Style* = enum
    Bold, Faint, Italic, Underline, ReverseVideo, CrossedOut

proc `$`*(style: Style): string =
    case style:
        of Bold: "1"
        of Faint: "2"
        of Italic: "3"
        of Underline: "4"
        of ReverseVideo: "7"
        of CrossedOut: "9"

type
    Colored* = object
        str: string
        descs: seq[string]

proc `$`*(color: Colored): string =
    const
        START_DEL = "\x1b["
        COMPONENT_DEL = ";"
        END_DEL = "\x1b[0m"
        COLOR_END_DEL = "m"

    result = START_DEL
    for d in color.descs:
        result.add($d)
        result.add(COMPONENT_DEL)
    result = result[0..^2]
    result.add(fmt"{COLOR_END_DEL}{color.str}{END_DEL}")

type ColorType* = string or Colored

proc color*[T: ColorType](fmt: T, desc: ColorDesc): Colored =
    when fmt is string:
        Colored(str: fmt, descs: @[$desc])
    elif fmt is Colored:
        var descs = fmt.descs
        descs.add($desc)
        Colored(str: fmt.str, descs: descs)


proc style*[T: ColorType](fmt: T, style: Style): Colored =
    when fmt is string:
        Colored(str: fmt, descs: @[$style])
    elif fmt is Colored:
        var descs = fmt.descs
        descs.add($style)
        Colored(str: fmt.str, descs: descs)

proc rgb*[T: ColorType](fmt: T, r, g, b: uint8 = 0): Colored =
    fmt.color(ColorDesc(r: r, g: g, b: b, ground: Fg))

proc rgbBg*[T: ColorType](fmt: T, r, g, b: uint8 = 0): Colored =
    fmt.color(ColorDesc(r: r, g: g, b: b, ground: Bg))

macro createColor(color: untyped, r, g, b: uint8 = 0): untyped =
    let colorBg = ident(fmt("{`color`}Bg"))
    quote do:
        proc `color`*[T: ColorType](fmt: T): Colored =
            fmt.rgb(`r`, `g`, `b`)
        proc `colorBg`*[T: ColorType](fmt: T): Colored =
            fmt.rgbBg(`r`, `g`, `b`)

macro createStyles(styles: untyped): untyped =
  let r = newStmtList()
  for styleName in styles: 
    let procName = fmt"{`styleName`}".toLower.ident
    r.add(
      quote do:
        proc `procName`*[T: ColorType](fmt: T): Colored =
          fmt.style(`styleName`)
    )
  r

createColor(red, 255)
createColor(green, 0, 255)
createColor(blue, 0, 0, 255)
createColor(yellow, 255, 255, 0)
createColor(purple, 255, 0, 255)
createColor(lightBlue, 0, 255, 255)
createStyles([Bold, Faint, Italic, Underline, ReverseVideo, CrossedOut])
