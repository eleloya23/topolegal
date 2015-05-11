module Topolegal
  module NuevoLeon
    class Juzgados < Topolegal::Scrapper

      def initialize
        super('http://www.pjenl.gob.mx/TSJ/BoletinJudicial/Default.aspx')
      end

      def run
        page = Mechanize.new.get(self.endpoint)

        juzgados = page.search '//select[@id="MainContent_ddlJuzgado"]/optgroup'

        juzgados.each do |j|
          prefixj =  j.attr('label')
          opts = j.search 'option'
          results << opts.map{ |x| "#{prefixj} #{x.content}" }
        end

      end
    end
  end
end
