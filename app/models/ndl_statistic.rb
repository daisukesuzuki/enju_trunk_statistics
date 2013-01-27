# -*- encoding: utf-8 -*-
class NdlStatistic < ActiveRecord::Base
  has_many :ndl_stat_manifestations, :dependent => :destroy
  has_many :ndl_stat_accepts, :dependent => :destroy
  has_many :ndl_stat_checkouts, :dependent => :destroy
  has_many :ndl_stat_jma_publications, :dependent => :destroy
  attr_accessible :term_id
  
  validates_presence_of :term_id
  
  def calc_all
    @prev_term_end = Term.where(:id => term_id).first.start_at.yesterday
    @curr_term_end = Term.where(:id => term_id).first.end_at
    self.calc_manifestation_counts
    self.calc_accept_counts
    self.calc_checkout_counts
    self.aggregate_jma_publications
  end
  
  def calc_manifestation_counts
    NdlStatistic.transaction do
      p "ndl_statistics of manifestation_counts"
      # 書籍、逐次刊行物
      [ "book", "magazine" ].each do |type|
        book_type = (type == 'book') ? ['%book', '%monograph'] : ['%magazine', '%serial_book']
        items_all = Item.
          includes(:manifestation => [:manifestation_type, :carrier_type]).
          where("manifestation_types.name like ? OR
                 manifestation_types.name like ?", book_type[0], book_type[1]).
          where("carrier_types.name = 'print'").
          where("bookbinder_id IS NULL OR items.bookbinder IS TRUE")
	# 国内, 国外
        [ "domestic", "foreign" ].each do |region|
	  manifestation_type = (region == "domestic") ? 'japanese%' : 'foreign%'
	  items = items_all.
	    where("manifestation_types.name like ?", manifestation_type)
	  # 前年度末現在数
	  prev = items.includes(:circulation_status).
                   where("circulation_statuses.name not in ('Removed', 'Lost', 'Missing')").
	           where("items.created_at < ?", @prev_term_end).count
	  # 本年度増加数
	  inc = items.includes(:circulation_status).
                   where("circulation_statuses.name != 'Missing'").
                   where("items.created_at between ? and ?",
                         @prev_term_end, @curr_term_end).count
	  # 本年度減少数
	  dec = items.includes(:circulation_status).
                   where("circulation_statuses.name in ('Removed', 'Lost')").
                   where("items.removed_at between ? and ?",
                         @prev_term_end, @curr_term_end).count
	  # 本年度末現在数
	  curr = items.includes(:circulation_status).
                   where("circulation_statuses.name not in ('Removed', 'Lost', 'Missing')").
	           where("items.created_at < ?", @curr_term_end).count
	  # サブクラス生成
          ndl_stat_manifestations.create(
            :item_type => type,
	    :region => region,
	    :previous_term_end_count => prev,
	    :inc_count => inc,
	    :dec_count => dec,
	    :current_term_end_count => curr
          )
	end
      end
      # その他
      [ "other_micro", "other_av", "other_file" ].each do |type|
        case type
	when "other_micro"
          items = Item.
            includes(:manifestation => :carrier_type).
            where("carrier_types.name = 'micro'").
            where("bookbinder_id IS NULL OR items.bookbinder IS TRUE")
	when "other_av"
          items = Item.
            includes(:manifestation => :carrier_type).
            where("carrier_types.name in ('CD','DVD','AV')").
            where("bookbinder_id IS NULL OR items.bookbinder IS TRUE")
	when "other_file"
          items = Item.
            includes(:manifestation => :carrier_type).
            where("carrier_types.name = 'file'").
            where("bookbinder_id IS NULL OR items.bookbinder IS TRUE")
	end
        region = "na"
        # 前年度末現在数
	prev = items.includes(:circulation_status).
                 where("circulation_statuses.name not in ('Removed', 'Lost', 'Missing')").
	         where("items.created_at < ?", @prev_term_end).count
	# 本年度増加数
	inc = items.includes(:circulation_status).
                 where("circulation_statuses.name != 'Missing'").
                 where("items.created_at between ? and ?",
                       @prev_term_end, @curr_term_end).count
	# 本年度減少数
	dec = items.includes(:circulation_status).
                 where("circulation_statuses.name in ('Removed', 'Lost')").
                 where("items.removed_at between ? and ?",
                       @prev_term_end, @curr_term_end).count
	# 本年度末現在数
	curr = items.includes(:circulation_status).
                 where("circulation_statuses.name not in ('Removed', 'Lost', 'Missing')").
	         where("items.created_at < ?", @curr_term_end).count
	# サブクラス生成
        ndl_stat_manifestations.create(
          :item_type => type,
	  :region => region,
	  :previous_term_end_count => prev,
	  :inc_count => inc,
	  :dec_count => dec,
	  :current_term_end_count => curr
        )
      end
    end
  end

  def calc_accept_counts
    NdlStatistic.transaction do
      p "ndl_statistics of accept_counts"
      [ "book", "magazine", "other" ].each do |type|
        [ "domestic", "foreign" ].each do |region|
	  purchase = 100
	  donation = 50
	  production = 10
          ndl_stat_accepts.create(
            :item_type => type,
	    :region => region,
	    :purchase => purchase,
	    :donation => donation,
	    :production => production
          )
	end
      end
    end
  end

  def calc_checkout_counts
    NdlStatistic.transaction do
      p "ndl_statistics of checkout_counts"
      [ "book", "magazine", "other" ].each do |type|
	user = 1000
	item = 2000
        ndl_stat_checkouts.create(
          :item_type => type,
	  :user => user,
	  :item => item
        )
      end
    end
  end

  def aggregate_jma_publications
    NdlStatistic.transaction do
      p "ndl_statistics of jma_publications"
      [ ["foo", "1-1-1"], ["bar", "1-2-3"] ].each do |original_title, number_string|
        ndl_stat_jma_publications.create(
	  :original_title => original_title,
	  :number_string => number_string
        )
      end
    end
  end

end
