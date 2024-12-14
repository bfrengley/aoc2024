import argv
import day01
import day02
import day03
import day04
import day05
import day06
import gleam/io

pub fn main() {
  case argv.load().arguments {
    ["1"] -> day01.run()
    ["2"] -> day02.run()
    ["3"] -> day03.run()
    ["4"] -> day04.run()
    ["5"] -> day05.run()
    ["6"] -> day06.run()
    _ -> io.println_error("Usage: gleam run <day>")
  }
}
