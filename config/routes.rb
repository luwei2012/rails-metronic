Rails.application.routes.draw do

  resources :order_manager do
    get :order_notifications, :on => :collection
    get :score_notifications, :on => :collection
    get :close, :on => :collection
    get :consume, :on => :collection
    get :confirm, :on => :collection
  end

  # resources :roles do
  #   get :authority, :on => :collection
  #   post :authority_update, :on => :collection
  #   get :authority_edit, :on => :collection
  # end

  resources :comments do
    get :close, :on => :collection
    get :confirm, :on => :collection
    get :consume, :on => :collection
    get :comment_notifications, :on => :collection
  end

  resources :discount_manager do
    get :remove, :on => :collection
    post :validate, :on => :collection
  end

  post 'discount_manager/update' => 'discount_manager#update'

  resources :discounts

  resources :discount_types do
    get :discount_type_list, :on => :collection
    get :show_upload_div, :on => :collection
    post :discount_type_name, :on => :collection
  end

  resources :brands do
    get :brand_shop_list, :on => :collection
    post :brand_name, :on => :collection
    get :show_upload_div, :on => :collection
  end


  resources :shops do
    get :show_upload_div, :on => :collection
    get :authority, :on => :collection
    post :authority_update, :on => :collection
    post :email, :on => :collection
    post :shop_name, :on => :collection
    get :authority_edit, :on => :collection
  end

  resources :users

  resources :shop_manager do
    get :show_upload_div, :on => :collection
  end

  resources :time_manager do
    get :modify, :on => :collection
    post :modify_update, :on => :collection
    get :book_record, :on => :collection
  end


  resources :documents do
    post :image_upload, :on => :collection
    post :validate, :on => :collection
  end

  root 'login#index'

  post 'login' => 'login#login'

  get 'login' => 'login#index'

  post 'login' => 'login#create'

  get 'logout' => 'login#logout'

  post 'reset' => 'login#reset'

  get 'password_modify' => 'login#password_modify'

  get 'modify' => 'login#modify'

  post 'update_password' => 'login#update_password'

  post 'modify_update' => 'login#modify_update'

  #手机端接口
  namespace :mobile do
    post 'register' => 'login#register' # 注册
    post 'login' => 'login#index' # 登陆
    post 'information' => 'operation#information' # 登陆
    post 'modify_password' => 'operation#modify_password' # 修改密码
    post 'forget_password' => 'operation#forget_password' # 忘记密码
    post 'shake' => 'shake#shake' # 摇一摇
    post 'shake_discount' => 'shake#shake_discount' # 摇一摇详情
    post 'order' => 'order#order' # 下订单
    post 'car_wash_order' => 'order#car_wash_order' #
    post 'my_orders' => 'order#my_orders' #查看订单信息
    post 'order_detail' => 'order#order_detail' #查看订单信息
    post 'cancel' => 'order#cancel' #cancel订单信息
    post 'comment' => 'order#comment' #comment订单信息
    post 'feedBack' => 'operation#feedBack' #feedBack
    post 'brand' => 'brand#brand' # 品牌服务页面
    post 'brands' => 'brand#brands' # 品牌服务页面-点击品牌
    post 'shop_discounts' => 'brand#shop_discounts' # 品牌服务页面 店铺服务信息列表
    post 'brand_shops' => 'brand#brand_shops' # 品牌-商店列表，点击品牌后需要展示商店列表
    post 'discounts' => 'car_wash#discounts' # 我要洗车页面 店铺服务信息列表
    post 'map_discounts' => 'car_wash#map_discounts' # 我要洗车页面 店铺服务信息列表
    post 'discount' => 'brand#discount' # 查看服务信息详情
    post 'car_wash_discount' => 'car_wash#discount' # 查看服务信息详情
    post 'follow_shop' => 'collect#follow_shop' # 收藏店铺
    post 'follow_discount' => 'collect#follow_discount' # 收藏服务
    post 'follow_brand' => 'collect#follow_brand' # 收藏品牌
    post 'praise_discount' => 'collect#praise_discount' # 赞
    post 'user_fav_discounts' => 'collect#user_fav_discounts' # 收藏的服务信息
    post 'user_fav_shops' => 'collect#user_fav_shops' # 收藏的店铺信息
    post 'complete' => 'operation#complete' # 完善个人信息
    post 'recommend_discounts' => 'brand#recommend_discounts' # 品牌服务页面 用户收藏列表
    post 'discount_types' => 'brand#discount_types' # 获取服务信息类型
    post 'discount_types_sons' => 'brand#discount_types_sons' # 获取服务信息类型子类型
    post 'discount_types_discounts' => 'brand#discount_types_discounts' # 获取某些服务类型的服务信息

  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
