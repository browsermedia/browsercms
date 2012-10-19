# Some CLI scenarios run bundler, which can take a while.
Before('@long-scenario') do
  @aruba_timeout_seconds = 60
end