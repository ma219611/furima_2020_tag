class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  # <<アクティブハッシュの設定関連>>
  belongs_to_active_hash :category
  belongs_to_active_hash :sales_status
  belongs_to_active_hash :shipping_fee_status
  belongs_to_active_hash :prefecture
  belongs_to_active_hash :scheduled_delivery

  # <<アクティブストレージの設定関連>>
  has_one_attached :image

  # <<アソシエーション>>
  belongs_to :user
  has_one :order
  has_many :item_tag_relations, dependent: :destroy
  has_many :tags, through: :item_tag_relations
end
