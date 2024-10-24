import argv
import config
import glint
import http

fn run() -> glint.Command(Nil) {
  use <- glint.command_help("Run the FairShare server")
  use config_file_path <- glint.flag(
    glint.string_flag("config")
    |> glint.flag_default("config.yaml")
    |> glint.flag_help("path to the yaml configuration file"),
  )
  use _, _, flags <- glint.command()
  let assert Ok(config_path) = config_file_path(flags)
  let loaded_config = config.load(config_path)
  http.run(loaded_config)
}

pub fn init() {
  glint.new()
  |> glint.with_name("hello")
  |> glint.pretty_help(glint.default_pretty_help())
  |> glint.add(at: ["run"], do: run())
  |> glint.run(argv.load().arguments)
}
