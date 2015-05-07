module Topolegal
  module BajaCaliforniaNorte
    class Juzgados < Topolegal::Scrapper

      def initialize
        super("http://www.pjbc.gob.mx/boletinj/2015/my_html/bc150408.htm")
      end


      def run
        # Aqui va el codigo de tu scrapper
        # Al terminar de hacer tu magia
        # recuerda grabarla en la variable @results

        # Tu magia tiene que usar el url de @endpoint

        page = Mechanize.new.get(self.endpoint)

        juzgados = page.search('/html/body/div/div/p/b/span/text()')

        juzgados = juzgados.map { |j| j.content }.reject { |j| !j.match(/JUZGADO|MIXTO|TRIBUNAL/) }
        # => ["H. TRIBUNAL SUPERIOR DE JUSTICIA DEL\r\nESTADO DE BAJA CALIFORNIA",
        #     "JUZGADO\r\nPRIMERO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015",
        #     "JUZGADO\r\nSEGUNDO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015"]

        juzgados = juzgados.map { |x| x.gsub("\r\n", ' ') }
        # => ["H. TRIBUNAL SUPERIOR DE JUSTICIA DEL ESTADO DE BAJA CALIFORNIA",
        #     "JUZGADO PRIMERO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015",
        #     "JUZGADO SEGUNDO CIVIL MEXICALI, B.C., 6 DE ABRIL DE 2015"]

        juzgados = juzgados.map { |x| x.split(", B.")[0] }
        # => ["H. TRIBUNAL SUPERIOR DE JUSTICIA DEL ESTADO DE BAJA CALIFORNIA",
        #     "JUZGADO PRIMERO CIVIL MEXICALI",
        #     "JUZGADO SEGUNDO CIVIL MEXICALI"]

        self.results = juzgados
      end
    end
  end
end
