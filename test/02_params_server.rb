require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'rails_lite'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html
server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class ExampleController < ControllerBase
  def create
    render_content(params.to_s, "text/json")
  end

  def new
    page = <<-END
<form action="/?a=3&b=4&c=3" method="post">
  <input type="text" name="cat[name][horse][monkey][dog]">
  <input type="text" name="cat[name][horse][monkey][owner]">
  <input type="text" name="dog">

  <input type="submit">
</form>
END

    render_content(page, "text/html")
  end
end

server.mount_proc '/' do |req, res|
  case req.path
  when '/'
    contr = ExampleController.new(req, res).create
  when '/new'
    contr = ExampleController.new(req, res).new
  end
end

server.start
