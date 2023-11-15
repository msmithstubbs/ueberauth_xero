# Ueberauth Xero

A Xero OAuth2 strategy for Überauth.

## Installation

1. Create an application at [Xero Developer Platform](https://developer.xero.com)

2. Add :ueberauth_xero to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:ueberauth_xero, "~> 0.1.0"}
  ]
end
```

3.  Add Google to your Überauth configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]
    ```

4.  Update your provider configuration:

```elixir
config :ueberauth, Ueberauth.Strategy.Xero.OAuth,
  client_id: {System, :get_env, ["XERO_CLIENT_ID"]},
  client_secret: {System, :get_env, ["XERO_CLIENT_SECRET"]}
```

5.  Include the Überauth plug in your controller:

```elixir
defmodule MyApp.AuthController do
  use MyApp.Web, :controller
  plug Ueberauth
  ...
end
```

6.  Create the request and callback routes if you haven't already:

```elixir
scope "/auth", MyApp do
  pipe_through :browser

  get "/:provider", AuthController, :request
  get "/:provider/callback", AuthController, :callback
end
```

7. Your controller needs to implement callbacks to deal with Ueberauth.Auth and Ueberauth.Failure responses.



## Configuring scopes

```elixir
config :ueberauth, Ueberauth,
  providers: [
    xero:
      {Ueberauth.Strategy.Xero,
       [
         default_scope:
           "openid email profile offline_access accounting.settings.read accounting.transactions accounting.contacts"
       ]}
  ]
```