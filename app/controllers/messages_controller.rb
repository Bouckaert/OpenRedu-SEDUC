class MessagesController < BaseController

  load_and_authorize_resource :user, :find_by => :login

  def index
    authorize! :manage, @user
      @messages = @user.received_messages.paginate(:page => params[:page],
                                                   :order =>  'created_at DESC',
                                                   :per_page => Redu::Application.config.items_per_page )
      respond_to do |format|
        format.html
        format.js do
          render_endless 'messages/item', @messages, '#messages > tbody',
            { :mailbox => :inbox }
        end
      end
  end

  def index_sent
    authorize! :manage, @user
    @messages = @user.sent_messages.paginate(:page => params[:page],
                                             :order =>  'created_at DESC',
                                             :per_page => Redu::Application.config.items_per_page)
    respond_to do |format|
        format.html
        format.js do
          render_endless 'messages/item', @messages, '#messages > tbody',
            { :mailbox => :outbox }
        end
    end
  end

  def show
    authorize! :manage, @user
    @message = Message.read(params[:id], current_user)
    @reply = Message.new_reply(@user, @message, params)

    respond_to do |format|
      format.html
    end
  end

  def new
    authorize! :manage, @user
    if params[:reply_to]
      in_reply_to = Message.find_by_id(params[:reply_to])
    end
    @message = Message.new_reply(@user, in_reply_to, params)
    if params[:message_to] and params[:message_to].length > 0
      @recipients = @user.friends.message_recipients(params[:message_to])
    end

    respond_to do |format|
      format.html
    end
  end

  def create  #TODO verificar se está enviando uma mensagem para um amigo mesmo ou se ta tentando colocar o id de outra pessoa?
    authorize! :manage, @user
    messages = []

    if params[:message][:reply_to] # resposta
      @message = Message.new(params[:message])
      @message.save!
      flash[:notice] = "Mensagem enviada!"
      respond_to do |format|
        format.html do
          redirect_to index_sent_user_messages_path(@user) and return
        end
      end
    end

    if not params[:message_to] or  params[:message_to].empty?
      @message = Message.new(params[:message])
      @message.valid?
      respond_to do |format|
        format.html do
          render :template => 'messages/new' and return
        end
      end
    end


    # If 'to' field isn't empty then make sure each recipient is valid
    params[:message_to].each do |to|
      @message = Message.new(params[:message])
      @message.recipient_id = to# User.find(to)
      @message.sender = @user
      unless @message.valid?
        @recipients = @user.friends.message_recipients(params[:message_to])
        respond_to do |format|
          format.html do
            render :template => 'messages/new' and return
          end
        end
        return
      else
        messages << @message
      end
    end

    # If all messages are valid then send messages
    messages.each {|msg| msg.save!}
    flash[:notice] = t :message_sent
    respond_to do |format|
      format.html do
        redirect_to index_sent_user_messages_path(@user) and return
      end
    end
  end

  def delete_selected
    authorize! :manage, @user

    @message = Message.where(:id => params[:delete])
    @message.each {|m| m.mark_deleted(@user) }
    flash[:notice] = t :messages_deleted

    if params[:mailbox] == 'inbox'
      redirect_to user_messages_path(@user)
    elsif params[:mailbox] == 'outbox'
      redirect_to index_sent_user_messages_path(@user)
    end
  end
end
