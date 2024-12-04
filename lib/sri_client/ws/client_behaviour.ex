defmodule BillingCore.Ws.ClientBehaviour do
  @moduledoc false
  @callback post(String.t(), String.t()) :: tuple()
  @callback put(String.t(), String.t()) :: tuple()
end
