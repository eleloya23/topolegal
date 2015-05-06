#!/usr/bin/env ruby
# encoding utf-8

require 'nokogiri'
require 'typhoeus'
require 'mechanize'
require 'pry'
require 'csv'

require_relative 'lib/expediente'

$acciones = %w{Juzgados Boletines}
$flags = %w{-output -destination}
# ['estados/Jalisco', 'estados/archivo.txt', 'estados-Baja-California']
# ['estados/Jalisco', 'estados/Baja-California'
# ['Jalisco', 'Baja-California']
$estados = Dir.glob('estados/*').reject { |c| File.file?(c)}.map { |c| c.gsub('estados/','')}
$estados -= ['Ejemplo']

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
EOF
  exit 1
end

command = ARGV[0]

usage if ARGV.count.even? or command.nil?

$estado, $accion = command.strip.split(':')

if !$estados.include? $estado
  puts "No tengo un adaptador para #{$estado}"
  puts '-------------------------------------'
  usage
end

if !$acciones.include? $accion
  puts "No tengo una accion '#{$accion}'"
  puts '--------------------------------'
  usage
end

config = {
  "output" => "",
  "destination" => "",
}

(1..ARGV.count-1).step(2) do |i|
  flag = ARGV[i]
  arg = ARGV[i+1]

  if $flags.include? flag
    config[flag[1..-1]] = arg
  else
    puts "Opcion invalida: #{flag}"
  end
end

require_relative "estados/#{$estado}/#{$accion.downcase}.rb"
topo = eval("Topolegal::#{$estado}::#{$accion}").new

topo.run

if $accion == 'Juzgados'
  puts topo.results
elsif $accion =='Boletines'
  if config["output"] == "csv"
    fecha = Date.today.strftime('%d-%m-%Y')
    CSV.open("#{config['destination']}#{$estado}-#{fecha}.csv", "wb", { :col_sep => '|' }) do |csv|
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
