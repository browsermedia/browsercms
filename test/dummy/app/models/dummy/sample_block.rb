module Dummy
  class SampleBlock
    extend ::ActiveModel::Naming

    def self.versioned?;
      true;
    end

    def self.publishable?;
      true;
    end

    def self.connectable?;
      true;
    end

    def self.searchable?;
      false;
    end

  end
end