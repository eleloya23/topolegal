module Topolegal
  module Jalisco
    class Juzgados < Topolegal::Scrapper

      def initialize
        super('http://cjj.gob.mx/consultas/boletin')
      end

      def parse_juzgados(html)
        form = html.forms.first
        self.results = form.fields[2].options
      end

      def run
        page = Mechanize.new.get(self.endpoint)
        parse_juzgados(page)
      end
    end
  end
end
