# Proposito: Regresar un arreglo con todos los juzgados pertenecientes a un estado
#
# De preferencia, que los saque de algun url (via scrapping).
# Si no es posible (como en baja california que esta en flash). De manera manual en este mismo archivo
#
# Output:
# ['JUZGADO PRIMERO DE LO CIVIL', 'JUZGADO SEGUNDO DE LO CIVIL', ....]
module Topolegal
  module Guanajuato
    class Juzgados  < Topolegal::Scrapper

      def initialize
        super('http://www.poderjudicial-gto.gob.mx/includes/municipios.php')
      end

      def parse_ciudades
        page = Mechanize.new.get(self.endpoint)
        array = page.body.split(',')
        @municipios = Hash[array.map { |m| m.split ':' }]
      end

      def parse_juzgados
        juzgados = []
        @municipios.each do |municipio, value|
          page = Mechanize.new.get("http://www.poderjudicial-gto.gob.mx/includes/oficinas.php?municipio=#{municipio}")
          juzgados << eval(page.body).map { |h| "#{h[:nombre]} #{value}" }[0] # convertir lo que regresan a un arreglo de hashes
        end
        self.results = juzgados
      end

      def run
        parse_ciudades
        parse_juzgados
      end
    end
  end
end
