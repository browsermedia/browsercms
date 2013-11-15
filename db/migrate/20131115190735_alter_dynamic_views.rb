class AlterDynamicViews < ActiveRecord::Migration
  def change

    Cms::PageTemplate.all.find_each do |pt|
      pt.path = "layout/templates/#{pt.name}"
      pt.locale = "en"
      pt.save!
    end

    Cms::PagePartial.all.find_each do |pp|
      pp.path = "partials/#{pp.name}"
      pp.locale = "en"
      pp.partial = true
      pp.save!
    end
  end
end
