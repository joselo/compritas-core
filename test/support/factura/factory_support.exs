defmodule Billing.Dataset.Factura.Test.FactorySupport do
  alias Billing.Dataset.Factura

  alias Billing.Dataset.Factura.{
    CampoAdicional,
    DetAdicional,
    Detalle,
    Impuesto,
    InfoFactura,
    InfoTributaria,
    Pago,
    TotalImpuesto
  }

  alias Billing.Dataset.ClaveAcceso

  def info_tributaria_factory do
    %InfoTributaria{
      ambiente: 1,
      tipo_emision: 1,
      razon_social: "CARRION JUMBO JOSE AUGUSTO",
      nombre_comercial: "INITMAIN",
      ruc: "1103671804001",
      clave_acceso: "0307202001110367180400110010010000000330000000119",
      cod_doc: 1,
      estab: 1,
      pto_emi: 100,
      secuencial: 33,
      dir_matriz: "Ciudadela: DAMMER II Calle: N49C Número: EC-102 Intersección: EL MORLAN"
    }
  end

  def total_impuesto_factory do
    %TotalImpuesto{
      codigo: 2,
      codigo_porcentaje: 0,
      base_imponible: 3000.00,
      valor: 0.00
    }
  end

  def pago_factory do
    %Pago{
      forma_pago: 20,
      total: 3000.00,
      plazo: 15,
      unidad_tiempo: "Dias"
    }
  end

  def info_factura_factory do
    {:ok, fecha_emision} = Date.new(2020, 7, 3)

    %InfoFactura{
      fecha_emision: fecha_emision,
      dir_establecimiento:
        "Ciudadela: DAMMER II Calle: N49C Número: EC-102 Intersección: EL MORLAN",
      obligado_contabilidad: "NO",
      tipo_identificacion_comprador: 8,
      razon_social_comprador: "Novaux Inc.",
      identificacion_comprador: 465_219_513,
      total_sin_impuestos: 3000.00,
      total_descuento: 0.00,
      total_con_impuestos: [total_impuesto_factory()],
      propina: 0,
      importe_total: 3000.00,
      moneda: "DOLAR",
      pagos: [pago_factory()]
    }
  end

  def info_factura_with_accounting_factory do
    struct!(
      info_factura_factory(),
      %{
        obligado_contabilidad: "SI",
        contribuyente_especial: "666"
      }
    )
  end

  def det_adicional_factory do
    %DetAdicional{
      nombre: "informacionAdicional",
      valor: "desarrollo de software"
    }
  end

  def impuesto_factory do
    %Impuesto{
      codigo: 2,
      codigo_porcentaje: 0,
      tarifa: 0.00,
      base_imponible: 3000.00,
      valor: 0.00
    }
  end

  def detalle_factory do
    %Detalle{
      codigo_principal: 831_410_399,
      codigo_auxiliar: 2,
      descripcion: "SERVICIOS PROFESIONALES NOVAUX INC.",
      cantidad: 1.0,
      precio_unitario: 3000.00,
      descuento: 0.00,
      precio_total_sin_impuesto: 3000.00,
      detalles_adicionales: [det_adicional_factory()],
      impuestos: [impuesto_factory()]
    }
  end

  def campo_adicional_factory do
    %CampoAdicional{
      nombre: "Direccion",
      valor: "East 109 St - 6J Manhattan NY"
    }
  end

  def campo_adicional_factory(nombre, valor) do
    %CampoAdicional{
      nombre: nombre,
      valor: valor
    }
  end

  def factura_factory do
    campo_adicional1 = campo_adicional_factory("Direccion", "East 109 St - 6J Manhattan NY")
    campo_adicional2 = campo_adicional_factory("Email", "javier@saborpos.com")

    %Factura{
      info_tributaria: info_tributaria_factory(),
      info_factura: info_factura_factory(),
      detalles: [detalle_factory()],
      info_adicional: [campo_adicional1, campo_adicional2]
    }
  end

  def clave_factory do
    %ClaveAcceso{
      fecha_emision: Date.utc_today(),
      tipo_comprobante: 1,
      ruc: "1103671804001",
      ambiente: 1,
      estab: 1,
      pto_emi: 1,
      secuencial: 33,
      codigo: 1,
      tipo_emision: 1
    }
  end
end
