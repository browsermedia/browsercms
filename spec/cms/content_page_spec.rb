require "minitest_helper"

describe Cms::ContentPage do
  class AllController < ActionController::Base
    include Cms::ContentPage
    template :subpage
  end

  class OnlyController < ActionController::Base
    include Cms::ContentPage
    template 'subpage', only: [:hello]
  end

  class ExceptController < ActionController::Base
    include Cms::ContentPage
    template 'subpage', except: [:hello]
  end

  class NoneController < ActionController::Base
    include Cms::ContentPage
  end

  describe "cms_template" do
    it "should return complete path" do
      AllController.new.cms_template.must_equal 'layouts/templates/subpage'
    end

    it 'should allow for overriding in configuration' do
      Rails.configuration.cms.templates.expects(:[]).with('cms/sites/sessions_controller').returns('alternative').at_least_once
      controller = Cms::Sites::SessionsController.new
      controller.cms_template.must_equal 'layouts/templates/alternative'

    end
  end

  describe '#use_template?' do
    describe "for all action_names" do
      let(:controller) { AllController.new }

      it 'be true' do
        controller.send(:use_template?).must_equal true
      end

    end

    describe "none" do
      let(:controller) { NoneController.new }

      it 'for any action' do
        controller.send(:use_template?).must_equal false
      end

    end

    describe ':only' do
      let(:controller) { OnlyController.new }

      it 'for #hello' do
        controller.expects(:action_name).returns('hello')
        controller.send(:use_template?).must_equal true
      end

      it 'for #goodbye' do
        controller.expects(:action_name).returns('goodbye')
        controller.send(:use_template?).must_equal false
      end
    end

    describe ':except' do
      let(:controller) { ExceptController.new }

      it 'should be false for #hello' do
        controller.expects(:action_name).returns('hello')
        controller.send(:use_template?).must_equal false
      end

      it 'should be true for #goodbye' do
        controller.expects(:action_name).returns('goodbye')
        controller.send(:use_template?).must_equal true
      end
    end
  end
end
