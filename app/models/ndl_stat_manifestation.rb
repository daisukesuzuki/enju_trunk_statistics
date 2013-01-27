class NdlStatManifestation < ActiveRecord::Base
  belongs_to :ndl_statistic
  attr_accessible :current_term_end_count, :dec_count, :inc_count, :previous_term_end_count, :region, :item_type
end
