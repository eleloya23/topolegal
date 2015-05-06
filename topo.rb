#!/usr/bin/env ruby
# encoding utf-8

require_relative 'lib/common'


topo = Topolegal::Main.new

command = ARGV[0]
config = {}

# We read and configure the params
topo.usage if ARGV.count.even? or command.nil?
estado, accion = command.strip.split(':')
unless topo.estados.include? estado
  puts "No tengo un adaptador para #{estado}"
  puts '-------------------------------------'
  topo.usage
end

unless topo.acciones.include? accion
  puts "No tengo una accion '#{accion}'"
  puts '--------------------------------'
  topo.usage
end

# ARGV[0] is the command. ARGV[1] and ARGV[2] contains the flag and argument
(1..ARGV.count-1).step(2) do |i|
  flag = ARGV[i]
  arg =  ARGV[i + 1]

  # We strip the "-" from the flag
  flag = flag[1..-1]

  if topo.flags.include? flag
    config[flag] = arg
  else
    puts "Opcion invalida: -#{flag}"
    puts '-------------------------------------'
    topo.usage
  end
end

topo.run(estado, accion, config)
