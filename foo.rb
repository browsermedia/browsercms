def do_something(callbacks={})
  callbacks[:before].call if callbacks[:before]
  yield
  callbacks[:after].call if callbacks[:after]
end

do_something({
  :before => lambda {
    puts "Will this work?"
  },
  :after => lambda {
    puts "Oh My!"
  } 
}) { puts "This is crazy" }