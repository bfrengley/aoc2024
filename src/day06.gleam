import gleam/bool.{guard, lazy_guard}
import gleam/dict
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import util.{get_input, ignore}

const example_input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

type Point =
  #(Int, Int)

type Map =
  dict.Dict(Point, Bool)

pub fn run() -> Nil {
  // let in = example_input
  let assert Ok(in) = get_input(6)

  let #(start, map) =
    in
    |> string.split("\n")
    |> list.index_fold(from: #(#(0, 0), dict.new()), with: fn(acc, line, y) {
      line
      |> string.to_graphemes()
      |> list.index_fold(from: acc, with: fn(acc, s, x) {
        let #(pos, d) = acc
        case s {
          "^" -> #(#(x, y), dict.insert(d, #(x, y), True))
          "#" -> #(pos, dict.insert(d, #(x, y), False))
          "." -> #(pos, dict.insert(d, #(x, y), True))
          _ -> panic as { "Unexpected cell value: " <> s }
        }
      })
    })

  let path = find_reverse_path(map, start, #(0, -1), [])

  path
  |> set.from_list
  |> set.size
  |> io.debug
  |> ignore

  count_obstruction_positions(map, start, path)
  |> io.debug
  |> ignore
}

fn find_reverse_path(
  map: Map,
  from: Point,
  dir: #(Int, Int),
  path: List(Point),
) -> List(Point) {
  let #(x, y) = from
  let #(dx, dy) = dir
  let next = #(x + dx, y + dy)

  case dict.get(map, next) {
    Ok(True) -> find_reverse_path(map, next, dir, [from, ..path])
    Ok(False) -> find_reverse_path(map, from, turn(dir), [from, ..path])
    Error(_) -> [from, ..path]
  }
}

fn count_obstruction_positions(
  map: Map,
  from: Point,
  in_path: List(Point),
) -> Int {
  in_path
  |> set.from_list
  |> set.to_list
  |> list.map(fn(pos) { dict.insert(map, pos, False) })
  |> list.count(is_cycle(_, from, #(0, -1), set.new()))
}

fn is_cycle(
  map: Map,
  from: Point,
  dir: #(Int, Int),
  visited: set.Set(#(Point, #(Int, Int))),
) -> Bool {
  use <- guard(when: set.contains(visited, #(from, dir)), return: True)

  let #(x, y) = from
  let #(dx, dy) = dir
  let next = #(x + dx, y + dy)

  let visited = set.insert(visited, #(from, dir))

  case dict.get(map, next) {
    Ok(True) -> {
      is_cycle(map, next, dir, visited)
    }
    Ok(False) -> is_cycle(map, from, turn(dir), visited)
    Error(_) -> False
  }
}

fn turn(dir: #(Int, Int)) -> #(Int, Int) {
  case dir {
    // down -> left
    #(0, 1) -> #(-1, 0)
    // left -> up
    #(-1, 0) -> #(0, -1)
    // up -> right
    #(0, -1) -> #(1, 0)
    // right -> down
    #(1, 0) -> #(0, 1)
    _ -> panic as "Invalid direction"
  }
}
