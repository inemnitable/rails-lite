require 'json'
require 'webrick'

class Session
  NAME = '_rails_lite_app'

  def initialize(req)
    req.cookies.each do |cookie|
      @cookie = JSON.parse(cookie.value) if cookie.name == NAME
    end

    @cookie ||= {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(resp)
    cookie = WEBrick::Cookie.new(NAME, JSON.dump(@cookie))
    resp.cookies << cookie
  end
end
