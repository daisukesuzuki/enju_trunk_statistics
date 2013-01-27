class NdlStatCheckout < ActiveRecord::Base
  belongs_to :ndl_statistic
  attr_accessible :item, :item_type, :user
end
