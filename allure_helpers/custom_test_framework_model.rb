module AllureHelper

  class CustomTestFrameworkModel
    def initialize(allure_config)
      @config = allure_config
    end

    # Convert to allure test result
    # @param [Hash] test_result_values
    # eg: {name: "Test Case Name", description: "Test Case description"}
    # @return [Allure::TestResult]
    def test_result(test_result_values={})
      Allure::TestResult.new(
        name: test_result_values[:name],
        description: test_result_values[:description]
        # description_html: scenario.description,
        # history_id: scenario.id,
        # full_name: scenario.name,
        # labels: parser.labels,
        # links: parser.links,
        # parameters: parser.parameters,
        # status_details: parser.status_details,
        # environment: config.environment
      )
    end

    # Convert to allure step result
    # @param [Hash] test_step
    # @return [Hash]
    def step_result(test_step={})
      allure_step = Allure::StepResult.new(
        name: test_step[:name],
        # attachments: attachments.map { |att| att[:allure_attachment] }
      )
      { allure_step: allure_step, attachments: attachments }
    end

    # Get failure details
    # @param [Cucumber::Core::Test::Result] result
    # @return [Hash<Symbol, String>]
    def failure_details(result)
      return { message: result.exception.message, trace: result.exception.backtrace.join("\n") } if result.failed?
      return { message: result.message, trace: result.backtrace.join("\n") } if result.undefined?
      {}
    end
  end
end