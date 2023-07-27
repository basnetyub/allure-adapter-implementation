require 'allure-ruby-commons'

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


Allure.lifecycle = @lifecycle = Allure::AllureLifecycle.new(Allure.configuration)
# on test suit started
@lifecycle.clean_results_dir
#on test case started
@lifecycle.start_test_container(Allure::TestResultContainer.new(name: "Test Container Started"))
test_result = Allure::TestResult.new(
  name: "Test Case 1",
  description: "Hello I am test case one",
  # description_html: scenario.description,
  # history_id: scenario.id,
  # full_name: scenario.name,
  # labels: parser.labels,
  # links: parser.links,
  # parameters: parser.parameters,
  # status_details: parser.status_details,
  # environment: config.environment
)
@lifecycle.start_test_case(test_result)

#one test step
allure_step = Allure::StepResult.new(
  name: "Test Step 1",
  # attachments: attachments.map { |att| att[:allure_attachment] }
)
@lifecycle.start_test_step(allure_step)
update_block = proc do |step|
  # step.stage = Allure::Stage::FINISHED
  # step.status = ALLURE_STATUS.fetch(event.result.to_sym, Allure::Status::BROKEN)
end
@lifecycle.update_test_step(&update_block)
@lifecycle.stop_test_step

#two test step
allure_step = Allure::StepResult.new(
  name: "Test Case 1 ko Test Step 2",
# attachments: attachments.map { |att| att[:allure_attachment] }
  )
@lifecycle.start_test_step(allure_step)
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