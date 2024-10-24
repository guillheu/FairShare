import gleeunit
import gleeunit/should
import util/ip

pub fn main() {
  gleeunit.main()
}

pub fn is_valid_ipv4_test() {
  // Valid test cases
  "0.0.0.0"
  |> ip.is_valid_ipv4
  |> should.be_true
  "127.0.0.1"
  |> ip.is_valid_ipv4
  |> should.be_true
  "255.255.255.255"
  |> ip.is_valid_ipv4
  |> should.be_true
  "163.243.76.36"
  |> ip.is_valid_ipv4
  |> should.be_true
  "0.0.0.255"
  |> ip.is_valid_ipv4
  |> should.be_true

  // Invalid test cases
  "0.256.0.0"
  |> ip.is_valid_ipv4
  |> should.be_false
  "127.0.0.-1"
  |> ip.is_valid_ipv4
  |> should.be_false
  ".0.0.0."
  |> ip.is_valid_ipv4
  |> should.be_false
  ".0.0.0.0."
  |> ip.is_valid_ipv4
  |> should.be_false
  "this.is.not.valid"
  |> ip.is_valid_ipv4
  |> should.be_false
}
