class ForumsController < BaseController
  layout 'environment'

  load_and_authorize_resource :space
  load_and_authorize_resource :forum, :through => :space

  before_filter :load_course_and_environment

  helper :application

  def show
    @forum = @space.forum
    respond_to do |format|
      # keep track of when we last viewed this forum for activity indicators
      (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?

      @topics = @forum.topics.includes(:replied_by_user).
                  paginate(:page => params[:page],
                           :order => 'locked DESC, replied_at DESC',
                           :per_page => 20)
      format.html
      format.xml do
        render :xml => @forum.to_xml
      end
      format.js
    end
  end

  # new renders new.rhtml

  def create
    @forum.attributes = params[:forum]
    @forum.tag_list = params[:tag_list] || ''
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head :created, :location => forum_url(:id => @forum, :format => :xml) }
    end
  end

  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end

  protected
  def load_course_and_environment
    @course = @space.course
    @environment = @course.environment
  end
end
