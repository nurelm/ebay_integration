require 'json'

class Configuration
  SANDBOX_URL = 'https://api.sandbox.ebay.com/wsapi'
  PRODUCTION_URL = 'https://api.ebay.com/wsapi'
  VERSION = 883

  def initialize(config={})
    @config = config
  end

  def ebay_client_config
    EbayClient::Configuration.new({ routing: :default,
                                    siteid: @config[:site_id],
                                    preload: false,
                                    version: VERSION,
                                    warning_level: :High,
                                    error_language: :en_US,
                                    api_keys: [{ token: @config[:user_token],
                                                 devid: settings[:devid],
                                                 appid: settings[:appid],
                                                 certid: settings[:certid]}],
                                    savon_log_level: :info,
                                    url: url,
                                    wsdl_file: wsdl_file_url })
  end

  private
    def url
      @config[:sandbox] ? SANDBOX_URL : PRODUCTION_URL
    end

    def wsdl_file_url
      "http://developer.ebay.com/webservices/#{ VERSION }/eBaySvc.wsdl"
    end

    def settings
      @settings ||= YAML.load_file('config/settings.yml')
      @config[:sandbox] ? @settings['sandbox'] : @settings['production']
    end
end