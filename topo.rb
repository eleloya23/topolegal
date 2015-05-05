#!/usr/bin/env ruby
# encoding utf-8

require 'nokogiri'
require 'typhoeus'
require 'mechanize'
require 'pry'
require_relative 'lib/expediente'

$acciones = %w{Juzgados Boletines}
# ['estados/Jalisco', 'estados/archivo.txt', 'estados-Baja-California']
# ['estados/Jalisco', 'estados/Baja-California'
# ['Jalisco', 'Baja-California']
$estados = Dir.glob('estados/*').reject { |c| File.file?(c)}.map { |c| c.gsub('estados/','')}
$estados -= ['Ejemplo']

command = ARGV[0]

def usage
  puts <<-EOF
usage: ./topo.rb estado:accion

Estados:
 - #{$estados.join("\n - ")}
Acciones:
 - #{$acciones.join(", ")}
EOF
  exit 1
end

usage if command.nil?

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

require_relative "estados/#{$estado}/#{$accion.downcase}.rb"
topo = eval("Topolegal::#{$estado}::#{$accion}").new

topo.run

#Imprimimos los resultados (todo: guardarlos en un csv o json file)

if $accion == 'Juzgados'
  puts topo.results
elsif $accion =='Boletines'
  topo.results.each do |r|
    puts "[#{r.estado}, #{r.juzgado}, #{r.fecha}, #{r.expediente}, '#{r.descripcion}']"
  end
end

# Falta que guarde los resultados en json. O que guarde los resultados en CSV.
