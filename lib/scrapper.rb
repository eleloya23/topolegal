module Topolegal
  class Scrapper

    attr_accessor :results, :fecha, :endpoint

    def sanitize_string(string)
      return string.encode('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').gsub(/[\r\n]/, '')
    end

    def validate_format(juzgado, expediente, descripcion)
      # Return false if empty
      return false if expediente.strip.empty?
      return false if descripcion.strip.empty?
      return false if juzgado.strip.empty?

      # Validate format
      return false unless expediente =~ /\w+\/\d+/
      return false unless descripcion =~ /(.+\s){3}/
      return false unless juzgado =~ /(\w+\s){1}/
      true
    end

    def save_result(estado, juzgado, expediente, descripcion)
      if validate_format(juzgado, expediente, descripcion)
        self.results << Expediente.new(estado: sanitize_string(estado), juzgado: sanitize_string(juzgado),
                                 fecha: self.fecha.strftime('%d-%m-%Y'), expediente: sanitize_string(expediente),
                                 descripcion: sanitize_string(descripcion))
      else
        # Aqui va el Log de no se pudo parsear data
        puts "Failed to validate data: #{expediente} | #{descripcion}"
      end
    end

    def initialize(uri, f = Date.today - 1)
      self.results = []
      self.fecha = f
      self.endpoint = uri
    end

    def run
    end

    def method_missing(method_name, *arguments, &block)
      if method_name.to_s =~ /user_(.*)/
        user.send($1, *arguments, &block)
      else
        super
      end
    end

  end
end
