require "uri"
require "net/http"
require "net/https"
require "json"
require "time"

module HttpHelper
  def self.included(base)
    base.extend(Methods)
    base.send(:include, Methods)
  end

  module Methods
    def get_json(url, options = {})
      JSON.parse(get(url, options).body)
    end

    def post_json(url, options = {})
      JSON.parse(post(url, options).body)
    end

    def delete_json(url, options = {})
      JSON.parse(delete(url, options).body)
    end

    def get(url, options = {})
      options = {
        headers: false,
        timeout: 10
      }.merge!(options)

      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.read_timeout = options[:timeout] || 10
      https.use_ssl = url.include?("https")
      req = Net::HTTP::Get.new(uri)
      options[:headers].map { |k, v| req[k] = v } if options[:headers]
      https.request(req)
    end

    def post(url, options = {})
      options = {
        body: {},
        headers: {
          "Content-Type" => "application/json"
        },
        timeout: 10
      }.merge!(options)

      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.read_timeout = options[:timeout] || 10
      https.use_ssl = url.include?("https")
      req = Net::HTTP::Post.new(uri.path, initheader = options[:headers])
      req.body = options[:body].to_json
      https.request(req)
    end

    def delete(url, options = {})
      options = {
        body: {},
        headers: {
          "Content-Type" => "application/json"
        },
        timeout: 10
      }.merge!(options)

      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.read_timeout = options[:timeout] || 10
      https.use_ssl = url.include?("https")
      req = Net::HTTP::Delete.new(uri.path, initheader = options[:headers])
      req.body = options[:body].to_json
      https.request(req)
    end
  end
end
