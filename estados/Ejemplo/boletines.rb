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

module Topolegal
  module Ejemplo
    class Boletines
      attr_reader :results

      def initialize(f = Date.today - 1)
        @results = []
        # Por lo pronto el scrapper solo saca los boletines del dia anterior
        @fecha = f
        @endpoint = ''
      end

      def run
        # Aqui va el codigo de tu scrapper
        # Al terminar de hacer tu magia
        # recuerda grabarla en la variable @results

        # Tu magia tiene que usar el url de @endpoints
        # asi como tambien la fecha de @fecha

        magia

        @results << Expediente.new(estado: $estado, juzgado: magia[:juzgado],
                                   fecha: @fecha.strftime('%d-%m-%Y'), expediente: magia[:expediente],
                                   descripcion: magia[:descripcion])
      end
    end
  end
end
