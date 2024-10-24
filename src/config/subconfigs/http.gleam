import config/generics
import glaml
import gleam/bool
import gleam/int
import gleam/result
import util/ip

pub opaque type HTTPServerConfig {
  HSConfig(host: String, port: Int)
}

pub type HTTPServerConfigUnvalidated {
  HSConfigUnvalidated(host: String, port: Int)
}

pub fn from_yaml(
  yaml_config: glaml.Document,
) -> Result(HTTPServerConfig, generics.ConfigError) {
  let yaml_config = glaml.doc_node(yaml_config)
  use http_host <- result.try(generics.get_string_yaml_path(
    yaml_config,
    "http.host",
  ))
  use http_port <- result.try(generics.get_int_yaml_path(
    yaml_config,
    "http.port",
  ))
  validate(HSConfig(http_host, http_port))
}

pub fn validate(
  http_server_config: HTTPServerConfig,
) -> Result(HTTPServerConfig, generics.ConfigError) {
  use <- bool.guard(
    bool.negate(ip.is_valid_ipv4(http_server_config.host)),
    Error(generics.InvalidFieldFormat(
      "address \"" <> http_server_config.host <> "\" is not a valid IP address",
      "http.host",
    )),
  )
  use <- bool.guard(
    http_server_config.port > 65_536 || http_server_config.port <= 0,
    Error(generics.InvalidFieldFormat(
      "value should be between 1 and 65536. found: "
        <> int.to_string(http_server_config.port),
      "http.port",
    )),
  )
  Ok(http_server_config)
}

pub fn read(http_config: HTTPServerConfig) -> HTTPServerConfigUnvalidated {
  HSConfigUnvalidated(http_config.host, http_config.port)
}
