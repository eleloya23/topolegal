module Topolegal
  class Logger
    attr_accessor :estado, :config, :fecha

    def initialize(a,b)
      self.estado = a
      self.config = b

      self.fecha = config['date'].nil? ? (Date.today - 1) : Date.strptime(config['date'],'%Y/%m/%d')
    end

    def error(mensaje)
      fstr = fecha.strftime('%d-%m-%Y')
      if File.exist?("#{self.config['destination']}Log-#{fstr}.csv")
        CSV.open("#{self.config['destination']}Log-#{fstr}.csv", 'ab', { col_sep: '|' }) do |csv|
          csv << ["#{self.estado}", "#{fstr}", "error", "#{mensaje}"]
        end
      else
        CSV.open("#{self.config['destination']}Log-#{fstr}.csv", 'ab', { col_sep: '|' }) do |csv|
          csv << ['Estado', 'Fecha', 'Tipo', 'Mensaje']
          csv << ["#{self.estado}", "#{fstr}", "error", "#{mensaje}"]
        end
      end
    end
  end
end
