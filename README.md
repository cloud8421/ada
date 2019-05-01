# Ada

[![CircleCI](https://circleci.com/gh/cloud8421/ada.svg?style=svg&circle-token=e4d5543095470815e9108a94840d4e57c4f77070)](https://circleci.com/gh/cloud8421/ada)

Ada is personal assistant designed to run on the [Pimoroni Scroll Bot](https://shop.pimoroni.com/products/scroll-bot-pi-zero-w-project-kit) (i.e. a [Raspberry Pi Zero W ](https://www.raspberrypi.org/products/raspberry-pi-zero-w/) and a [Scroll pHAT HD](https://shop.pimoroni.com/products/scroll-phat-hd)).

It’s powered by [Nerves Project](https://nerves-project.org) and [Elixir](https://elixir-lang.org).

## Features

Ada fits a specific use case: a small device, using little energy, that helps me with things I do on a daily basis. Hardware wise, the Pimoroni kit is a perfect fit: it looks cool, has a low-fi screen that I can use to report basic useful information even in bright light conditions and I can pack it with me when I travel.

At this point Ada support these workflows:

- Email me Guardian News about a specific topic (via [theguardian / open platform](https://open-platform.theguardian.com/documentation/))
- Email me the weather forecast for the day at a specific location (via [Dark Sky](https://darksky.net/dev))
- Email me what I’ve listened to in the last day/week (via [Last.fm](https://www.last.fm/api))

Workflows can be scheduled at hourly, daily or weekly intervals, with configurable parameters like locations or email recipients.

The display is used primarily as a digital clock, but it can display if one or more scheduled tasks are running.

Ada’s timezone can be configured and its clock is synchronised automatically.

## Interaction modes

Ada can be controlled by a command line UI and an HTTP API.

TODO on how to use

## Setup

TODO on how to get everything working.

## Commit legend

- [F] Feature
- [C] Chore
- [B] Bugfix
- [D] Documentation
