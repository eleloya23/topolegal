# Proposito: Regresar un arreglo con todos los juzgados pertenecientes a un estado
#
# De preferencia, que los saque de algun url (via scrapping).
# Si no es posible (como en baja california que esta en flash). De manera manual en este mismo archivo
# 
# Output:
# ['JUZGADO PRIMERO DE LO CIVIL', 'JUZGADO SEGUNDO DE LO CIVIL', ....]
module Topolegal
  module Jalisco
    class Juzgados
      attr_reader :results

      def initialize
        @results = "" 
        @endpoint = "http://cjj.gob.mx/consultas/boletin"
      end

      def parse_juzgados(html)
        doc = Nokogiri::HTML(html)

        juzgados = doc.at_css("#BoletinJuzgado")
        juzgados = juzgados.xpath("//option")
        juzgados = juzgados.map { |j| j.content }

        @results = juzgados
      end

      def run
        endpoint = "http://cjj.gob.mx/consultas/boletin" 

        h = {
          'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14',
          'X-User-Agent' => 'TopoLegal/1.0 http://buzonlegal.com'
        }

        req = Typhoeus::Request.new(endpoint, timeout: 60, headers: h)

        req.on_complete do |response|
          if response.success?
            parse_juzgados(response.body)
          elsif response.timed_out?
            puts "Se tardo demasiado en responser el endpoint"
          else
            puts "El request fallo: " + response.code.to_s
          end
        end

        req.run
      end
    end
  end
end

