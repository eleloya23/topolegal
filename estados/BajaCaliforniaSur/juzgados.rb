# Proposito: Regresar un arreglo con todos los juzgados pertenecientes a un estado
#
# De preferencia, que los saque de algun url (via scrapping).
# Si no es posible (como en baja california que esta en flash). De manera manual en este mismo archivo
#
# Output:
# ['JUZGADO PRIMERO DE LO CIVIL', 'JUZGADO SEGUNDO DE LO CIVIL', ....]
module Topolegal
  module BajaCaliforniaSur
    class Juzgados
      attr_reader :results

      def initialize
        @results = []
        @endpoint = "http://www.tribunalbcs.gob.mx/listas.php"
      end

      def parse_juzgados(html)
        doc = Nokogiri::HTML(html)

        spans = doc.xpath("//tr/td[position()>last()-2]/span[position()>1]")

        juzgados = []
        name_to_append = ""
        spans.each do |span|
          if span.xpath("@id='subtitulos'")
            name_to_append = span.text
          else
            juzgados << "#{span.xpath("a").first.text}, #{name_to_append}"
          end
        end
        @results = juzgados
      end

      def run
        page = Mechanize.new.get(@endpoint)

        parse_juzgados(page.body)
      end
    end
  end
end
