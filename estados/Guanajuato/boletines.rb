# Proposito: Regresar un arreglo con todos los juzgados pertenecientes a un estado
#
# De preferencia, que los saque de algun url (via scrapping).
# Si no es posible (como en baja california que esta en flash). De manera manual en este mismo archivo
#
# Output:
# ['JUZGADO PRIMERO DE LO CIVIL', 'JUZGADO SEGUNDO DE LO CIVIL', ....]
module Topolegal
  module Guanajuato
    class Boletines
      attr_reader :results

      def initialize
        @results = []
      end

      def parse_ciudades
        page = Mechanize.new.get('http://www.poderjudicial-gto.gob.mx/includes/municipios.php')
        array = page.body.split(',')
        @municipios = Hash[array.map { |m| m.split ':' }]
      end

      def parse_juzgados
        @municipios_juzgado = {}
        @municipios.each do |municipio, value|
          page = Mechanize.new.get("http://www.poderjudicial-gto.gob.mx/includes/oficinas.php?municipio=#{municipio}")
          juzgado = eval(page.body)  # convertir lo que regresan a un arreglo de hashes
          @municipios_juzgado[municipio] = { municipio: value, juzgados: juzgado }
        end
      end

      def parse_boletines
        date = Date.today - 1
        @municipios_juzgado.each do |municipio, municipio_juzgado|
          municipio_juzgado[:juzgados].each do |juzgado|
            params = { cbomunicipio: "#{municipio}",
                       cbojuzgados: "#{juzgado[:id]}",
                       incluir2: '1',
                       cbodia: "#{date.day}",
                       cbomes: "#{date.month}",
                       cboano: "#{date.year}"
                     }
            page = Mechanize.new.post('http://www.poderjudicial-gto.gob.mx/modules.php?name=Acuerdos&file=buscar_acuerdos1', params)
            begin
              table = page.search('table')[6]
              trs = table.search('tr')[1..-1]
              trs.each do |tr|
                tds = tr.search('td')
                @results << Topolegal::Expediente.new(estado: $estado, juzgado: juzgado[:nombre], fecha: date.strftime('%d-%m-%Y'),
                                                      expediente: "#{tds[0].content.strip}", descripcion: "#{tds[1].content.strip}, #{tds[2].content.strip}, #{tds[3].content.strip}")
              end
            rescue NoMethodError
              # Si no hay resultados se rescata la excepcion y seguimos adelante
            end
          end
        end
      end

      def run
        parse_ciudades
        parse_juzgados
        parse_boletines
      end
    end
  end
end
