import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
app_port = System.fetch_env!("APP_PORT")
app_hostname = System.fetch_env!("APP_HOSTNAME")

config :wacko, WackoWeb.Endpoint,
  http: [:inet6, port: String.to_integer(app_port)],
  secret_key_base: "+J9qHyvPqnxXHldkW5b3C+GvNMkHKsCCIqap+VYL0GJ+uuVPBJHS56/3qQBwpmB7"

config :wacko, app_port: app_port
