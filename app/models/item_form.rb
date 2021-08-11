class ItemForm
    include ActiveModel::Model

    ## ItemFormクラスのオブジェクトがitemモデルの属性を扱えるようにする
    attr_accessor(
                  :name, :info, :category_id, :sales_status_id,
                  :shipping_fee_status_id, :prefecture_id, :scheduled_delivery_id,
                  :price,
                  :image,
                  :user_id,
                  :id, :created_at, :datetime, :updated_at, :datetime,
                  :tag_name
                 )
                #  更新時にid~~~が必要
                # tag_nameも必要

    # <<バリデーション（item.rbの流用）>>
    # 値が入っているか検証
    with_options presence: true do
      validates :image
      validates :name
      validates :info
      validates :price
    end

    # 金額が半角であるか検証
    validates :price, numericality: { with: /\A[0-9]+\z/, message: 'is invalid. Input half-width characters' }

    # 金額の範囲
    validates :price, numericality: { greater_than_or_equal_to: 300, less_than_or_equal_to: 9999999, message: "is out of setting range"}

    # 選択関係で「---」のままになっていないか検証
    with_options numericality: { other_than: 0, message: "can't be blank" } do
      validates :category_id
      validates :sales_status_id
      validates :shipping_fee_status_id
      validates :prefecture_id
      validates :scheduled_delivery_id
    end

    def save
      item = Item.create(
        name: name,
        info: info,
        price: price,
        category_id: category_id,
        sales_status_id: sales_status_id,
        shipping_fee_status_id: shipping_fee_status_id,
        prefecture_id: prefecture_id,
        scheduled_delivery_id: scheduled_delivery_id,
        user_id: user_id,
        image: image)
      # itemだけを取り出して保存

      tag = Tag.where(tag_name: tag_name).first_or_initialize
      tag.save
      # tagだけを保存

      ItemTagRelation.create(item_id: item.id, tag_id: tag.id)
      #中間テーブルに保存
    end

    # def update(params, item)
    #   ## paramsからtag_nameを除外し、除外したものを変数tag_nameに入れる
    #   ## ※ハッシュ.delete(:キー)で、ハッシュの中から渡したキーとそのバリューが削除され、バリューが返される
    #   ## 結果的にparamsから:tag_nameのキーとバリューが削除され、tag_nameに削除されたバリューが入る
    #   tag_name = params.delete(:tag_name)

    #   ## tag_nameが空ではない場合はタグを作る。first_or_initializeで重複がないかを確認しておく。
    #   ## ※先にtagを定義しておかないとrescue内でtagが使えない
    #   tag = Tag.where(tag_name: tag_name).first_or_initialize if tag_name.present?

    #   ActiveRecord::Base.transaction do
    #     # タグの保存
    #     ## updateに!をつけると失敗したらrescueへ
    #     tag.save if tag_name.present?

    #     # itemの保存
    #     item.update!(params)

    #     ## itemから一旦タグを外す。
    #     item.item_tag_relations.destroy_all
    #     ## tag_nameがある場合はタグを付け直す。tag_nameがない場合はタグが0個になる
    #     ## ※タグがバリデーションに引っかかるとここでrescueへ行く
    #     item.tags << tag if tag_name.present?
    #     ## 成功であることを呼び出し元であるコントローラに伝えて終了
    #     return true
    #   end
    #   rescue => e
    #     ## なんらかのバリデーションに引っかかったとき、フォームオブジェクトへエラーメッセージを足していく
    #     binding.pry
    #     ## itemのnameとtagのnameでエラーメッセージのキーが重複するため、tagはtag_nameとしておく
    #     tag.errors.messages[:tag_name] = tag.errors.messages.delete(:name) if tag&.errors&.messages&.present?
    #     ## itemのエラーメッセージをitem_formオブジェクトのエラーメッセージに追加していく
    #     item&.errors&.messages&.each do |key, message|
    #       self.errors.add(key, message.first)
    #     end
    #     ## tagのエラーメッセージをitem_formオブジェクトのエラーメッセージに追加していく
    #     tag&.errors&.messages&.each do |key, message|
    #       self.errors.add(key, message.first)
    #     end
    #     ## 失敗したことを呼び出し元であるコントローラに伝えて終了
    #     return false
    # end

    def update(params, item)
      # paramsからタグ名を削除する
      tag_name = params.delete(:tag_name)
      tag = Tag.where(tag_name: tag_name).first_or_initialize if tag_name.present?

      item.item_tag_relations.destroy_all

      tag.save if tag_name.present?
      item.update(params)

      ItemTagRelation.create(item_id: item.id, tag_id: tag.id) if tag_name.present?
    end


end