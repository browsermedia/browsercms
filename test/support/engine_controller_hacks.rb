# Rewrite test methods to avoid need to repeat :use_route => :cms in EVERY functional test call
# See http://edgeguides.rubyonrails.org/engines.html#testing-an-engine for why this would be necessary.
module EngineControllerHacks
  def get(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, "GET")
  end

  # Executes a request simulating POST HTTP method and set/volley the response
  def post(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, "POST")
  end

  # Executes a request simulating PUT HTTP method and set/volley the response
  def put(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, "PUT")
  end

  # Executes a request simulating DELETE HTTP method and set/volley the response
  def delete(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, "DELETE")
  end

  private

  def process_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
    parameters ||= {}
    merge = { :use_route => :cms }
    if parameters[:use_route] == false
      parameters.delete(:use_route)
      merge = {}
    end
    process(action, method, parameters.merge!(merge), session, flash)
  end
end

ActionController::TestCase.send(:include, EngineControllerHacks)