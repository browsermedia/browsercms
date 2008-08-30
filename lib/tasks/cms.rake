desc "Reset the DB, run the migrations, load the fixtures, run the specs"
task :reset => ["db:migrate:reset", "db:fixtures:load", "spec"]