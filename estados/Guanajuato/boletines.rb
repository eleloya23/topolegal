module Topolegal
  module Guanajuato
    class Boletines < Topolegal::Scrapper

      def initialize(f = Date.today - 1)
        super('http://www.poderjudicial-gto.gob.mx/includes/municipios.php', f)
      end

      def parse_ciudades
        page = Mechanize.new.get(self.endpoint)
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
        @municipios_juzgado.each do |municipio, municipio_juzgado|
          municipio_juzgado[:juzgados].each do |juzgado|
            params = { cbomunicipio: "#{municipio}",
                       cbojuzgados: "#{juzgado[:id]}",
                       incluir2: '1',
                       cbodia: "#{self.fecha.day}",
                       cbomes: "#{self.fecha.month}",
                       cboano: "#{self.fecha.year}"
                     }
            page = Mechanize.new.post('http://www.poderjudicial-gto.gob.mx/modules.php?name=Acuerdos&file=buscar_acuerdos1', params)
            begin
              table = page.search('table')[6]
              trs = table.search('tr')[1..-1]
              trs.each do |tr|
                tds = tr.search('td')
                expediente = "#{tds[0].content.strip}"
                descripcion = "#{tds[1].content.strip}, #{tds[2].content.strip}, #{tds[3].content.strip}"
                save_result('Guanajuato', juzgado[:nombre], expediente, descripcion)
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
