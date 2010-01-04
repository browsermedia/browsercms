require "test_helper"
require "mocha"

class CommandLineTest < ActiveSupport::TestCase

  test "Use the correct demo template with '-m demo'" do
    CommandLine.expects(:template).with("demo.rb").returns("./templates/demo.rb")
    args = ["-m", "demo"]

    CommandLine.set_template(args)

    assert_equal ["-m", "./templates/demo.rb"], args
  end

  test "template_file looks up files based on the current directory" do
    CommandLine.expects(:template_dir).returns("./templates")

    assert_equal "./templates/bar.rb", CommandLine.template("bar.rb")
  end

  test "ARGV gets replaced" do
    CommandLine.expects(:template).with("demo.rb").returns("./templates/demo.rb")
    ARGV = ["-m", "demo"]

    CommandLine.set_template(ARGV)

    assert_equal ["-m", "./templates/demo.rb"], ARGV
  end

  test "Sets blank template if empty" do
    CommandLine.expects(:template).with("blank.rb").returns("./templates/blank.rb")
    args = []

    CommandLine.set_template(args)

    assert_equal ["-m", "./templates/blank.rb"], args
  end

  test "Sets module template with -m" do
    CommandLine.expects(:template).with("module.rb").returns("./templates/module.rb")
    args = ["-m", "module"]

    CommandLine.set_template(args)

    assert_equal ["-m", "./templates/module.rb"], args
  end

  test "Sets the module template with --template" do
    CommandLine.expects(:template).with("module.rb").returns("./templates/module.rb")
    args = ["--template", "module"]

    CommandLine.set_template(args)

    assert_equal ["--template", "./templates/module.rb"], args 
  end

  test "Sets the demo template with --template" do
    CommandLine.expects(:template).with("demo.rb").returns("./templates/demo.rb")
    args = ["--template", "demo"]

    CommandLine.set_template(args)

    assert_equal ["--template", "./templates/demo.rb"], args
  end

  test "Set usage" do
    
  end

end