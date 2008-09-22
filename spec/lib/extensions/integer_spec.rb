require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Integer do
  describe "#round_bytes" do
    it "should round #{99.megabytes + 450.kilobytes} bytes to 99.44 MB" do
      (99.megabytes + 450.kilobytes).round_bytes.should == "99.44 MB"
    end
    it "should round #{12.kilobytes + 45} bytes to 12.04 KB" do
      (12.kilobytes + 45).round_bytes.should == "12.04 KB"      
    end
    it "should round 999 bytes to 999 bytes" do
      999.round_bytes.should == "999 bytes"
    end
    it "should round nil to 0 bytes" do
      nil.round_bytes.should == "0 bytes"
    end
  end
end