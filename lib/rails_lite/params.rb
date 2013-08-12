require 'uri'
require 'debugger'

class Params
  def initialize(req, route_params)
    # debugger
    qs = req.query_string
    @params = qs ? parse_www_encoded_form(qs) : {}
    @params.merge!(req.body ? parse_www_encoded_form(req.body) : {})
    @params.merge!(route_params || {})
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    shlw_hash = Hash[URI.decode_www_form(www_encoded_form)]
    parsed_hash = {}
    shlw_hash.each do |k,v|
      key_arr = parse_key(k)
      if key_arr.length == 1
        parsed_hash[k] = v
        next
      end
      parsed_hash[key_arr[0]] = {}
      nested_hash = parsed_hash[key_arr[0]]
      i = 1
      while i < key_arr.length - 1
        nested_hash[key_arr[i]] = {}
        nested_hash = nested_hash[key_arr[i]]
        i += 1
      end
      nested_hash[key_arr[-1]] = v
    end
    parsed_hash
  end

  WEIRD_REGEX = /^\[?([^\[\]]*)\]?(\[.*\])?/
  def parse_key(key)
    head = key[WEIRD_REGEX, 1]
    rest = key[WEIRD_REGEX, 2]
    ret = [head]
    ret += parse_key(rest) if rest
    ret
  end
end
