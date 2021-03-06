use Mix.Config

config :ada, http_port: 80

config :tzdata, :data_dir, "/root/storage/tz_data"

config :ada, Ada.Repo, database: "/root/storage/ada-v1.db"

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.
config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.
config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget, :nerves_network, :power_control],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger,
  backends: [RingLogger, Logger.Backends.Telegraf]

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

key = Path.join(System.user_home!(), ".ssh/id_rsa.pub")
unless File.exists?(key), do: Mix.raise("No SSH Keys found. Please generate an ssh key")

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(key)
  ]

# Configure network

config :nerves_network, regulatory_domain: "GB"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("WIFI_SSID"),
    psk: System.get_env("WIFI_PASS"),
    key_mgmt: :"WPA-PSK"
  ]

# Configure nerves_init_gadget.
# See https://hexdocs.pm/nerves_init_gadget/readme.html for more information.

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "ada.local",
  node_name: :ada,
  node_host: :mdns_domain,
  ssh_console_port: 22

config :power_control,
  cpu_governor: :powersave,
  disable_leds: true,
  disable_hdmi: true
