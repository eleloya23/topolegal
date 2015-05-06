# Proposito: Regresar un arreglo con todos los boletines pertenecientes a un estado
#
# De preferencia, que los saque de algun url (via scrapping).
# Output:
# [Expediente, Expediente, Expediente, ....]

# [#<Topolegal::Expediente:0x007f859c93ec60
#  @descripcion="MERCANTIL EJECUTIVO, CJWTC INMUEBLES, S.A. DE C.V. vs. GONZALEZ BUSTOS RAUL, Se ordena extraer del archivo",
#  @estado="Jalisco",
#  @expediente="1549/96",
#  @fecha="29-04-2015",
#  @juzgado="JUZGADO SEGUNDO DE LO CIVIL">, ...]

require_relative 'juzgados.rb'

module Topolegal
  module BajaCaliforniaNorte
    class Boletines
      attr_reader :results

      def initialize(f = nil)
        @results = []
        # Por lo pronto el scrapper solo saca los boletines del dia anterior
        @fecha = f ? f : Date.today - 1
        @endpoint = 'http://www.pjbc.gob.mx/boletinj/2015/my_html/bc150408.htm'
      end

      def sanitize_string(string)
        return string.encode('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').gsub(/[\r\n]/, '')
      end

      def run
        page = Mechanize.new.get(@endpoint)
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
              @results << Expediente.new(estado: $estado, juzgado: j.results[k-1],
                                       fecha: @fecha.strftime('%d-%m-%Y'), expediente: expediente,
                                       descripcion: descripcion)
            end
          end
        end

      end

    end
  end
end
