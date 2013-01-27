class NdlStatAccept < ActiveRecord::Base
  belongs_to :ndl_statistic
  attr_accessible :donation, :production, :purchase, :region, :item_type
end
