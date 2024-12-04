defmodule BillingCore.Xbes.P12.Key do
  @moduledoc false

  def sign_with_pem(value, pem_file, index) do
    pem = pem_decode(pem_file, index)

    :public_key.sign(value, :sha, pem)
    |> Base.encode64()
  end

  # TODO: Write tests
  def pem_decode(pem_file, index) do
    pem_file
    |> :public_key.pem_decode()
    |> Enum.at(index)
    |> :public_key.pem_entry_decode()
  end
end
