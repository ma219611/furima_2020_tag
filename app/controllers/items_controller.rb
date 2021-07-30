class ItemsController < ApplicationController
  before_action :select_item, only: [:show, :edit, :update, :destroy]
  before_action :set_item_form, only: [:edit, :update]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :redirect_to_show, only: [:edit, :update, :destroy]

  def index
    @items = Item.all.order(created_at: :desc)
  end

  def new
    # @item = Item.new
    @item_form = ItemForm.new
  end

  def create
    # @item = Item.new(item_params)
    @item_form = ItemForm.new(item_form_params)
    # バリデーションで問題があれば、保存はされず「商品出品画面」を再描画
    # if @item.save
    if @item_form.valid?
      @item_form.save
      return redirect_to root_path
    else
      # アクションのnewをコールすると、エラーメッセージが入った@itemが上書きされてしまうので注意
      render 'new'
    end
  end

  def show
  end

  def edit
    @item_form.tag_name = @item.tags.first&.tag_name
    return redirect_to root_path if @item.order != nil
  end

  def update
    @item_form = ItemForm.new(item_form_params)
    if @item_form.valid?
      @item_form.update(item_form_params, @item)
      # item_form_paramsに情報を受け取ってる、@itemは更新対象
      return redirect_to item_path(@item)
    else
      render 'edit'
    end
  end

  # 古木戸さんのやつ
  # def update
  #   @item_form = ItemForm.new(item_form_params)
  #   if @item_form.update(item_form_params, @item)
  #     return redirect_to item_path(@item.id)
  #   else
  #     render :edit
  #   end
  # end

  def destroy
    if @item.destroy
      return redirect_to root_path
    else
      render 'show'
    end
  end

  private

  def item_form_params
    # :itemから:item_formに変更
    params.require(:item_form).permit(
      :name,
      :info,
      :category_id,
      :sales_status_id,
      :shipping_fee_status_id,
      :prefecture_id,
      :scheduled_delivery_id,
      :price,
      :tag_name,
      # 必ずimageは最後に書く
      :image
    ).merge(user_id: current_user.id)
  end

  def select_item
    @item = Item.find(params[:id])
  end

  def set_item_form
    item_attributes = @item.attributes
    @item_form = ItemForm.new(item_attributes)
  end

  def redirect_to_show
    return redirect_to root_path if current_user.id != @item.user.id
  end
end
