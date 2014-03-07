# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, tag: 'div', class: 'control-group row-fluid', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input
    b.use :error, wrap_with: {tag: 'span', class: 'help-inline'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :browsercms, tag: 'div', class: 'control-group row-fluid', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input
    b.use :error, wrap_with: {tag: 'span', class: 'help-inline'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :checkbox, :tag => 'div', :class => 'control-group row-fluid', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label_input
    b.use :hint, :wrap_with => {:tag => 'span', :class => 'help-block'}
    b.use :error, :wrap_with => {:tag => 'span', :class => 'help-inline'}
  end

  config.wrapper_mappings = { :boolean => :checkbox }

  config.wrappers :prepend, tag: 'div', class: "control-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'input-prepend' do |prepend|
      prepend.use :input
    end
    b.use :hint, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :error, wrap_with: {tag: 'span', class: 'help-inline'}
  end

  config.wrappers :append, tag: 'div', class: "control-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'input-append' do |append|
      append.use :input
    end
    b.use :hint, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :error, wrap_with: {tag: 'span', class: 'help-inline'}
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
