Feature:
  Cucumber isn't fully Rails 4.0 compatible yet, so we need to upgrade when it is.
  Right now, we get the following warnings:

  DEPRECATION WARNING: ActionController::Integration is deprecated and will be removed, use ActionDispatch::Integration instead. (called from <top (required)> at /Users/ppeak/projects/browsercms/features/support/env.rb:40)
  DEPRECATION WARNING: ActionController::IntegrationTest is deprecated and will be removed, use ActionDispatch::IntegrationTest instead. (called from <top (required)> at /Users/ppeak/projects/browsercms/features/support/env.rb:40)

  Background:

  Scenario: Upgrade Cucumber
    Given we are using a Rails 4.0 compatible version of cucumber




