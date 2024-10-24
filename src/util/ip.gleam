import gleam/int
import gleam/string

pub fn is_valid_ipv4(input: String) -> Bool {
  case string.split(input, ".") {
    [w, x, y, z] ->
      is_valid_octet(w)
      && is_valid_octet(x)
      && is_valid_octet(y)
      && is_valid_octet(z)
    _ -> False
  }
}

pub fn is_valid_octet(x: String) -> Bool {
  case int.parse(x) {
    Ok(x) -> 0 <= x && x < 256
    _ -> False
  }
}
// pub fn get_first_string_list_duplicate(
//   input: List(String),
// ) -> option.Option(String) {
//   let neighbors_list = list.sort(input, string.compare) |> list.window_by_2()
//   let duplicates = {
//     use neighbors <- list.filter(neighbors_list)
//     case neighbors {
//       #(val1, val2) if val1 == val2 -> True
//       _ -> False
//     }
//   }
//   case duplicates {
//     [] -> option.None
//     [duplicate_window, ..] -> option.Some(duplicate_window.1)
//   }
// }
