import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/result
import util.{get_input, ignore}

const example_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const example_input_2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn run() -> Nil {
  let assert Ok(input) = get_input(3)

  let assert Ok(regex) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do(n't)?\\(\\)")

  let operators = regexp.scan(regex, input)

  operators
  |> list.map(fn(match) {
    let regexp.Match(_, nums) = match
    execute_mul(nums)
  })
  |> int.sum
  |> io.debug
  |> ignore

  operators
  |> list.fold(#(True, 0), fn(acc, match) {
    let #(enabled, total) = acc
    let regexp.Match(val, nums) = match
    case val {
      "do()" -> #(True, total)
      "don't()" -> #(False, total)
      // mul(x,y)
      _ if enabled -> #(enabled, total + execute_mul(nums))
      _ -> #(enabled, total)
    }
  })
  |> pair.second
  |> io.debug
  |> ignore
}

fn execute_mul(nums: List(option.Option(String))) -> Int {
  list.filter_map(nums, fn(s) {
    option.to_result(s, Nil)
    |> result.try(int.parse)
  })
  |> list.reduce(int.multiply)
  |> result.unwrap(0)
}
