require_relative 'check_utils.rb'
require 'allure-ruby-commons'
require_relative 'custom_allure_model.rb'

class TestSum
  def test_sum
    a=2
    b=3
    c=5
    CheckUtils.check_equal(c,a+b, "Sum is working")
  end
end

Allure.configure do |config|
  config.results_directory = "features/allure-results"
  config.clean_results_directory = true
  config.logging_level = Logger::INFO
  config.logger = Logger.new($stdout, Logger::DEBUG)
  config.environment = "staging"

  # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
  config.link_tms_pattern = "http://www.jira.com/browse/{}"
  config.link_issue_pattern = "http://www.jira.com/browse/{}"
end


Allure.lifecycle = @lifecycle = Allure::AllureLifecycle.new(Allure.configure)
# on test suit started
@lifecycle.clean_results_dir
#on test case started
@lifecycle.start_test_container(Allure::TestResultContainer.new(name: "Test Container Started"))
@lifecycle.start_test_case("Test Case 1")
#one test step
@lifecycle.start_test_step("Test Case 1 ko step 1")
update_block = proc do |step|
  # step.stage = Allure::Stage::FINISHED
  # step.status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
end
@lifecycle.update_test_step(&update_block)
@lifecycle.stop_test_step

#two test step
@lifecycle.start_test_step("Test Case 1 ko step 2")
@lifecycle.stop_test_step

# on test case finished
@lifecycle.update_test_case do |test_case|
  # test_case.stage = Allure::Stage::FINISHED
  # test_case.status = event.result.failed? ? Allure::ResultUtils.status(event.result&.exception) : status
  # test_case.status_details.flaky = event.result.flaky?
  test_case.status_details.message = "Fail vo"
  # test_case.status_details.trace = failure_details[:trace]
end
@lifecycle.stop_test_case
@lifecycle.stop_test_container

# on test suit finished
@lifecycle.write_environment

test.test_sum
#on test step finished

