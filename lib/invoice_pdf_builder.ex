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
    symbol = currency_symbol(document.currency)

    subtotals_by_rate =
      Enum.map(document.taxes, fn tax ->
        label = String.replace(tax.tax_label, "IVA", "SUBTOTAL")
        [label, format_amount(tax.tax_value, symbol)]
      end)

    subtotal_sin_impuesto = [
      ["SUBTOTAL S/IMP.", format_amount(document.sub_total_without_taxes, symbol)]
    ]

    descuento = [["DESCUENTO", format_amount(document.total_discount, symbol)]]

    iva_by_rate =
      Enum.map(document.taxes, fn tax ->
        [tax.tax_label, format_amount(tax.tax_total, symbol)]
      end)

    grand_total = [["Total", format_amount(document.total, symbol)]]

    totals_table =
      subtotals_by_rate ++
        subtotal_sin_impuesto ++
        descuento ++
        iva_by_rate ++
        grand_total

    # Format numeric columns in items table (indices 4-7: precio, cantidad, descuento, total)
    # Row 0 is headers — skip it. Column 5 is quantity (no currency symbol).
    [header | item_rows] = document.items

    formatted_items =
      [
        header
        | Enum.map(item_rows, fn row ->
            row
            |> List.update_at(4, &format_amount(&1, symbol))
            |> List.update_at(5, &format_amount/1)
            |> List.update_at(6, &format_amount(&1, symbol))
            |> List.update_at(7, &format_amount(&1, symbol))
          end)
      ]

    document =
      document
      |> Map.put(:auth_datetime, xml_map.authorization_date)
      |> Map.put(:totals_table, totals_table)
      |> Map.put(:totals_row_count, length(totals_table))
      |> Map.put(:items, formatted_items)
      |> Map.put(:currency_symbol, symbol)

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
    %{width: width, height: _height} = Pdf.size(pdf)

    contribuyente_especial =
      if is_nil(invoice.accounting_number), do: "NO", else: "SI"

    client_table = [
      ["Razón Social/Nombres y Apellidos:", invoice.client_name],
      ["RUC/CI:", invoice.client_identification],
      ["Dirección:", Map.get(invoice, :client_address, "")]
    ]

    business_table = [
      ["Razón social:", invoice.tradename],
      ["Dirección Matriz:", invoice.business_main_address],
      ["Dirección Sucursal:", invoice.business_branch_address],
      ["Obligado a llevar contabilidad:", invoice.accounting],
      ["Contribuyente Especial:", contribuyente_especial]
    ]

    {pdf, _} =
      pdf
      |> Pdf.set_font("Helvetica", 10)
      |> Pdf.set_font_size(7)
      # ── Logo / FACTURA badge ────────────────────────────────────────
      |> add_logo(logo_path)
      # ── Invoice meta (top-right) ────────────────────────────────────
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
      |> Pdf.text_at({310, 735}, "Número de Autorización", bold: true)
      |> add_bar_code(bar_code_path)
      |> Pdf.text_at({310, 700}, invoice.access_key)
      # ── Horizontal divider below header ─────────────────────────────
      |> Pdf.set_line_width(0.3)
      |> Pdf.line({50, 695}, {width - 50, 695})
      |> Pdf.stroke()
      # ── Client title ─────────────────────────────────────────────────
      |> Pdf.set_font_size(8)
      |> Pdf.text_at({50, 680}, "Cliente", bold: true)
      # ── Business name ────────────────────────────────────────────────
      |> Pdf.set_font_size(9)
      |> Pdf.text_at({310, 680}, invoice.business_name, bold: true)
      |> Pdf.set_font_size(7)
      # ── Client mini-table (left, no border) ──────────────────────────
      |> Pdf.table({50, 672}, {260, 60}, client_table,
        padding: 2,
        border: 0,
        cols: [
          [width: 115, bold: true, font_size: 7],
          [width: 145, font_size: 7]
        ]
      )

    # ── Business mini-table (right, no border, aligned to x=310) ─────
    {pdf, _} =
      Pdf.table(pdf, {310, 672}, {240, 72}, business_table,
        padding: 2,
        border: 0,
        cols: [
          [width: 115, bold: true, font_size: 7],
          [width: 125, font_size: 7]
        ]
      )

    # ── Horizontal divider below client/business ─────────────────────
    pdf
    |> Pdf.set_line_width(0.3)
    |> Pdf.line({50, 600}, {width - 50, 600})
    |> Pdf.stroke()
  end

  defp add_footer(pdf, invoice) do
    %{width: width, height: _height} = Pdf.size(pdf)
    items_bottom = Pdf.cursor(pdf)
    text_cursor = items_bottom - 20
    page_number = "#{Pdf.page_number(pdf)}"
    symbol = Map.get(invoice, :currency_symbol, "")

    pdf = Pdf.set_font_size(pdf, 7)

    # ── Info Adicional (left, above payment) ─────────────────────────
    {pdf, payment_cursor} =
      case Map.get(invoice, :other_info, []) do
        [] ->
          {pdf, text_cursor}

        other_info ->
          pdf =
            pdf
            |> Pdf.set_font_size(8)
            |> Pdf.text_at({50, text_cursor}, "Información Adicional", bold: true)

          other_info_table = Enum.map(other_info, fn field -> [field.name <> ":", field.value] end)

          {pdf, _} =
            Pdf.table(pdf, {50, text_cursor - 12}, {350, 100}, other_info_table,
              padding: 2,
              border: 0,
              cols: [
                [width: 90, bold: true, font_size: 7],
                [width: 260, font_size: 7]
              ]
            )

          {pdf, text_cursor - 100}
      end

    # ── Payment section as a structured mini-table ────────────────────
    payment_table = [
      ["Forma de Pago", ""],
      ["Método", invoice.payments.method],
      ["Moneda", invoice.currency],
      ["Plazo", invoice.payments.due_date],
      ["Total", format_amount(invoice.payments.total, symbol)]
    ]

    {pdf, _} =
      Pdf.table(
        pdf,
        {50, payment_cursor},
        {220, 70},
        payment_table,
        padding: 2,
        border: 0.1,
        cols: [
          [width: 80, bold: true, font_size: 7],
          [width: 140, font_size: 7]
        ],
        rows: %{
          0 => [bold: true, background: :gainsboro, font_size: 8]
        }
      )

    # ── Totals table (right, flush with items) ────────────────────────
    row_count = Map.get(invoice, :totals_row_count, 5)
    totals_height = max(row_count * 14, 60)
    last_row_index = row_count

    {pdf, _grid} =
      Pdf.table(pdf, {400, items_bottom}, {150, totals_height}, invoice.totals_table,
        padding: 2,
        border: 0.1,
        cols: [
          [width: 220, bold: true],
          [width: 220, align: :right]
        ],
        rows: %{
          last_row_index => [bold: true, background: :gainsboro]
        }
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

  defp add_logo(pdf, nil) do
    # No logo provided — render a prominent FACTURA badge instead
    pdf
    |> Pdf.set_font("Helvetica", 28)
    |> Pdf.text_at({50, 775}, "FACTURA", bold: true)
    |> Pdf.set_font("Helvetica", 10)
    |> Pdf.set_font_size(7)
  end

  defp add_logo(pdf, image_path) do
    Pdf.add_image(pdf, {50, 700}, image_path, height: 100)
  end

  defp add_bar_code(pdf, nil), do: pdf

  defp add_bar_code(pdf, image_path) do
    Pdf.add_image(pdf, {305, 705}, image_path, width: 235, height: 28)
  end

  defp format_amount(nil), do: "0.00"

  defp format_amount(value) when is_binary(value) do
    case String.split(value, ".") do
      [integer_part, decimal_part] ->
        formatted = integer_part |> format_integer_part()
        "#{formatted}.#{decimal_part}"

      [integer_part] ->
        format_integer_part(integer_part)
    end
  end

  defp format_amount(value), do: to_string(value)

  # format_amount/2 — prepends the currency symbol
  defp format_amount(value, symbol), do: "#{symbol} #{format_amount(value)}"

  defp format_integer_part(integer_str) do
    {sign, digits} =
      if String.starts_with?(integer_str, "-") do
        {"-", String.slice(integer_str, 1..-1//1)}
      else
        {"", integer_str}
      end

    formatted =
      digits
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.join(",")
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.join()

    "#{sign}#{formatted}"
  end

  # Maps XML currency strings to display symbols.
  # Extend this list to support additional currencies in the future.
  defp currency_symbol(currency) do
    case String.upcase(currency || "") do
      "DOLAR" -> "$"
      "USD" -> "$"
      "EUR" -> "€"
      "GBP" -> "£"
      _ -> currency || ""
    end
  end
end
