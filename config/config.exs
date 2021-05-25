import Config

config :peerage,
  via: Peerage.Via.Udp,
  serves: true,
  port: 45900
