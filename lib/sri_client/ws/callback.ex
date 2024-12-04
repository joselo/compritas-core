defmodule BillingCore.Ws.Callback do
  require Logger

  @moduledoc false

  def send(callback_url, params) do
    client().put(callback_url, params)
  end

  defp client do
    Application.get_env(:billing_core, :client)
  end
end
