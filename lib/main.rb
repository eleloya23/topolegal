module Topolegal
  class Main
    attr_accessor :acciones, :flags, :estados

    def initialize
      self.acciones = %w{Juzgados Boletines}
      self.flags = %w{output destination date}
      self.estados = Dir.glob('estados/*').reject { |c| File.file?(c)}.map { |c| c.gsub('estados/','')}
      self.estados -= ['Ejemplo']
    end

    def usage
      puts <<-EOF
usage: ./topo.rb estado:accion [opciones]

Estados:
 * #{self.estados.join("\n * ")}

Acciones:
 * #{self.acciones.join(", ")}

Opciones:
 * -output csv
 * -destination /path/to/file/
 * -date YYYY/mm/dd
EOF
      exit 1
    end

    def run(estado, accion, config)
      fecha = config['date'].nil? ? Date.today : Date.strptime(config['date'],'%Y/%m/%d')

      if accion == "Juzgados"
        scrapper = eval("Topolegal::#{estado}::#{accion}").new
      else
        scrapper = eval("Topolegal::#{estado}::#{accion}").new(fecha)
      end

      scrapper.run

      if accion == 'Juzgados'
        puts scrapper.results
      elsif  accion == 'Boletines'
        if config['output'] == 'csv'
          save_data(scrapper.results, estado, fecha, config)
        else
          scrapper.results.each do |r|
            puts ["#{r.estado}", "#{r.juzgado}", "#{r.fecha}", "#{r.expediente}", "#{r.descripcion}"]
          end
        end
      end
    end

    def save_data(results, estado, fecha, config)
      fstr = fecha.strftime('%d-%m-%Y')
      CSV.open("#{config['destination']}#{estado}-#{fstr}.csv", 'wb', { col_sep: '|' }) do |csv|
        csv << ['Estado', 'Juzgado', 'Fecha', 'Expediente', 'Descripcion']
        results.each do |r|
          csv << ["#{r.estado}", "#{r.juzgado}", "#{r.fecha}", "#{r.expediente}", "#{r.descripcion}"]
        end
      end
    end
  end
end
