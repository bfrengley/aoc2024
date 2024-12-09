import envoy
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/result
import gleam/string
import simplifile

/// Discards the given value and always returns Nil. Based on F#'s `ignore`.
pub fn ignore(_: t) -> Nil {
  Nil
}

pub fn get_input(day: Int) -> Result(String, String) {
  case envoy.get("AOC_SESSION_KEY") {
    Ok(key) -> get_input_by_api(day, key)
    _ -> get_input_from_file(day)
  }
}

fn get_input_by_api(day: Int, session_key: String) -> Result(String, String) {
  use req <- result.try(
    request.to(
      "https://adventofcode.com/2024/day/" <> int.to_string(day) <> "/input",
    )
    |> result.replace_error("Failed to parse request URL"),
  )
  let req = request.prepend_header(req, "Cookie", "session=" <> session_key)

  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(string.inspect),
  )

  case resp.status {
    200 -> Ok(resp.body |> string.trim_end)
    code -> Error("Unexpected status code: " <> int.to_string(code))
  }
}

fn get_input_from_file(day: Int) -> Result(String, String) {
  simplifile.read(
    "./input/day"
    <> string.pad_start(int.to_string(day), to: 2, with: "0")
    <> ".txt",
  )
  |> result.map_error(string.inspect)
}
