class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    !!req.path.match(@pattern) &&
    @http_method == req.request_method.downcase.to_sym
  end

  def run(req, resp)
    m = pattern.match(req.path)

    route_params = {}
    m.names.each do |name|
      route_params[name.to_sym] = m[name]
    end
    controller = @controller_class.new(req, resp, route_params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each { |route| return route if route.matches?(req) }
    nil
  end

  def run(req, resp)
    route = match(req)
    if route
      route.run(req, resp)
    else
      resp.status = 404
    end
  end
end
