defmodule BillingCore.Dataset.ClaveAcceso do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:fecha_emision, :date)
    field(:tipo_comprobante, :integer)
    field(:ruc, :string)
    field(:ambiente, :integer)
    field(:pto_emi, :integer)
    field(:estab, :integer)
    field(:secuencial, :integer)
    field(:codigo, :integer)
    field(:tipo_emision, :integer)
  end

  def changeset(clave, params \\ %{}) do
    clave
    |> cast(params, [
      :fecha_emision,
      :tipo_comprobante,
      :ruc,
      :ambiente,
      :pto_emi,
      :estab,
      :secuencial,
      :codigo,
      :tipo_emision
    ])
    |> validate_required([
      :fecha_emision,
      :tipo_comprobante,
      :ruc,
      :ambiente,
      :pto_emi,
      :estab,
      :secuencial,
      :codigo,
      :tipo_emision
    ])
  end
end
