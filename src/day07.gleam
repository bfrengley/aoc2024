import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import util.{get_input, ignore}

const example_input = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"

pub fn run() -> Nil {
  // let in = example_input
  let assert Ok(in) = get_input(7)

  let equations =
    string.split(in, "\n")
    |> list.filter_map(string.split_once(_, ": "))
    |> list.map(fn(p) { pair.map_second(p, string.split(_, " ")) })
    |> list.map(fn(p) {
      let #(n, ns) = p
      let assert Ok(n) = int.parse(n)
      let assert Ok(ns) = result.all(list.map(ns, int.parse))
      #(n, ns)
    })

  equations
  |> list.filter_map(fn(p) {
    let #(target, vals) = p
    let assert [n, ..rest] = vals
    try_eval(target, n, rest, [int.add, int.multiply])
  })
  |> int.sum
  |> io.debug
  |> ignore

  equations
  |> list.filter_map(fn(p) {
    let #(target, vals) = p
    let assert [n, ..rest] = vals
    try_eval(target, n, rest, [int.add, int.multiply, int_concat])
  })
  |> int.sum
  |> io.debug
  |> ignore
}

fn try_eval(
  target: Int,
  acc: Int,
  vals: List(Int),
  ops: List(fn(Int, Int) -> Int),
) -> Result(Int, Nil) {
  case vals {
    [] ->
      case acc == target {
        True -> Ok(acc)
        False -> Error(Nil)
      }
    [n, ..rest] ->
      list.find_map(ops, fn(op) { try_eval(target, op(acc, n), rest, ops) })
  }
}

fn int_concat(n1: Int, n2: Int) -> Int {
  let assert Ok(digits) = int.digits(n2, 10)
  let assert Ok(p) = int.power(10, list.length(digits) |> int.to_float)
  n1 * float.truncate(p) + n2
}
