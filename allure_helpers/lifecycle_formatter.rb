module AllureHelper
  class AllureLifecycleHandler

    ALLURE_STATUS = {
      failed: Allure::Status::FAILED,
      skipped: Allure::Status::SKIPPED,
      passed: Allure::Status::PASSED
    }.freeze

    def initialize(allure_configuration)
      Allure.lifecycle = @lifecycle = Allure::AllureLifecycle.new(allure_configuration)
      @custom_test_framework_model ||= CustomTestFrameworkModel.new(allure_configuration)
      names = Allure::TestPlan.test_names
    end

    # Clean test result directory before starting run
    # @return [void]
    def start_test_run
      lifecycle.clean_results_dir
    end

    # Handle test case started event
    # @param [String] test_case_name
    # @param [Hash] test_result
    # @return [void]
    def start_test_case(test_case_name, test_result={})
      lifecycle.start_test_container(Allure::TestResultContainer.new(name: test_case_name))
      lifecycle.start_test_case(@custom_test_framework_model.test_result(test_result))
    end

    # Handle test step started event
    # @param [Hash] test_step
    # @return [void]
    def start_test_step(test_step)
      step = @custom_test_framework_model.step_result(test_step)
      lifecycle.start_test_step(step[:allure_step])
      # step[:attachments].each { |att| lifecycle.write_attachment(att[:source], att[:allure_attachment]) }
    end

    # Handle test step finished event
    # @param [Cucumber::Events::TestStepFinished] event
    # @return [void]
    def finish_test_step(event)
      update_block = proc do |step|
        step.stage = Allure::Stage::FINISHED
        # step.status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
      end
      lifecycle.update_test_step(&update_block)
      lifecycle.stop_test_step
    end

    # Handle test case finished event
    # @param [Cucumber::Events::TestCaseFinished] event
    # @return [void]
    # some work to do
    def finish_test_case(event)
      failure_details = @custom_test_framework_model.failure_details(event.result)
      status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
      lifecycle.update_test_case do |test_case|
        test_case.stage = Allure::Stage::FINISHED
        test_case.status = event.result.failed? ? Allure::ResultUtils.status(event.result&.exception) : status
        test_case.status_details.flaky = event.result.flaky?
        test_case.status_details.message = failure_details[:message]
        test_case.status_details.trace = failure_details[:trace]
      end
      lifecycle.stop_test_case
      lifecycle.stop_test_container
    end

    # Write Environment configs after everything is done
    # @return [void]
    def on_test_run_finished
      lifecycle.write_environment
    end
  end
end