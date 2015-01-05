class MessageController < WebsocketRails::BaseController
  before_filter :check_login
  def initialize_session
    # perform application setup here
    controller_store[:message_count] = 0
  end

  def client_connected
    new_message = {:message => 'this is a message'}
    send_message :client_connected, new_message
  end

  def new_message
    new_message = {:message => 'this is a message'}
    send_message :new_message, new_message
  end

  def log_message
    new_message = {:message => 'this is a message'}
    send_message :log_message, new_message
  end

  def new_user
    new_message = {:message => 'this is a message'}
    send_message :new_user, new_message
  end

  def change_username
    new_message = {:message => 'this is a message'}
    send_message :change_username, new_message
  end

  def new_product
    new_message = {:message => 'this is a message'}
    send_message :new_product, new_message
  end

  def delete_user
    new_message = {:message => 'this is a message'}
    send_message :delete_user, new_message
  end

end
