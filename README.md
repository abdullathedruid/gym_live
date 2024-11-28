# GymLive

A progressive web app workout tracking app, hosted at [fly.io](https://frosty-rain-4402.fly.dev/)

<img src="https://github.com/abdullathedruid/gym_live/assets/8117454/45ea7883-4ce4-4507-b51a-4ceda1b8f4ff" width="207" height="448">

<img src="https://github.com/abdullathedruid/gym_live/assets/8117454/d531952b-4448-434f-ae2f-e67f4c23b887" width="207" height="448">

## Instructions 

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## To run database locally

```sh
docker run --name gym-live-db -e POSTGRES_PASSWORD=password -e POSTGRES_USER=postgres -d -p 5432:5432 -d --rm -v ${PWD}/postgres-docker:/var/lib/postgresql/data postgres:15
```

## Known issues

If a user logs in via multiple devices, the state will not be synced until the page is refreshed. It is possible to fix this by implementing PubSub
