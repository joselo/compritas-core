defmodule BillingCore.InvoiceXmlParser do
  @moduledoc """
  XML Invoice Parser
  """

  @headers [
    "Código",
    "Código Aux.",
    "Descripción",
    "Precio Unitario",
    "Cantidad",
    "Descuento",
    "Total"
  ]

  def get_authorization(xml_map) do
    xml_map["soap:Envelope"]["soap:Body"]["ns2:autorizacionComprobanteResponse"][
      "RespuestaAutorizacionComprobante"
    ]["autorizaciones"]["autorizacion"]
  end

  def parse_xml(nil) do
    nil
  end

  def parse_xml(xml) do
    xml_map = XmlToMap.naive_map(xml)
    authorization = get_authorization(xml_map)

    document = parse(XmlToMap.naive_map(authorization["comprobante"]))

    %{
      document: document,
      authorization_date: authorization["fechaAutorizacion"]
    }
  end

  def parse(nil) do
    nil
  end

  def parse(xml_invoice) do
    %{
      items: get_items(xml_invoice),
      business_name: get_business_name(xml_invoice),
      tradename: get_tradename(xml_invoice),
      business_main_address: get_business_main_address(xml_invoice),
      business_branch_address: get_business_branch_address(xml_invoice),
      accounting: get_accounting(xml_invoice),
      accounting_number: get_accounting_number(xml_invoice),
      client_name: get_client_name(xml_invoice),
      client_identification: get_client_identification(xml_invoice),
      business_identification: get_business_identification(xml_invoice),
      access_key: get_access_key(xml_invoice),
      environment: get_environment(xml_invoice),
      emssion_type: get_emission_type(xml_invoice),
      invoice_number: get_invoice_number(xml_invoice),
      currency: get_currency(xml_invoice),
      taxes: get_taxes(xml_invoice)
    }
    |> Map.merge(get_totals(xml_invoice))
    |> Map.merge(get_client_fields(xml_invoice))
    |> Map.merge(get_payments(xml_invoice))
  end

  def get_items(xml_struct) do
    items =
      Enum.map(xml_struct["factura"]["#content"]["detalles"]["detalle"], fn item ->
        [
          item["codigoPrincipal"],
          item["codigoAuxiliar"],
          "#{item["descripcion"]}\n#{item["detallesAdicionales"]["detAdicional"]["-valor"]}",
          item["precioUnitario"],
          item["cantidad"],
          item["descuento"],
          item["precioTotalSinImpuesto"]
        ]
      end)

    [@headers | items]
  end

  def get_business_name(xml_struct) do
    xml_struct["factura"]["#content"]["infoTributaria"]["razonSocial"]
  end

  def get_tradename(xml_struct) do
    xml_struct["factura"]["#content"]["infoTributaria"]["nombreComercial"]
  end

  def get_business_main_address(xml_struct) do
    String.slice(xml_struct["factura"]["#content"]["infoTributaria"]["dirMatriz"], 0..110)
  end

  def get_business_branch_address(xml_struct) do
    String.slice(xml_struct["factura"]["#content"]["infoFactura"]["dirEstablecimiento"], 0..110)
  end

  def get_accounting(xml_struct) do
    xml_struct["factura"]["#content"]["infoFactura"]["obligadoContabilidad"]
  end

  def get_accounting_number(xml_struct) do
    xml_struct["factura"]["#content"]["infoFactura"]["contribuyenteEspecial"]
  end

  def get_business_identification(xml_struct) do
    xml_struct["factura"]["#content"]["infoTributaria"]["ruc"]
  end

  def get_access_key(xml_struct) do
    xml_struct["factura"]["#content"]["infoTributaria"]["claveAcceso"]
  end

  def get_environment(xml_struct) do
    case xml_struct["factura"]["#content"]["infoTributaria"]["ambiente"] do
      "1" -> "PRUEBAS"
      "2" -> "PRODUCCION"
      value -> value
    end
  end

  def get_emission_type(xml_struct) do
    case xml_struct["factura"]["#content"]["infoTributaria"]["tipoEmision"] do
      "1" -> "NORMAL"
      value -> value
    end
  end

  def get_client_name(xml_struct) do
    xml_struct["factura"]["#content"]["infoFactura"]["razonSocialComprador"]
  end

  def get_client_identification(xml_struct) do
    xml_struct["factura"]["#content"]["infoFactura"]["identificacionComprador"]
  end

  def get_client_fields(xml_struct) do
    xml_struct["factura"]["#content"]["infoAdicional"]["campoAdicional"]
    |> Enum.flat_map(&determinate_client_field(&1))
    |> Map.new()
  end

  def get_invoice_number(xml_struct) do
    Enum.join(
      [
        xml_struct["factura"]["#content"]["infoTributaria"]["estab"],
        xml_struct["factura"]["#content"]["infoTributaria"]["ptoEmi"],
        xml_struct["factura"]["#content"]["infoTributaria"]["secuencial"]
      ],
      "-"
    )
  end

  def get_totals(xml_struct) do
    %{
      sub_total_without_taxes:
        xml_struct["factura"]["#content"]["infoFactura"]["totalSinImpuestos"],
      total_discount: xml_struct["factura"]["#content"]["infoFactura"]["totalDescuento"],
      total: xml_struct["factura"]["#content"]["infoFactura"]["importeTotal"]
    }
  end

  def get_taxes(xml_struct) do
    xml_struct["factura"]["#content"]["infoFactura"]["totalConImpuestos"]["totalImpuesto"]
    |> Enum.map(&determinate_tax(&1))
  end

  def get_payments(xml_struct) do
    %{
      payments: determinate_payment(xml_struct["factura"]["#content"]["infoFactura"]["pagos"]["pago"])
    }
  end

  def get_currency(xml_struct) do
    xml_struct["factura"]["#content"]["infoFactura"]["moneda"]
  end

  defp determinate_tax(%{"codigoPorcentaje" => code, "baseImponible" => total, "valor" => value}) do
    %{
      tax_value: total,
      tax_total: value,
      tax_code: code,
      tax_label: get_tax_label(code)
    }
  end

  defp get_tax_label(code) do
    case code do
      "0" -> "IVA 0%"
      "2" -> "IVA 12%"
      "4" -> "IVA 15%"
      "10" -> "IVA 13%"
      _ -> code
    end
  end

  defp determinate_client_field(%{"#content" => address, "-nombre" => "Dirección"}) do
    %{
      client_address: String.slice(address, 0..300)
    }
  end

  defp determinate_client_field(%{"#content" => email, "-nombre" => "Correo electrónico"}) do
    %{
      client_email: email
    }
  end

  defp determinate_payment(%{
         "formaPago" => method,
         "plazo" => term,
         "total" => total,
         "unidadTiempo" => time
       }) do
    payment_method = case method do
      "16" -> "TARJETA DE DÉBITO"
      "18" -> "TARJETA PREPAGO"
      "19" -> "TARJETA DE CRÉDITO"
      "20" -> "OTROS CON UTILIZACION DEL SISTEMA FINANCIERO"
      _ -> method
    end

    %{
      method: payment_method,
      total: total,
      due_date: "#{term} #{time}"
    }
  end
end
