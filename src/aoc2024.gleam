import argv
import day01
import gleam/io

pub fn main() {
  case argv.load().arguments {
    ["1"] -> day01.run()
    _ -> io.println_error("Usage: gleam run <day>")
  }
}
