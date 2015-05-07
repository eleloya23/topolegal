module Topolegal
  module BajaCaliforniaSur
    class Juzgados < Topolegal::Scrapper

      def initialize
        super('http://www.tribunalbcs.gob.mx/listas.php')
      end

      def parse_juzgados(html)
        doc = Nokogiri::HTML(html)

        spans = doc.xpath("//tr/td[position()>last()-2]/span[position()>1]")

        juzgados = []
        name_to_append = ""
        spans.each do |span|
          if span.xpath("@id='subtitulos'")
            name_to_append = span.text
          else
            juzgados << "#{span.xpath("a").first.text}, #{name_to_append}"
          end
        end
        self.results = juzgados
      end

      def run
        page = Mechanize.new.get(@endpoint)

        parse_juzgados(page.body)
      end
    end
  end
end
