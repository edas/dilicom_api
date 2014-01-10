require 'spec_helper'

describe DilicomApi::Hub::Client do
 
  # Generic get_notice tests 
  context "#get_notice" do
    include_context "faraday connection" 
    
    let(:end_point) { "/v1/hub-numerique-api/onix/getNotice" }
    let(:ean13) { "1234567890123" }
    let(:distributor) { "0987654321098" }
    let(:message) {
      '<?xml version="1.0" encoding="UTF-8"?><ONIXMessage release="3.0" xmlns="http://www.editeur.org/onix/3.0/reference">
<Header>
<Sender>
<SenderIdentifier><SenderIDType>06</SenderIDType><IDValue>3025599000108</IDValue></SenderIdentifier>
<SenderName>SERVEUR DILICOM - HUB NUMERIQUE</SenderName></Sender>
<Addressee><AddresseeIdentifier><AddresseeIDType>06</AddresseeIDType><IDValue>3012410001000</IDValue></AddresseeIdentifier></Addressee>
<SentDateTime>20101103T0529Z</SentDateTime>
</Header>
<Product><RecordReference>immateriel.fr-RP944</RecordReference><NotificationType>03</NotificationType><ProductIdentifier><ProductIDType>01</ProductIDType><IDValue>RP944</IDValue></ProductIdentifier><ProductIdentifier><ProductIDType>03</ProductIDType><IDValue>3600120309440</IDValue></ProductIdentifier><DescriptiveDetail><ProductComposition>00</ProductComposition><ProductForm>ED</ProductForm><ProductFormDetail>E107</ProductFormDetail><ProductFormDescription>PDF</ProductFormDescription><EpubTechnicalProtection>02</EpubTechnicalProtection><EpubUsageConstraint><EpubUsageType>02</EpubUsageType><EpubUsageStatus>01</EpubUsageStatus></EpubUsageConstraint><EpubUsageConstraint><EpubUsageType>03</EpubUsageType><EpubUsageStatus>01</EpubUsageStatus></EpubUsageConstraint><EpubUsageConstraint><EpubUsageType>04</EpubUsageType><EpubUsageStatus>01</EpubUsageStatus></EpubUsageConstraint><TitleDetail><TitleType>01</TitleType><TitleElement><TitleElementLevel>01</TitleElementLevel><TitleText>Mieux programmer en C++</TitleText></TitleElement></TitleDetail></DescriptiveDetail><RelatedMaterial><RelatedProduct><ProductRelationCode>02</ProductRelationCode><ProductIdentifier><ProductIDType>01</ProductIDType><IDValue>O18600</IDValue></ProductIdentifier><ProductIdentifier><ProductIDType>03</ProductIDType><IDValue>9782212850185</IDValue></ProductIdentifier><ProductIdentifier><ProductIDType>15</ProductIDType><IDValue>9782212850185</IDValue></ProductIdentifier></RelatedProduct></RelatedMaterial><ProductSupply><SupplyDetail><Supplier><SupplierRole>03</SupplierRole><SupplierIdentifier><SupplierIDType>02</SupplierIDType><IDValue>D1</IDValue></SupplierIdentifier><SupplierIdentifier><SupplierIDType>06</SupplierIDType><IDValue>3012410001000</IDValue></SupplierIdentifier><SupplierName>immat&#233;riel.fr</SupplierName></Supplier><ProductAvailability>45</ProductAvailability><UnpricedItemType>03</UnpricedItemType></SupplyDetail></ProductSupply></Product>
 
</ONIXMessage>'
    }
    it "end point should be called" do
      called = false
      set_connection do |stub|
        stub.get(end_point) do |env|   
          called = true
          [200, {}, message]
        end
      end
      links = subject.get_notice(ean13, distributor)
      expect(called).to be_true
    end
    it "should send the ean13" do
      options = { }
      set_connection do |stub|
        stub.get(end_point) do |env|  
          options = env[:params]
          [200, {}, message]
        end
      end
      subject.get_notice(ean13, distributor)
      expect(options).to have_key("ean13")
      expect(options["ean13"]).to eq(ean13)
    end
    it "should send the distributor as glnDistributor" do
      options = { }
      set_connection do |stub|
        stub.get(end_point) do |env|  
          options = env[:params]
          [200, {}, message]
        end
      end
      subject.get_notice(ean13, distributor)
      expect(options).to have_key("glnDistributor")
      expect(options["glnDistributor"]).to eq(distributor)
    end
    it "should return an onix file" do
      set_connection do |stub|
        stub.get(end_point) do |env|  
          options = env[:params]
          [200, {}, message]
        end
      end
      onix = subject.get_notice(ean13, distributor)
      expect(onix).to match(/\bONIX[mM]essage\b/)
    end
  end

end

