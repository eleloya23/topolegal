#!/usr/bin/env ruby
# encoding utf-8

require_relative 'lib/common'
require_relative 'lib/expediente'

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
       * #{$estados.join("\n * ")}
      Acciones:
       * #{$acciones.join(", ")}
      Opciones:
       * -output csv
       * -destination /path/to/file/
       * -date YYYY/mm/dd
      EOF
      exit 1
    end
end


topo = Topolegal::Main.new

command = ARGV[0]
config = {}

# We read and configure the params
topo.usage if ARGV.count.even? or command.nil?
estado, accion = command.strip.split(':')
unless topo.estados.include? estado
  puts "No tengo un adaptador para #{estado}"
  puts '-------------------------------------'
  usage
end

unless topo.acciones.include? accion
  puts "No tengo una accion '#{accion}'"
  puts '--------------------------------'
  usage
end

# ARGV[0] is the command. ARGV[1] and ARGV[2] contains the flag and argument
(1..ARGV.count-1).step(2) do |i|
  flag = ARGV[i]
  arg =  ARGV[i+1]

  # We strip the "-" from the flag
  flag = flag[1..-1]

  if topo.flags.include? flag
    config[flag] = arg
  else
    puts "Opcion invalida: -#{flag}"
    puts '-------------------------------------'
    usage
  end

end

require_relative "estados/#{estado}/#{accion.downcase}.rb"


topo.run(estado,accion,config)



if $accion == "Juzgados" or config["date"] == ""
  fecha = Date.today
  topo = eval("Topolegal::#{$estado}::#{$accion}").new
else
  fecha = Date.strptime(config["date"],"%Y/%m/%d")
  topo = eval("Topolegal::#{$estado}::#{$accion}").new(fecha)
end

topo.run

if $accion == 'Juzgados'
  puts topo.results
elsif $accion =='Boletines'
  if config["output"] == "csv"
    fstr = fecha.strftime('%d-%m-%Y')
    CSV.open("#{config['destination']}#{$estado}-#{fstr}.csv", "wb", { :col_sep => '|' }) do |csv|
      csv << ["Estado", "Juzgado", "Fecha", "Expediente", "Descripcion"]
      topo.results.each do |r|
        csv << ["#{r.estado}", "#{r.juzgado}", "#{r.fecha}", "#{r.expediente}", "#{r.descripcion}"]
      end
    end
  else
    topo.results.each do |r|
      puts ["#{r.estado}", "#{r.juzgado}", "#{r.fecha}", "#{r.expediente}", "#{r.descripcion}"]
    end
  end
end
