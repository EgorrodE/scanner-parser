class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  TIME_ERROR           = 2.minutes
  CHECK_INTERVAL       = 10.minutes
end
