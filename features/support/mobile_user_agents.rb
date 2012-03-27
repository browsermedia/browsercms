SAMPLE_AGENT_STRING = {
    "iPhone" => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5",
    "Android" => "HTC_Eris Mozilla/5.0 (Linux; U; Android 4.0; en-ca; Build/GINGERBREAD) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1",
    "Windows Mobile" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; HTC_Touch_Diamond2_T5353; Windows Phone 6.5)",
    "Windows Phone 7" => "Mozilla/4.0 (compatible; MSIE 7.0; Windows Phone OS 7.0; Trident/3.1; IEMobile/7.0) Asus;Galaxy6",
    "Blackberry" => "BlackBerry9700/5.0.0.351 Profile/MIDP-2.1 Configuration/CLDC-1.1 VendorID/123",
    "Palm Pre" => "Mozilla/5.0 (webOS/1.0; U; en-US) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/1.0 Safari/525.27.1 Pre/1.0",
    "Nokia N97" => "Mozilla/5.0 (SymbianOS/9.4; Series60/5.0 NokiaN97-1/20.0.019; Profile/MIDP-2.1 Configuration/CLDC-1.1) AppleWebKit/525 (KHTML, like Gecko) BrowserNG/7.1.18124"
}

module Cms
  module RackTestDriver
    module UserAgent

      # This may break badly with future versions of RackTest.
      def request_as_iphone
        options = page.driver.instance_variable_get("@options")
        options[:headers] = {"HTTP_USER_AGENT" => SAMPLE_AGENT_STRING['iPhone']}
        page.driver.instance_variable_set "@options", options
      end

    end
  end

end
World(Cms::RackTestDriver::UserAgent)