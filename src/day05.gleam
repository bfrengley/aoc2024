import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import util.{get_input, ignore}

const example_input = "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"

pub fn run() -> Nil {
  let assert Ok(in) = get_input(5)

  let lines = string.split(in, "\n")
  let #(rule_lines, update_lines) =
    list.split_while(lines, fn(s) { !string.is_empty(s) })

  let rules =
    rule_lines
    |> list.filter_map(string.split_once(_, "|"))
    |> list.fold(from: dict.new(), with: fn(rules, ss) {
      let #(s1, s2) = ss
      let assert Ok(x) = int.parse(s1)
      let assert Ok(y) = int.parse(s2)
      dict.upsert(rules, x, fn(ys) {
        case ys {
          option.Some(s) -> set.insert(s, y)
          option.None -> set.from_list([y])
        }
      })
    })

  let updates =
    update_lines
    |> list.filter_map(fn(line) {
      line
      |> string.split(",")
      |> list.map(int.parse)
      |> result.all
    })

  let #(valids, invalids) = list.partition(updates, is_valid_update(_, rules))

  valids
  |> list.map(fn(update) {
    list.drop(update, list.length(update) / 2) |> list.first |> result.unwrap(0)
  })
  |> int.sum
  |> io.debug
  |> ignore
}

fn is_valid_update(
  update: List(Int),
  rules: dict.Dict(Int, set.Set(Int)),
) -> Bool {
  is_valid_update_inner(update, set.from_list(update), set.new(), rules)
}

fn is_valid_update_inner(
  pages: List(Int),
  update: set.Set(Int),
  expect: set.Set(Int),
  rules: dict.Dict(Int, set.Set(Int)),
) -> Bool {
  case pages {
    [] -> set.is_disjoint(update, expect)
    [n, ..rest] -> {
      let expect = set.delete(expect, n)
      let expect = case dict.get(rules, n) {
        Ok(ys) -> set.union(expect, ys)
        Error(_) -> expect
      }
      is_valid_update_inner(rest, update, expect, rules)
    }
  }
}
