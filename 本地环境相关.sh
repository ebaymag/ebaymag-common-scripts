# 1.更新schema.json文件
yarn typings:update
yarn start:app

#8 执行yarn linters
yarn run lint:js --format junit -o /tmp/test-results/lint_js.xml
yarn eslint webpack

#2 执行yarn flow
yarn flow check --max-workers 2

#3 yarn test
yarn run test --maxWorkers=4 --ci --testResultsProcessor="jest-junit"

#4.当启动报了You have already activated json 2.6.3, but your Gemfile requires json 2.3.1. 错误
gem uninstall json -v 2.6.3

#5.查看rubocop情况
bundle exec rubocop

#6.字段更新
# 如果想在表里新增一个字段，需要新建一个数据库，然后运行 rails db:migrate
rails db:migrate
rails db:seed

#7. 更新ebay_api
bundle update ebay_api
bundle update ebay_request

#8. 安装helm
brew install helm

#9. rspec
bundle exec dotenv -f .circleci/.env \
rspec --format RspecJunitFormatter --out /tmp/test-results/rspec.xml \
      --format progress \
      $(circleci tests glob "spec/**/*_spec.rb" | circleci tests split --split-by=timings)