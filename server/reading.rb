require 'supermodel'

class Reading < SuperModel::Base
  include SuperModel::RandomID
  attributes :timestamp, :value, :meter_id
end
