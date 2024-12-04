defmodule BillingCore.Signing do
  @moduledoc false

  alias BillingCore.P12Reader
  alias BillingCore.Xbes

  def sign(xml, p12_path, p12_password) do
    signing_time =
      Application.get_env(:billing_core, :timezone)
      |> Timex.now()
      |> Timex.format!("%FT%T%:z", :strftime)

    case P12Reader.read(p12_path, p12_password) do
      {:ok, cert, rsa} ->
        Xbes.sign(xml, cert, rsa, signing_time)

      {:error, error} ->
        {:error, error}
    end
  end
end
