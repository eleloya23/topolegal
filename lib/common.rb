require 'nokogiri'
require 'typhoeus'
require 'mechanize'
require 'pry'
require 'csv'
require_relative 'expediente'
require_relative 'main'

Dir["#{File.dirname(__FILE__)}/../estados/**/*.rb"].each { |f| load(f) }
