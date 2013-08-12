require 'erb'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, resp, route_params = nil)
    @req = req
    @resp = resp
    @params = Params.new(@req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @response_built
  end

  def redirect_to(url)
    raise "cannot render twice" if @response_built
    @resp.set_redirect(WEBrick::HTTPStatus[302], url)
    session.store_session(@resp)
    @response_built = true
  end

  def render_content(content, type)
    raise "cannot render twice" if @response_built
    @resp.content_type = type
    @resp.body = content
    session.store_session(@resp)
    @response_built = true
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb = ERB.new(template)
    content = erb.result(binding)
    render_content(content, "text/html")
  end

  def invoke_action(name)
  end
end
