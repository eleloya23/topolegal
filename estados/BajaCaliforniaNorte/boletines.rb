module Topolegal
  module BajaCaliforniaNorte
    class Boletines < Topolegal::Scrapper

      def initialize(f = Date.today - 1)
        custom_uri = "http://www.pjbc.gob.mx/boletinj/#{f.year}/my_html/bc#{f.strftime('%y%d%m')}.htm"
        super(custom_uri,f)
      end

      def run

        page = Mechanize.new.get(self.endpoint)
        j = Topolegal::BajaCaliforniaNorte::Juzgados.new
        j.run

        juzgados = page.search("/html/body/div/div")

        num_juzgados = juzgados.count

        # Sacamos los acuerdos de los primeros 37 juzgados usando el metodo bayesiano
        # $ns1[count(.|$ns2) = count($ns2)]
        # $ns1 = /html/body/div/div[$k]/following-sibling::table
        # $ns2 = /html/body/div/div[$k+1]/preceding-sibling::table

        # SACAMOS LOS BOLETINES DE LOS PRIMEROS 37 JUZGADOS
        # Le restamos uno, porque solo queremos del 1 al 37
        (num_juzgados - 1).times do |num|
          k = num + 1
          tablas_expedientes = page.search("/html/body/div/div[#{k}]/following-sibling::table[count(.|/html/body/div/div[#{k+1}]/preceding-sibling::table)=count(/html/body/div/div[#{k+1}]/preceding-sibling::table)]")
          tablas_expedientes.each do |tabla|
            rows = tabla.xpath("tr/td[position()>last()-2]")

            (0..rows.count-1).step(2) do |n|
              expediente = sanitize_string(rows[n].search("*/text()").to_s)
              descripcion = sanitize_string(rows[n+1].search("*/text()").to_s)
              self.results << Expediente.new(estado: 'BajaCaliforniaNorte', juzgado: j.results[k-1],
                                       fecha: @fecha.strftime('%d-%m-%Y'), expediente: expediente,
                                       descripcion: descripcion)
            end
          end
        end

      end

    end
  end
end
