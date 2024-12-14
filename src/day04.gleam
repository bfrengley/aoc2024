import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util.{get_input, ignore}

const example_input = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

const dirs = [
  #(0, 1), #(1, 1), #(1, 0), #(0, -1), #(-1, -1), #(-1, 0), #(1, -1), #(-1, 1),
]

type WordSearch =
  dict.Dict(#(Int, Int), String)

pub fn run() -> Nil {
  // let in = example_input
  let assert Ok(in) = get_input(4)

  let word = string.to_graphemes("XMAS")

  let ws =
    in
    |> string.split("\n")
    |> list.index_fold(from: dict.new(), with: fn(d, line, y) {
      line
      |> string.to_graphemes()
      |> list.index_fold(from: d, with: fn(d, s, x) {
        dict.insert(d, #(x, y), s)
      })
    })

  ws
  |> dict.keys
  |> list.flat_map(fn(pos) { list.filter(dirs, find_word(ws, pos, _, word)) })
  |> list.length
  |> io.debug
  |> ignore

  ws
  |> dict.keys
  |> list.filter_map(find_cross(ws, _))
  |> list.length
  |> io.debug
  |> ignore
}

fn find_word(
  ws: WordSearch,
  from: #(Int, Int),
  dir: #(Int, Int),
  word: List(String),
) -> Bool {
  case word {
    [] -> True
    [letter, ..rest] -> {
      case dict.get(ws, from) {
        Ok(l) -> {
          let #(x, y) = from
          let #(dx, dy) = dir
          l == letter && find_word(ws, #(x + dx, y + dy), dir, rest)
        }
        Error(_) -> False
      }
    }
  }
}

fn find_cross(ws: WordSearch, from: #(Int, Int)) -> Result(Bool, Nil) {
  let #(x, y) = from
  use center <- result.try(dict.get(ws, from))
  use top_left <- result.try(dict.get(ws, #(x - 1, y - 1)))
  use top_right <- result.try(dict.get(ws, #(x + 1, y - 1)))
  use btm_left <- result.try(dict.get(ws, #(x - 1, y + 1)))
  use btm_right <- result.try(dict.get(ws, #(x + 1, y + 1)))

  let ok =
    center == "A"
    && {
      { top_left == "M" && btm_right == "S" }
      || { top_left == "S" && btm_right == "M" }
    }
    && {
      { btm_left == "M" && top_right == "S" }
      || { btm_left == "S" && top_right == "M" }
    }
  case ok {
    True -> Ok(True)
    False -> Error(Nil)
  }
}
