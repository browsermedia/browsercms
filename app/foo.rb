class Foo
  def time
    @time ||= Time.now
  end
  def reset!
    @time = nil
  end
end

foo = Foo.new
puts foo.time
sleep 2
puts foo.time
foo.reset!
sleep 2
puts foo.time