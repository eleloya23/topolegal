module Topolegal
  class Scrapper

    attr_accessor :results, :fecha, :endpoint

    def sanitize_string(string)
      return string.encode('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').gsub(/[\r\n]/, '')
    end

    def initialize(uri, f = Date.today - 1)
      self.results = []
      self.fecha = f
      self.endpoint = uri
    end

    def run
    end
  end
end
