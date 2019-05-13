# Ada

[![CircleCI](https://circleci.com/gh/cloud8421/ada.svg?style=svg&circle-token=e4d5543095470815e9108a94840d4e57c4f77070)](https://circleci.com/gh/cloud8421/ada)

Ada is personal assistant designed to run on the [Pimoroni Scroll Bot](https://shop.pimoroni.com/products/scroll-bot-pi-zero-w-project-kit) (i.e. a [Raspberry Pi Zero W ](https://www.raspberrypi.org/products/raspberry-pi-zero-w/) and a [Scroll pHAT HD](https://shop.pimoroni.com/products/scroll-phat-hd)).

It’s powered by [Nerves Project](https://nerves-project.org) and [Elixir](https://elixir-lang.org).

![Ada Device](https://github.com/cloud8421/ada/blob/master/ada.jpg?raw=true)

## Features

Ada fits a specific use case: a small device, using little energy, that helps me with things I do on a daily basis. Hardware-wise, the Pimoroni kit is a perfect fit: it looks cool, has a low-fi screen that I can use to report basic useful information even in bright light conditions and I can pack it with me when I travel.

At this point Ada support these workflows:

- Email me Guardian News about a specific topic (via [theguardian / open platform](https://open-platform.theguardian.com/documentation/))
- Email me the weather forecast for the day at a specific location (via [Dark Sky](https://darksky.net/dev))
- Email me what I’ve listened to in the last day/week (via [Last.fm](https://www.last.fm/api))

Workflows can be scheduled at hourly, daily or weekly intervals, with configurable parameters like locations or email recipients.

The display is used primarily as a digital clock, but it can display if one or more scheduled tasks are running.

Ada’s timezone can be configured and its clock is synchronised automatically.

Ada’s default email adapter is [Sendgrid](https://sendgrid.com/docs/for-developers/sending-email/api-getting-started/).

Ada’s default backup strategy uses [Dropbox via a custom app](https://www.dropbox.com/developers/apps).

## Interaction modes

Ada can be controlled by a command line UI (CLI) and an HTTP API.

### CLI interaction

The CLI can be setup by [following these instructions](#Build-the-CLI). To function, it requires the ability to connect to the running device via the Erlang distribution. By default, it will assume that the target device is available at `ada.local`.

Running `./ada` will show a list of available commands. If you happen to use the [Fish shell](https://fishshell.com), you can run `./ada fish_autocomplete | source` to load basic completions for the current shell (pull requests are welcome to support other shells!).

Generally speaking, with the CLI you can:

- control the display brightness
- manage device data (users, locations, tasks)
- manage device preferences
- run or preview tasks
- backup the database with the active backup strategy
- pull the device database to a local file
- restore the device database from a local file

As an example, we can add a new user and setup a news digest about UK news, sent every day at 9am:

```
$ ./ada create_user mary mary@example.com

  Created User with ID 3

$ ./ada create_scheduled_task send_news_by_tag daily:9 --user_id 3 --tag 'uk/uk'

  Created scheduled_task with ID 9

```

You can run a task (irrespectively of its frequency) with:

```
$ ./ada run_scheduled_task 9
```

If you're interested in previewing its data, the CLI can render a
shell-friendly version of a task's result with:

```
$ ./ada preview_scheduled_task 9
```

Current tasks render as follows:

![Last.fm report shell preview](https://github.com/cloud8421/ada/blob/master/screenshots/last_fm.png?raw=true)
![Weather report shell preview](https://github.com/cloud8421/ada/blob/master/screenshots/weather.png?raw=true)
![News report shell preview](https://github.com/cloud8421/ada/blob/master/screenshots/news.png?raw=true)

### HTTP interaction

HTTP api documentation is available at `http://ada.local/swagger-ui`.

## Setup

First of all, we need working installations of Elixir and Erlang. The recommended way to achieve this is via [asdf](https://asdf-vm.com/#/). Once it's installed and working, you can run `asdf install` from the project root to install the correct versions required by Ada (see the `.tool-versions` file for details).

Next, make sure you setup the required environment variables as detailed in `.envrc.example`. We recommend using a program such as [direnv](https://direnv.net) to make this process automatic.

To support over-the-air updates, the firmware requires an ssh public key at `~/.ssh/id_rsa.pub`. This is not needed unless you try to produce a firmware file.

Once they're setup, you can run `make dev.setup` to install required tools and dependencies. Note that this will not install system-wide dependencies which are required to burn the Ada firmware to a card (see the MacOS and Linux sections at <https://hexdocs.pm/nerves/installation.html#content> for details).

At this stage, you should be able to perform the most common tasks:

### Running tests

You can run `make host.test`.

### Build the CLI

You can run `make host.cli`, which will leave you with the `ada` executable in the current directory. You can move it anywhere, but to function properly it requires a compatible version of Erlang available globally. You can checkout the [asdf documentation](https://asdf-vm.com/#/core-manage-versions?id=set-current-version) to configure that.

### Run dialyzer

You can run `make host.dialyzer` to perform a static analysis of the source code to find type inconsistencies. The first time you run it might take a while, it will be considerably faster after that.

### Build docs

You can run `make host.docs`. Key parts of the source are documented, so this should help in case you feel like contributing.

### Open a local iex session

You can run `make host.shell`.

### Produce a firmware

You can run `make rpi0.firmware` to produce a firmware file. Running `make rpi0.burn` will produce a file and try to burn it to a SD/MicroSD card if possible.

### Update the device on the fly

You can run `make rpi0.push` to perform a over-the-air device update.

### Remote shell to the running device

You can run `make rpi0.ssh`.

## Data backups

Ada is capable of backing up its own db file at 3am every night. To do that, it uses a configured backup strategy (with Dropbox being the one currently implemented). To activate it, it's enough to define a `DROPBOX_API_TOKEN` env variable (the token can be created at <https://www.dropbox.com/developers/apps>).

## Commit legend

- [F] Feature
- [C] Chore
- [B] Bugfix
- [D] Documentation
- [R] Refactor
