# encoding: UTF-8
#Encoding.default_internal = Encoding::UTF_8
require 'test_helper'
 
class TestInfoExtraction < Test::Unit::TestCase

	include TestHelper
	include CodeModels

	def assert_map(exp,map)
		assert_equal exp.count,map.count, "Expected to have keys: #{exp.keys}, it has #{map}"
		exp.each do |k,v|
			assert_equal exp[k],map[k], "Expected #{k} to have #{exp[k]} instances, it has #{map[k.to_s]}. Map: #{map}"
		end
	end

	def assert_code_map_to(code,exp)
		r = parse_code(code)
		map = r.values_map
		assert_map(exp,map)
	end

	def test_info_the_root_is_parsed
		code = "for(var i = 0; i < 10; i++) { var x = 5 + 5; }"
		assert_code_map_to(code, {'i'=> 3, 0.0 => 1, 5.0 => 2, 10.0=> 1, 'x' => 1})
	end

	def test_info_var_statement
		code = "var i = 0;"
		assert_code_map_to(code, {'i'=> 1, 0.0 => 1})
	end

	def test_info_less
		code = "i < 10;"
		assert_code_map_to(code, {'i'=> 1, 10.0 => 1})
	end

	def test_info_postfix
		code = "i++;"
		assert_code_map_to(code, {'i'=> 1})
	end

	def test_info_block
		code = "{ var x = 5 + 5; }"
		assert_code_map_to(code, {'x'=> 1, 5.0 => 2})		
	end

	def test_snippet_1
		code = "var lowercase = function(string){return isString(string) ? string.toLowerCase() : string;};"
		assert_code_map_to(code, {'lowercase'=> 1, 'string' => 4, 'isString' => 1, 'toLowerCase' => 1})
	end

	def test_snippet_2
		code = %q{
			var manualLowercase = function(s) {
			  return isString(s)
			      ? s.replace(/[A-Z]/g, function(ch) {return String.fromCharCode(ch.charCodeAt(0) | 32);})
			      : s;
			};
			var manualUppercase = function(s) {
			  return isString(s)
			      ? s.replace(/[a-z]/g, function(ch) {return String.fromCharCode(ch.charCodeAt(0) & ~32);})
			      : s;
			};
		}
		assert_code_map_to(code, {
			'manualLowercase'=> 1, 'manualUppercase'=>1,
			's' => 8, 'isString' => 2, 'replace' => 2, 
			'[A-Z]'=>1, '[a-z]'=>1,
			'g'=>2, # this is the flag, it should be removed from the AST in the future
			'ch'=>4, 'String'=>2,
			'fromCharCode'=>2, 'charCodeAt'=>2, 
			0.0=>2, 32.0=>2})
	end

	def test_snippet_3
		code = %q{
			'use strict';

				// Declare app level module which depends on filters, and services
				angular.module('myApp', ['myApp.filters', 'myApp.services', 'myApp.directives']).
				  config(['$routeProvider', function($routeProvider) {
				    $routeProvider.when('/aes', {template: 'partials/aes.html', controller: aesCtrl});
				    $routeProvider.when('/about', {template: 'partials/about.html', controller: homeCtrl});
				    //$routeProvider.when('/memorize', {template: 'partials/memorize.html', controller: memorizeCtrl});
				    $routeProvider.when('/phrases', {template: 'partials/phrases.html', controller: phrasesCtrl});
				    //$routeProvider.when('/about', {template: 'partials/about.html', controller: aboutCtrl});
				    $routeProvider.otherwise({redirectTo: '/aes'});
				  }]);
		}
		assert_code_map_to(code, {
			'use strict' => 1,
			'angular'=>1,
			'module'=>1,
			'myApp'=>1,
			'myApp.filters'=>1,
			'myApp.services'=>1,
			'myApp.directives'=>1,
			'config'=>1,
			'$routeProvider' => 6,
			'when' => 3,
			'otherwise'=>1,
			'/aes' =>2, 'partials/aes.html'=>1,
			'/about' =>1, 'partials/about.html'=>1,
			'/phrases' =>1, 'partials/phrases.html'=>1,
			'template' => 3,
			'controller' => 3,
			'aesCtrl' => 1,
			'homeCtrl' => 1,
			'phrasesCtrl' => 1,
			'redirectTo' => 1
		})		
	end

#	def test_encoding_is_supported
#		r = Js.parse_file('test/data/app.js','UTF-8')
#		
#		r.traverse(:also_foreign) do |node|			
#		end
#	end

	def test_no_extraneous_values_simple_encoding
		#code = IO.read('test/data/app.js',{ :encoding => 'UTF-8', :mode => 'rb'})
		r = Js.parse_file('test/data/app_clean.js','UTF-8')
		r.traverse(:also_foreign) do |node|			
			node.collect_values_with_count.each do |value,count|
				value_s = value.to_s.encode(Parser::DEFAULT_INTERNAL_ENCODING)
				value_s = value_s[0..-3] if value_s.end_with?('.0')
				node_code = node.source.code.encode(Parser::DEFAULT_INTERNAL_ENCODING)
				unless node_code.include?(value_s)
					node.class.ecore.eAllAttributes.each do |a|
						if a.many
							puts "Attribute #{a.name}" if node.send(:"#{a.name}").include?(value)
						else
							puts "Attribute #{a.name}" if node.send(:"#{a.name}")==value
						end
					end

					fail("Value '#{value}' expected in #{node}. Artifact: #{node.source.artifact}, abspos: #{node.source.position(:absolute)}, code: '#{node_code}'")
				end
			end
		end
	end

	def test_no_extraneous_values
		#code = IO.read('test/data/app.js',{ :encoding => 'UTF-8', :mode => 'rb'})
		r = Js.parse_file('test/data/app.js','UTF-8')
		r.traverse(:also_foreign) do |node|			
			node.collect_values_with_count.each do |value,count|
				value_s = value.to_s.encode(Parser::DEFAULT_INTERNAL_ENCODING)
				value_s = value_s[0..-3] if value_s.end_with?('.0')
				node_code = node.source.code.encode(Parser::DEFAULT_INTERNAL_ENCODING)
				unless node_code.include?(value_s)
					node.class.ecore.eAllAttributes.each do |a|
						if a.many
							puts "Attribute #{a.name}" if node.send(:"#{a.name}").include?(value)
						else
							puts "Attribute #{a.name}" if node.send(:"#{a.name}")==value
						end
					end

					fail("Value '#{value}' expected in #{node}. Artifact: #{node.source.artifact}, abspos: #{node.source.position(:absolute)}, code: '#{node_code}'")
				end
			end
		end
	end


end