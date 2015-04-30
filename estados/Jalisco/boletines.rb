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
  module Jalisco
    class Boletines
      attr_reader :results

      def initialize
        @results = []
        # Por lo pronto el scrapper solo saca los boletines del dia anterior
        @fecha = Date.today - 1
        @endpoint = 'http://cjj.gob.mx/consultas/boletin'
      end

      def parse_boletines(html)
        form = html.forms.first
        # => "29-04-2015"
        form['data[Boletin][txtbusqueda]'] = @fecha.strftime('%d-%m-%Y')
        form['data[Boletin][tipo]'] = 1
        options = form.fields[2].options
        #options.each do |option|
          form['data[Boletin][juzgado]'] = options[1].value
          #puts "Procesando: #{options[1].text}"
          data = form.submit
          table = data.search('table.twelve')
          uls = table.search('ul.tabs-content')
          dls = uls.search('dl')
          dls.each do |dl|
            dd = dl.search('dd')
            @results << Expediente.new(estado: $estado, juzgado: options[1].text,
                                       fecha: @fecha.strftime('%d-%m-%Y'), expediente: dd[0].content.strip,
                                       descripcion: "#{dd[1].content.strip}, #{dd[2].content.strip}, #{dd[3].content.strip}")
          end
        #end
      end

      def run
        page = Mechanize.new.get(@endpoint)
        parse_boletines(page)
      end
    end
  end
end
