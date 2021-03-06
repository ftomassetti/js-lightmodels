require 'test_helper'
 
class TestExampleApp < Test::Unit::TestCase

	include TestHelper
	include CodeModels
	include CodeModels::Js

	def setup
		@root = Js.parse_file(relative_path('data/app.js'))
	end

	def test_root_is_ast_root
		assert_class AstRoot, @root
	end

	def test_root_contains_function_call
		assert_equal 1, @root.statements.count
		assert_class ExpressionStatement, @root.statements[0]
		assert_class FunctionCall, @root.statements[0].expression
	end

end