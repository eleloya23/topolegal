module Topolegal
  module NuevoLeon
    class Boletines < Topolegal::Scrapper

      def initialize(f = Date.today - 1)
        super('http://www.pjenl.gob.mx/TSJ/BoletinJudicial/Default.aspx', f)
      end

      def run
        # setup
        FileUtils::mkdir_p 'tmp'

        # run
        agent = Mechanize.new
        page = agent.get(self.endpoint)

        img = page.search "//img"
        agent.get(img.attr('src')).save 'tmp/captcha.jpg'

        ocr = Topolegal::Ocr.new
        captcha_txt = ocr.process_img 'tmp/captcha.jpg'

        puts captcha_txt ? captcha_txt : 'ERROR'

        # cleanup
        FileUtils::rm_rf 'tmp'
      end

    end
  end
end
