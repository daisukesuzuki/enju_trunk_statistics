class NdlStatJmaPublication < ActiveRecord::Base
  belongs_to :ndl_statistic
  attr_accessible :original_title, :number_string
end
