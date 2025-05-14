defmodule BillingCore.Dataset.NotaCredito.InfoNotaCreditoTest do
  use ExUnit.Case

  alias BillingCore.Dataset.NotaCredito.{InfoNotaCredito, TotalImpuesto}

  alias BillingCore.Dataset.NotaCredito.Test.FactorySupport
  alias BillingCore.Dataset.Test.XmlSupport

  setup do
    info_nota_credito = FactorySupport.info_nota_credito_factory()
    info_nota_credito_with_accounting = FactorySupport.info_nota_credito_with_accounting_factory()

    {:ok,
     info_nota_credito: info_nota_credito,
     info_nota_credito_with_accounting: info_nota_credito_with_accounting}
  end

  test "to_doc without contribuyenteEspecial", %{info_nota_credito: info_nota_credito} do
    day = info_nota_credito.fecha_emision.day |> Integer.to_string() |> String.pad_leading(2, "0")

    month =
      info_nota_credito.fecha_emision.month |> Integer.to_string() |> String.pad_leading(2, "0")

    fecha_emision = [day, month, info_nota_credito.fecha_emision.year] |> Enum.join("/")

    fecha_emision_doc_sustento =
      [day, month, info_nota_credito.fecha_emision_doc_sustento.year] |> Enum.join("/")

    total_con_impuestos =
      info_nota_credito.total_con_impuestos
      |> Enum.map(fn impuesto -> TotalImpuesto.to_doc(impuesto) end)

    doc_expected = {
      :infoNotaCredito,
      nil,
      [
        {:fechaEmision, nil, fecha_emision},
        {:dirEstablecimiento, nil, info_nota_credito.dir_establecimiento},
        {:contribuyenteEspecial, nil, nil},
        {:tipoIdentificacionComprador, nil,
         info_nota_credito.tipo_identificacion_comprador
         |> Integer.to_string()
         |> String.pad_leading(2, "0")},
        {:razonSocialComprador, nil, info_nota_credito.razon_social_comprador},
        {:identificacionComprador, nil, info_nota_credito.identificacion_comprador},
        {:obligadoContabilidad, nil, info_nota_credito.obligado_contabilidad},
        {:rise, nil, info_nota_credito.rise},
        {:codDocumentoModificado, nil, info_nota_credito.cod_documento_modificado},
        {:numDocumentoModificado, nil, info_nota_credito.cod_documento_modificado},
        {:fechaEmisionDocSustento, nil, fecha_emision_doc_sustento},
        {:totalSinImpuestos, nil,
         :erlang.float_to_binary(info_nota_credito.total_sin_impuestos, decimals: 2)},
        {:valorModificacion, nil,
         :erlang.float_to_binary(info_nota_credito.valor_modificacion, decimals: 2)},
        {:moneda, nil, info_nota_credito.moneda},
        {:motivo, nil, info_nota_credito.motivo},
        {:totalConImpuestos, nil, total_con_impuestos}
      ]
    }

    assert InfoNotaCredito.to_doc(info_nota_credito) == doc_expected
  end

  test "to_doc with contribuyenteEspecial", %{
    info_nota_credito_with_accounting: info_nota_credito
  } do
    day = info_nota_credito.fecha_emision.day |> Integer.to_string() |> String.pad_leading(2, "0")

    month =
      info_nota_credito.fecha_emision.month |> Integer.to_string() |> String.pad_leading(2, "0")

    fecha_emision = [day, month, info_nota_credito.fecha_emision.year] |> Enum.join("/")

    fecha_emision_doc_sustento =
      [day, month, info_nota_credito.fecha_emision_doc_sustento.year] |> Enum.join("/")

    total_con_impuestos =
      info_nota_credito.total_con_impuestos
      |> Enum.map(fn impuesto -> TotalImpuesto.to_doc(impuesto) end)

    doc_expected = {
      :infoNotaCredito,
      nil,
      [
        {:fechaEmision, nil, fecha_emision},
        {:dirEstablecimiento, nil, info_nota_credito.dir_establecimiento},
        {:contribuyenteEspecial, nil, info_nota_credito.contribuyente_especial},
        {:tipoIdentificacionComprador, nil,
         info_nota_credito.tipo_identificacion_comprador
         |> Integer.to_string()
         |> String.pad_leading(2, "0")},
        {:razonSocialComprador, nil, info_nota_credito.razon_social_comprador},
        {:identificacionComprador, nil, info_nota_credito.identificacion_comprador},
        {:obligadoContabilidad, nil, info_nota_credito.obligado_contabilidad},
        {:rise, nil, info_nota_credito.rise},
        {:codDocumentoModificado, nil, info_nota_credito.cod_documento_modificado},
        {:numDocumentoModificado, nil, info_nota_credito.cod_documento_modificado},
        {:fechaEmisionDocSustento, nil, fecha_emision_doc_sustento},
        {:totalSinImpuestos, nil,
         :erlang.float_to_binary(info_nota_credito.total_sin_impuestos, decimals: 2)},
        {:valorModificacion, nil,
         :erlang.float_to_binary(info_nota_credito.valor_modificacion, decimals: 2)},
        {:moneda, nil, info_nota_credito.moneda},
        {:motivo, nil, info_nota_credito.motivo},
        {:totalConImpuestos, nil, total_con_impuestos}
      ]
    }

    assert InfoNotaCredito.to_doc(info_nota_credito) == doc_expected
  end

  test "to_xml without contribuyenteEspecial", %{info_nota_credito: info_nota_credito} do
    xml_expected =
      File.read!("test/fixtures/nota_credito/info_nota_credito.xml")
      |> XmlSupport.format()

    xml =
      InfoNotaCredito.to_xml(info_nota_credito)
      |> XmlSupport.format()

    assert xml == xml_expected
  end

  test "to_xml with contribuyenteEspecial", %{
    info_nota_credito_with_accounting: info_nota_credito
  } do
    xml_expected =
      File.read!("test/fixtures/nota_credito/info_nota_credito_with_accounting.xml")
      |> XmlSupport.format()

    xml =
      InfoNotaCredito.to_xml(info_nota_credito)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
