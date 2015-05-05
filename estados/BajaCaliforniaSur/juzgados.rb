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

      def run
        page = Mechanize.new(@enpoint)

        err
      end
    end
  end
end
