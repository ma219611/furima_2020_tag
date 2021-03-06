class Tag < ApplicationRecord
    # validates :tag_name, presence: true, uniqueness: { case_sensitive: true }
    validates :tag_name, presence: true, uniqueness: true
    has_many :item_tag_relations
    has_many :items, through: :item_tag_relations
end
