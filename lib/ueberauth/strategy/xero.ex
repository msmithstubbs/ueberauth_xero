defmodule Ueberauth.Strategy.Xero do
  @moduledoc """
  Xero Strategy for Überauth.
  See https://developer.xero.com/documentation/guides/oauth2/auth-flow
  """

  use Ueberauth.Strategy,
    uid_field: :xero_userid,
    reponse_type: "code",
    default_scope: "openid"

  alias Ueberauth.Auth.Credentials

  # Must redirect to
  # https://login.xero.com/identity/connect/authorize?response_type=code&client_id=YOURCLIENTID&redirect_uri=YOURREDIRECTURI&scope=SCOPES&state=STATE
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    params =
      [scope: scopes]
      |> with_optional(:reponse_type, conn)
      |> with_param(:reponse_type, conn)
      |> with_state_param(conn)

    opts = oauth_client_options_from_conn(conn)

    redirect!(conn, Ueberauth.Strategy.Xero.OAuth.authorize_url!(params, opts))
  end

  @doc """
  Handles the callback from Xero.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    params = [code: code]

    opts = oauth_client_options_from_conn(conn)

    case Ueberauth.Strategy.Xero.OAuth.get_access_token(params, opts) do
      {:ok, token} ->
        put_private(conn, :xero_token, token)

      {:error, {error_code, error_description}} ->
        set_errors!(conn, [error(error_code, error_description)])
    end
  end

  def credentials(conn) do
    token = conn.private.xero_token
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      token_type: Map.get(token, :token_type),
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  defp with_param(opts, key, conn) do
    if value = conn.params[to_string(key)], do: Keyword.put(opts, key, value), else: opts
  end

  defp with_optional(opts, key, conn) do
    if option(conn, key), do: Keyword.put(opts, key, option(conn, key)), else: opts
  end

  defp oauth_client_options_from_conn(conn) do
    base_options = [redirect_uri: callback_url(conn)]
    request_options = conn.private[:ueberauth_request_options].options

    case {request_options[:client_id], request_options[:client_secret]} do
      {nil, _} -> base_options
      {_, nil} -> base_options
      {id, secret} -> [client_id: id, client_secret: secret] ++ base_options
    end
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  def decode_token(token) do
    Application.get_env(:ueberauth, Ueberauth.Strategy.Xero.OAuth)[:client_secret]
    |> JOSE.JWK.from_oct()
    |> JOSE.JWT.verify(token)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    {_, jwt, _} =
      conn.private.xero_token.access_token
      |> decode_token()

    jwt.fields[uid_field]
  end
end
