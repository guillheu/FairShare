import config
import gleam/io

pub fn run(loaded_config: config.FairShareConfig) {
  io.debug(loaded_config)
  Nil
}
