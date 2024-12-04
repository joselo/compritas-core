defmodule Billing.Service.FacturaService do
  @moduledoc false

  alias Billing.Dataset.Factura

  def build(factura_params) do
    case validate_invoice(factura_params) do
      {:ok, factura} ->
        {:ok, [xml: Factura.to_xml(factura), clave_acceso: factura.info_tributaria.clave_acceso]}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_invoice(params) do
    case Factura.changeset(%Factura{}, params) do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
