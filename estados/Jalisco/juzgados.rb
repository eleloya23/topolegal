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
        @results = []
        @endpoint = 'http://cjj.gob.mx/consultas/boletin'
      end

      def parse_juzgados(html)
        form = html.forms.first
        @results = form.fields[2].options
      end

      def run
        page = Mechanize.new.get(@endpoint)
        parse_juzgados(page)
      end
    end
  end
end
