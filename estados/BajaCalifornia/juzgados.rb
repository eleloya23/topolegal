# Proposito: Regresar un arreglo con todos los juzgados pertenecientes a un estado
#
# De preferencia, que los saque de algun url (via scrapping).
# Si no es posible (como en baja california que esta en flash). De manera manual en este mismo archivo
#
# Output:
# ['JUZGADO PRIMERO DE LO CIVIL', 'JUZGADO SEGUNDO DE LO CIVIL', ....]
module Topolegal
  module BajaCalifornia
    class Juzgados
      attr_reader :results

      def initialize
        @results = ""
        @endpoint = "http://www.pjbc.gob.mx/boletinj/2015/my_html/bc150408.htm"
      end


      def run
        # Aqui va el codigo de tu scrapper
        # Al terminar de hacer tu magia
        # recuerda grabarla en la variable @results

        # Tu magia tiene que usar el url de @endpoint

      end
    end
  end
end
