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

        page = Mechanize.new.get(@endpoint)

        juzgados = page.search('/html/body/div/div/p/b/span/text()')

        juzgados = juzgados.map { |j| j.content }.reject { |j| !j.match(/JUZGADO|MIXTO|TRIBUNAL/) }
        # => ["H. TRIBUNAL SUPERIOR DE JUSTICIA DEL\r\nESTADO DE BAJA CALIFORNIA",
        #     "JUZGADO\r\nPRIMERO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015",
        #     "JUZGADO\r\nSEGUNDO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015"]

        juzgados = juzgados.map { |x| x.gsub("\r\n", ' ') }
        # => ["H. TRIBUNAL SUPERIOR DE JUSTICIA DEL ESTADO DE BAJA CALIFORNIA",
        #     "JUZGADO PRIMERO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015",
        #     "JUZGADO SEGUNDO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015"]

        juzgados = juzgados.map { |x| x.split(", B.")[0] }
        # => ["H. TRIBUNAL SUPERIOR DE JUSTICIA DEL ESTADO DE BAJA CALIFORNIA",
        #     "JUZGADO PRIMERO CIVIL MEXICALI",
        #     "JUZGADO SEGUNDO CIVIL MEXICALI"]

        @results = juzgados
      end
    end
  end
end
