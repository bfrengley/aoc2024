import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util.{get_input, ignore}

const example_input = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn run() -> Nil {
  let assert Ok(input) = get_input(2)

  let data =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(" ")
      |> list.filter_map(int.parse)
    })

  do_part(data, False)
  do_part(data, True)
}

fn do_part(data: List(List(Int)), tolerant: Bool) -> Nil {
  data
  |> list.filter(fn(l) {
    is_valid_report(l)
    || {
      tolerant
      && {
        let assert [first, ..rest] = l
        is_valid_report_tolerant(first, [], rest)
      }
    }
  })
  |> list.length
  |> io.debug
  |> ignore
}

fn is_valid_report(report: List(Int)) -> Bool {
  case report {
    [_] | [] -> False
    [a, b] -> valid_diff(a - b)
    [a, b, c, ..rest] -> {
      let diff_ab = a - b
      let diff_bc = b - c
      let sign_match = diff_ab > 0 == diff_bc > 0
      case valid_diff(diff_ab) && valid_diff(diff_bc) && sign_match {
        True -> is_valid_report([b, c, ..rest])
        False -> False
      }
    }
  }
}

// this is very brute force, since list.appends are O(n)
fn is_valid_report_tolerant(
  dropped_val: Int,
  left: List(Int),
  right: List(Int),
) -> Bool {
  case is_valid_report(list.append(left, right)) {
    True -> True
    False ->
      case right {
        [n, ..rest] ->
          is_valid_report_tolerant(n, list.append(left, [dropped_val]), rest)
        _ -> False
      }
  }
}

fn valid_diff(diff: Int) -> Bool {
  let diff = int.absolute_value(diff)
  diff >= 1 && diff <= 3
}
