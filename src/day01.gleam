import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import simplifile
import util.{ignore}

const example_input = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn run() -> Nil {
  let assert Ok(data) =
    simplifile.read(from: "./inputs/day01.txt") |> result.map(string.trim_end)

  let lists =
    data
    |> string.split("\n")
    |> list.fold(from: #([], []), with: fn(acc, s) {
      let assert Ok(#(v1, v2)) = string.split_once(s, on: "   ")
      let assert #(Ok(v1), Ok(v2)) = #(int.parse(v1), int.parse(v2))
      #([v1, ..acc.0], [v2, ..acc.1])
    })

  part1(lists)
  part2(lists)
}

fn part1(input: #(List(Int), List(Int))) -> Nil {
  input
  |> pair.map_first(list.sort(_, by: int.compare))
  |> pair.map_second(list.sort(_, by: int.compare))
  |> fn(p) { list.zip(p.0, p.1) }
  |> list.map(fn(ns) { int.absolute_value(ns.0 - ns.1) })
  |> int.sum
  |> io.debug
  |> ignore
}

fn part2(input: #(List(Int), List(Int))) -> Nil {
  let counts =
    list.fold(over: input.1, from: dict.new(), with: fn(acc, n) {
      dict.upsert(in: acc, update: n, with: fn(entry) {
        option.unwrap(entry, 0) + 1
      })
    })

  input.0
  |> list.map(fn(n) { n * { dict.get(counts, n) |> result.unwrap(0) } })
  |> int.sum
  |> io.debug
  |> ignore
}
