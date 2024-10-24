import config/loader
import gleam/io
import gleam/list

pub fn main() {
  let current_config = loader.load_config("config.yaml")
  io.debug(loader.read(current_config).http_server_config.host)
  io.debug(loader.read(current_config).http_server_config.port)
  io.debug(loader.read(current_config).activities_config.min_select)
  io.debug(loader.read(current_config).activities_config.max_select)
  use admin_account <- list.each(
    loader.read(current_config).admin_accounts_config.accounts,
  )
  io.debug(admin_account)
}
