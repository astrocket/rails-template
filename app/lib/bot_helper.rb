require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'time'

module BotHelper
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

    def get(url, options = {})
      options = {
          headers: false
      }.merge!(options)

      uri = URI.parse(URI.escape(url))
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = url.include?('https')
      req = Net::HTTP::Get.new(uri)
      options[:headers].map {|k, v| req[k] = v } if options[:headers]
      https.request(req)
    end

    def post(url, options = {})
      options = {
          body: {},
          headers: {
              'Content-Type' => 'application/json'
          }
      }.merge!(options)

      uri = URI.parse(URI.escape(url))
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = url.include?('https')
      req = Net::HTTP::Post.new(uri.path, initheader = options[:headers])
      req.body = options[:body].to_json
      https.request(req)
    end
  end

  def url_shortner(url)
    shortened_url = post_json("https://api-ssl.bitly.com/v4/shorten", {
        headers: {
            'Content-Type' =>'application/json',
            "Authorization" => "Bearer #{Rails.application.credentials.(&:bitly_token)}"
        },
        body: {
            domain: "bit.ly",
            long_url: url
        }
    })["link"] if Rails.application.credentials.try(:bitly_token)
    shortened_url ? shortened_url : url
  end

  def in_kst(utc_time)
    kst = Time.parse(utc_time) + (Time.zone_offset('KST') || 32400)
    kst.strftime("%Y-%m-%d %H:%M")
  end

  def show_map(address)
    url_shortner("#{URI.escape("http://map.kakao.com?q=#{address}")}#!/all/map/place")
  end

end