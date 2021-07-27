class ItemsTag
    include ActiveModel::Model
    attr_accessor :tag_name, :name, :image, :info, :price, :category_id, :sales_status_id, :shipping_fee_status_id, :prefecture_id, :scheduled_delivery_id, :user_id

    with_options presence: true do
      validates :tag_name
      validates :image
      validates :name
      validates :info
      validates :price
    end

    def save
      item = Item.create(name: name, image: image, info: info, category_id: category_id, sales_status_id: sales_status_id, shipping_fee_status_id: shipping_fee_status_id, prefecture_id: prefecture_id, scheduled_delivery_id: scheduled_delivery_id, price: price, user_id: user_id)

      binding.pry
      tag = Tag.where(tag_name: tag_name).first_or_initialize
      binding.pry
      tag.save

      ItemTagRelation.create(item_id: item.id, tag_id: tag.id)
    end

end