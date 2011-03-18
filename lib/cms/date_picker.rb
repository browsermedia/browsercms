module Cms


  # Helper methods for centralizing Date handling for the CMS.
  # Eventually, we will need a way to handle i18n formatting of dates, but I would also like to have US style dates
  # for US locales (M/d/yy), but since Ruby 1.8.7 and 1.9.2 have different handling of Date.parse, that would take some
  # monkeypatching.
  #
  class DatePicker

    class << self

      # Returns the date format that the JQuery selector will need to use.
      def jquery_format
        'yy/mm/dd'
      end

      def format_for_ui(date)
        date ? date.strftime('%Y/%m/%d') : nil
      end
    end
  end
end