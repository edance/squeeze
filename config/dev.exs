import Config

# Configure your database
config :squeeze, Squeeze.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "squeeze_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :squeeze, SqueezeWeb.Endpoint,
  # Allow access from other machines to use docker
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dA6nIjOH8yCstzjGAqA7DgTk9rEP9XVNZUewZmL06T2pSn+kbVIkpwBh5I5oep+1",
  watchers: [
    node: ["build.js", "--watch", cd: Path.expand("../assets", __DIR__)],
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :squeeze, SqueezeWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/[^#]*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/[^#]*(po)$",
      ~r"lib/squeeze_web/(live|views)/[^#]*(ex)$",
      ~r"lib/squeeze_web/templates/[^#]*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :squeeze, Squeeze.Mailer, adapter: Bamboo.LocalAdapter

config :squeeze, gtm_id: System.get_env("GTM_ID")

config :squeeze, mapbox_access_token: System.get_env("MAPBOX_ACCESS_TOKEN")

config :new_relic_agent,
  app_name: "OpenPace Development",
  license_key: System.get_env("NEW_RELIC_KEY"),
  logs_in_context: :direct
