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
  module BajaCaliforniaSur
    class Boletines
      attr_reader :results

      MONTH_NAMES = ["ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
      MONTH_INDEX = { "ENERO" => 1, "FEBRERO" => 2  , "MARZO" => 3, "ABRIL" => 4, "MAYO" => 5, "JUNIO" => 6, "JULIO" => 7, "AGOSTO" => 8, "SEPTIEMBRE" => 9, "OCTUBRE" => 10, "NOVIEMBRE" => 11, "DICIEMBRE" => 12 }
      INNER_HALF_ENDPOINT = "http://e-tribunal.bcs.gob.mx/AccesoLibre/"

      def initialize(f = Date.today - 1)
        @results = []
        # Por lo pronto el scrapper solo saca los boletines del dia anterior
        @fecha = f
        @endpoint = 'http://www.tribunalbcs.gob.mx/listas.php'
      end

      def run
        mech = Mechanize.new
        page = mech.get(@endpoint)

        j = Topolegal::BajaCaliforniaSur::Juzgados.new
        j.run

        links = page.search("//tr/td[position()>last()-2]/span[position()>1]/a").map{ |link| link.attribute("href").value }

        links.each_with_index do |link, i|
          if link.include?("http://")
            inner_mech = Mechanize.new
            inner_page = inner_mech.get(link)

            calendar_container = inner_page.search("//*[@id='Calendar1']/tr[1]/td")
            calendar_header = calendar_container.search("table/tr/td")
            calendar_month = calendar_header[1].text.split(" ")[0].upcase
            month_diff = MONTH_INDEX[calendar_month] - @fecha.month

            while (month_diff != 0)
              par = []
              if month_diff > 0
                par = calendar_header[0].at("a").attribute("href").value[/['].*[']/].gsub("'", "").split(",")
              else
                par = calendar_header[1].at("a").attribute("href").value[/['].*[']/].gsub("'", "").split(",")
              end
              inner_page = inner_page.form_with(:id => 'form1') do |form|
                form.add_field!("__EVENTTARGET", value = par[0])
                form.add_field!("__EVENTARGUMENT", value = par[1])
              end.submit

              calendar_container = inner_page.search("//*[@id='Calendar1']/tr[1]/td")
              calendar_header = calendar_container.search("table/tr/td")
              calendar_month = calendar_header[1].text.split(" ")[0].upcase
              month_diff = MONTH_INDEX[calendar_month] - @fecha.month
            end

            page_links = inner_page.links
            day_params = nil
            page_links.each do |page_link|
              if page_link.text == @fecha.day.to_s
                day_params = page_link.uri.to_s[/['].*[']/].gsub("'", "").split(",")
                break;
              end
            end

            if(!day_params)
              next
            end

            inner_page = inner_page.form_with(:id => 'form1') do |form|
              form.add_field!("__EVENTTARGET", value = day_params[0])
              form.add_field!("__EVENTARGUMENT", value = day_params[1])
            end.submit

            files_data = inner_page.search("//table[@id='tblResultados']/tr")
            files_data.each do |file|
              tds = file.search("td")
              @results << Expediente.new(estado: $estado, juzgado: j.results[i],
                                       fecha: @fecha.strftime('%d-%m-%Y'), expediente: tds[1].search("span/text()").map{ |val| val.text}.join(" ").gsub(/[\n]+/, " "),
                                       descripcion: tds[2].search("span/text()").map{ |val| val.text}.join(" ").gsub(/[\n]+/, " "))
            end
          else
            inner_mech = Mechanize.new
            inner_page = inner_mech.get("http://www.tribunalbcs.gob.mx/#{link}")

            months = inner_page.search("//td[@id='centro'][@align='center']/table")

            search_in_month = nil

            months.each do |month|
              if month.search("tr[1]/td/div/strong/text()").text == MONTH_NAMES[@fecha.month - 1]
                search_in_month = month
                break
              end
            end

            if (!search_in_month)
              next
            end

            available_days = search_in_month.search("tr/td/div[@class='habiles']/a")

            bulletin_page = nil
            available_days.each do |day|
              if day.text == @fecha.day.to_s
                bulletin_page = Mechanize::Page::Link.new(day, inner_mech, inner_page).click
                break
              end
            end

            if (!bulletin_page)
              next
            end

            bulletin_files = Nokogiri::HTML(bulletin_page.body).search("//table/tr")

            bulletin_files.each do |file|
              resulting_tds = file.search("td")

              @results << Expediente.new(estado: $estado, juzgado: j.results[i],
                                       fecha: @fecha.strftime('%d-%m-%Y'), expediente: resulting_tds[0].text.gsub(/\s+/, ' '),
                                       descripcion: "#{resulting_tds[1].text.gsub(/\s+/, ' ')}, #{resulting_tds[2].text.gsub(/\s+/, ' ')}")

            end
          end
        end
      end
    end
  end
end
