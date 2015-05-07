module Topolegal
  module Jalisco
    class Boletines < Topolegal::Scrapper

      def initialize(f = Date.today - 1)
        super('http://cjj.gob.mx/consultas/boletin', f)
      end

      def parse_boletines(html)
        form = html.forms.first
        # => "29-04-2015"
        form['data[Boletin][txtbusqueda]'] = self.fecha.strftime('%d-%m-%Y')
        form['data[Boletin][tipo]'] = 1
        options = form.fields[2].options
        options.each do |option|
          form['data[Boletin][juzgado]'] = option.value
          #puts "Procesando: #{option.text}"
          data = form.submit
          table = data.search('table.twelve')
          uls = table.search('ul.tabs-content')
          dls = uls.search('dl')
          dls.each do |dl|
            dd = dl.search('dd')
            juzgado = option.text
            expediente = dd[0].content.strip
            descripcion  = "#{dd[1].content.strip}, #{dd[2].content.strip}, #{dd[3].content.strip}"
            save_results('Jalisco', juzgado, expediente, descripcion)
          end
        end
      end

      def run
        page = Mechanize.new.get(self.endpoint)
        parse_boletines(page)
      end
    end
  end
end
