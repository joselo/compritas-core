defmodule BillingCore.InvoiceXmlParser do
  @moduledoc """
  XML Invoice Parser
  """

  @headers [
    "Código",
    "Código Aux.",
    "Descripción",
    "Detalle Adic.",
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

    if authorization do
      document = parse(XmlToMap.naive_map(authorization["comprobante"]))

      %{
        document: document,
        authorization_date: authorization["fechaAutorizacion"]
      }
    end
  end

  def parse_xml_file(path) do
    if File.exists?(path) do
      File.read!(path)
      |> XmlToMap.naive_map()
      |> parse()
    end
  end

  def get_client_email(xml_struct) do
    get_client_fields(xml_struct)
    |> Enum.find_value(fn
      %{client_email: email} -> email
      _ -> nil
    end)
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
    details = xml_struct["factura"]["#content"]["detalles"]["detalle"]

    get_details_fn = fn item ->
      detalles_adicionales = item["detallesAdicionales"]
      det_adicional_node = if is_map(detalles_adicionales), do: detalles_adicionales["detAdicional"], else: nil

      det_adicionales =
        cond do
          is_list(det_adicional_node) -> det_adicional_node
          is_map(det_adicional_node) -> [det_adicional_node]
          true -> []
        end

      extra_text =
        det_adicionales
        |> Enum.filter(&is_map/1)
        |> Enum.reject(fn det -> det["-nombre"] == "informacionAdicional" end)
        |> Enum.map(fn det -> det["-valor"] end)
        |> Enum.reject(&is_nil/1)
        |> Enum.join("\n")

      [
        item["codigoPrincipal"],
        item["codigoAuxiliar"],
        item["descripcion"],
        extra_text,
        item["precioUnitario"],
        item["cantidad"],
        item["descuento"],
        item["precioTotalSinImpuesto"]
      ]
    end

    items =
      if is_list(details) do
        details
        |> Enum.filter(&is_map/1)
        |> Enum.map(fn item ->
          get_details_fn.(item)
        end)
      else
        if is_map(details) do
          [get_details_fn.(details)]
        else
          []
        end
      end

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
    info_adicional = xml_struct["factura"]["#content"]["infoAdicional"]
    campos = if is_map(info_adicional), do: info_adicional["campoAdicional"], else: nil

    campos_list = 
      cond do
        is_list(campos) -> campos
        is_map(campos) -> [campos]
        true -> []
      end

    base_fields =
      campos_list
      |> Enum.flat_map(&determinate_client_field/1)
      |> Map.new()

    other_info = 
      campos_list
      |> Enum.filter(fn %{"-nombre" => n} -> 
           n not in ["Dirección", "Direccion", "DIRECCION", "Correo electrónico", "Email", "E-MAIL", "Correo electronico"]
         end)
      |> Enum.map(fn %{"-nombre" => n, "#content" => v} -> "#{n}: #{v}" end)

    Map.put(base_fields, :other_info, other_info)
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
    total_con_impuestos = xml_struct["factura"]["#content"]["infoFactura"]["totalConImpuestos"]
    raw = if is_map(total_con_impuestos), do: total_con_impuestos["totalImpuesto"], else: nil

    taxes =
      cond do
        is_list(raw) -> raw
        is_map(raw) -> [raw]
        true -> []
      end

    Enum.map(taxes, &determinate_tax(&1))
  end

  def get_payments(xml_struct) do
    info_factura = xml_struct["factura"]["#content"]["infoFactura"]
    pagos = if is_map(info_factura), do: info_factura["pagos"], else: nil
    pago = if is_map(pagos), do: pagos["pago"], else: nil

    %{
      payments: determinate_payment(pago)
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
      "3" -> "IVA 14%"
      "4" -> "IVA 15%"
      "10" -> "IVA 13%"
      "6" -> "No objeto de impuesto"
      "7" -> "Exento de IVA"
      _ -> code
    end
  end

  defp determinate_client_field(%{"#content" => address, "-nombre" => name})
       when name in ["Dirección", "Direccion", "DIRECCION"] do
    %{
      client_address: String.slice(address, 0..300)
    }
  end

  defp determinate_client_field(%{"#content" => email, "-nombre" => name})
       when name in ["Correo electrónico", "Email", "E-MAIL", "Correo electronico"] do
    %{
      client_email: email
    }
  end

  defp determinate_client_field(_), do: []

  defp determinate_payment(nil), do: %{method: "DESCONOCIDO", total: 0, due_date: ""}

  defp determinate_payment(%{
         "formaPago" => method,
         "plazo" => term,
         "total" => total,
         "unidadTiempo" => time
       }) do
    payment_method =
      case method do
        "16" -> "TARJETA DE DÉBITO"
        "18" -> "TARJETA PREPAGO"
        "19" -> "TARJETA DE CRÉDITO"
        "20" -> "OTROS CON UTILIZACION DEL SISTEMA FINANCIERO"
        "01" -> "SIN UTILIZACION DEL SISTEMA FINANCIERO"
        "15" -> "COMPENSACIÓN DE DEUDAS"
        "17" -> "DINERO ELECTRÓNICO"
        "21" -> "ENDOSO DE TÍTULOS"
        _ -> method
      end

    %{
      method: payment_method,
      total: total,
      due_date: "#{term} #{time}"
    }
  end
end
