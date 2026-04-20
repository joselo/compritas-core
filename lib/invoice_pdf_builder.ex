defmodule BillingCore.InvoicePdfBuilder do
  @moduledoc false

  @table_opts [
    padding: 2,
    border: 0.1,
    repeat_header: 1,
    cols: [
      [width: 50, font_size: 7],
      [width: 50, font_size: 7],
      [width: 140, font_size: 7],
      [width: 60, font_size: 7],
      [width: 50, align: :right, font_size: 7],
      [width: 50, align: :right, font_size: 7],
      [width: 50, align: :right, font_size: 7],
      [width: 50, align: :right, font_size: 7]
    ],
    rows: %{
      # Headers
      0 => [
        bold: true,
        align: :center,
        kerning: true,
        background: :gainsboro
      ]
    }
  ]

  def build(xml_map, logo_path \\ nil, bar_code_path \\ nil) do
    document = xml_map.document

    subtotal = [
      ["Subtotal", document.sub_total_without_taxes]
    ]

    taxes =
      Enum.map(document.taxes, fn tax ->
        [
          tax.tax_label,
          tax.tax_total
        ]
      end)

    totals = [
      ["Descuento", document.total_discount],
      ["Total", document.total]
    ]

    totals_table = subtotal ++ taxes ++ totals

    document =
      document
      |> Map.put(:auth_datetime, xml_map.authorization_date)
      |> Map.put(:totals_table, totals_table)

    {:ok, pdf} = Pdf.new(size: :a4, compress: false)

    pdf =
      pdf
      |> Pdf.set_info(
        title: "Test Document",
        producer: "Test producer",
        creator: "Test Creator",
        created: Date.utc_today(),
        modified: Date.utc_today(),
        author: "Test Author",
        subject: "Test Subject"
      )
      |> Pdf.set_font("Helvetica", 10)

    pdf = render(pdf, document, logo_path, bar_code_path)

    Pdf.export(pdf)
  end

  defp render(pdf, invoice, logo_path, bar_code_path) do
    {pdf, grid} =
      pdf
      |> add_header(invoice, logo_path, bar_code_path)
      |> render_table(invoice)

    pdf = add_footer(pdf, invoice)
    add_table({pdf, grid}, invoice, logo_path, bar_code_path)
  end

  defp add_header(pdf, invoice, logo_path, bar_code_path) do
    %{width: _width, height: _height} = Pdf.size(pdf)

    pdf
    |> Pdf.set_font("Helvetica", 10)
    # Business Info
    |> Pdf.set_font_size(7)
    # Guides
    # |> Pdf.rectangle({310, 700}, {240, 100})
    # |> Pdf.rectangle({310, 700}, {120, 100})
    # |> Pdf.rectangle({430, 700}, {60, 100})
    # |> Pdf.rectangle({50, 580}, {240, 100})
    # |> Pdf.rectangle({310, 580}, {240, 100})
    # |> Pdf.rectangle({370, 625}, {180, 20})
    # |> Pdf.rectangle({370, 605}, {180, 20})
    # |> Pdf.stroke()
    # End Guides
    # Logo
    |> add_logo(logo_path)
    # Invoice
    |> Pdf.text_at({310, 790}, "Factura Nro.", bold: true)
    |> Pdf.text_at({310, 780}, invoice.invoice_number)
    |> Pdf.text_at({430, 790}, "R.U.C.", bold: true)
    |> Pdf.text_at({430, 780}, invoice.business_identification)
    |> Pdf.text_at({310, 760}, "Fecha de Autorización", bold: true)
    |> Pdf.text_at({310, 750}, "#{invoice.auth_datetime}")
    |> Pdf.text_at({430, 760}, "Ambiente", bold: true)
    |> Pdf.text_at({430, 750}, invoice.environment)
    |> Pdf.text_at({490, 760}, "Emisión", bold: true)
    |> Pdf.text_at({490, 750}, invoice.emssion_type)
    |> Pdf.text_at({310, 730}, "Número de Autorización", bold: true)
    |> Pdf.text_at({310, 720}, invoice.access_key)
    |> add_bar_code(bar_code_path)
    # Client
    |> Pdf.text_at({50, 670}, "Cliente", bold: true)
    |> Pdf.text_at({50, 650}, invoice.client_name)
    |> Pdf.text_at({50, 640}, invoice.client_identification)
    |> Pdf.text_at({50, 630}, Map.get(invoice, :client_email, ""))
    |> Pdf.text_wrap!({50, 620}, {240, 50}, Map.get(invoice, :client_address, ""))
    # Business
    |> Pdf.text_at({310, 670}, invoice.business_name, bold: true)
    |> Pdf.text_at({310, 660}, invoice.tradename, bold: true)
    |> Pdf.text_at({310, 640}, "Matriz:", bold: true)
    |> Pdf.text_wrap!({370, 645}, {180, 20}, invoice.business_main_address)
    |> Pdf.text_at({310, 620}, "Sucursal:", bold: true)
    |> Pdf.text_wrap!({370, 625}, {180, 20}, invoice.business_branch_address)
    |> Pdf.text_at({310, 590}, "Obligado a llevar contabilidad: #{invoice.accounting}")
    |> add_accounting_number(invoice)
  end

  defp add_footer(pdf, invoice) do
    %{width: width, height: _height} = Pdf.size(pdf)
    cursor = Pdf.cursor(pdf) - 20
    page_number = "#{Pdf.page_number(pdf)}"

    pdf =
      pdf
      |> Pdf.set_font_size(7)

    {pdf, payment_cursor} = 
      if Map.get(invoice, :other_info, []) != [] do
        pdf =
          pdf
          |> Pdf.text_at({50, cursor}, "Información Adicional", bold: true)
          |> Pdf.text_wrap!({50, cursor - 10}, {240, 60}, Enum.join(invoice.other_info, "\n"))
        {pdf, cursor - 80}
      else
        {pdf, cursor}
      end

    pdf =
      pdf
      # Payment
      |> Pdf.text_at({50, payment_cursor}, "Forma de Pago", bold: true)
      |> Pdf.text_at({50, payment_cursor - 20}, invoice.payments.method)
      |> Pdf.text_at({50, payment_cursor - 30}, "Moneda: #{invoice.currency}")
      |> Pdf.text_at({50, payment_cursor - 40}, "Plazo: #{invoice.payments.due_date}")
      |> Pdf.text_at({50, payment_cursor - 50}, "Total: #{invoice.payments.total}")

    # Totals

    {pdf, _grid} =
      Pdf.table(pdf, {400, cursor}, {150, 150}, invoice.totals_table,
        padding: 2,
        border: 0.1,
        cols: [
          [width: 220, bold: true],
          [width: 220, align: :right]
        ]
      )

    Pdf.text_wrap!(pdf, {20, 100}, {width - 40, 20}, "Página #{page_number}", align: :center)
  end

  defp add_table({pdf, :complete}, _invoice, _logo_path, _bar_code_path), do: pdf

  defp add_table({pdf, {:continue, _} = remaining}, invoice, logo_path, bar_code_path) do
    {pdf, grid} =
      pdf
      |> Pdf.add_page(:a4)
      |> add_header(invoice, logo_path, bar_code_path)
      |> Pdf.table({50, 560}, {500, 300}, remaining, @table_opts)

    pdf = add_footer(pdf, invoice)
    add_table({pdf, grid}, invoice, logo_path, bar_code_path)
  end

  defp render_table(pdf, %{items: items}) do
    Pdf.table(pdf, {50, 560}, {500, 350}, items, @table_opts)
  end

  defp add_accounting_number(pdf, %{accounting_number: nil}), do: pdf

  defp add_accounting_number(pdf, %{accounting_number: number}) do
    Pdf.text_at(pdf, {310, 580}, "Contribuyente Nro: #{number}")
  end

  defp add_logo(pdf, image_path) do
    if image_path do
      Pdf.add_image(pdf, {50, 700}, image_path, height: 100)
    else
      pdf
    end
  end

  defp add_bar_code(pdf, image_path) do
    if image_path do
      Pdf.add_image(pdf, {304, 700}, image_path, width: 253, height: 15)
    else
      pdf
    end
  end
end
