defmodule BillingCore.Dataset.Factura.PagoTest do
  use ExUnit.Case

  alias BillingCore.Dataset.Factura.Pago

  alias BillingCore.Dataset.Factura.Test.FactorySupport
  alias BillingCore.Dataset.Test.XmlSupport

  setup do
    pago = FactorySupport.pago_factory()

    {:ok, pago: pago}
  end

  test "to_doc", %{pago: pago} do
    doc_expected = {
      :pago,
      nil,
      [
        {:formaPago, nil, pago.forma_pago},
        {:total, nil, :erlang.float_to_binary(pago.total, decimals: 2)},
        {:plazo, nil, pago.plazo},
        {:unidadTiempo, nil, pago.unidad_tiempo}
      ]
    }

    assert Pago.to_doc(:pago, pago) == doc_expected
  end

  test "to_xml", %{pago: pago} do
    xml_expected =
      File.read!("test/fixtures/pago.xml")
      |> XmlSupport.format()

    xml =
      Pago.to_xml(:pago, pago)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
