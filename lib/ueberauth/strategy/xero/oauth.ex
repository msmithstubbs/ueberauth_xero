defmodule Ueberauth.Strategy.Xero.OAuth do
  @moduledoc false
  use OAuth2.Strategy

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])

    [
      strategy: __MODULE__,
      site: "",
      authorize_url: "https://login.xero.com/identity/connect/authorize",
      token_url: "https://identity.xero.com/connect/token"
    ]
    |> Keyword.merge(opts)
    |> Keyword.merge(config)
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_access_token(params \\ [], opts \\ []) do
    case opts |> client |> OAuth2.Client.get_token(params) do
      {:error, %OAuth2.Response{body: %{"error" => error, "error_description" => description}}} ->
        {:error, {error, description}}

      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, {"error", to_string(reason)}}

      {:ok, %OAuth2.Client{token: %{access_token: nil} = token}} ->
        %{"error" => error, "error_description" => description} = token.other_params
        {:error, {error, description}}

      {:ok, %OAuth2.Client{token: token}} ->
        {:ok, token}
    end
  end

  # OAuth2.Strategy callbacks
  @impl OAuth2.Strategy
  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  @impl OAuth2.Strategy
  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
