defmodule BillingCore.InvoicePdfBuilderTest do
  use ExUnit.Case

  alias BillingCore.InvoicePdfBuilder
  alias BillingCore.InvoiceXmlParser

  setup do
    xml_signed = File.read!("test/fixtures/invoice_xml_signed.xml")
    xml_map = InvoiceXmlParser.parse(xml_signed)

    {:ok, xml_map: xml_map}
  end

  describe "build/1" do
    test "build a pdf", %{xml_map: xml_map} do
      dbg(xml_map)

      pdf = InvoicePdfBuilder.build(xml_map)
      File.write!("/home/joselo/Downloads/invoice.pdf", pdf)
    end
  end
end
