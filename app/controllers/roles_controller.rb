class RolesController < BaseController
  load_and_authorize_resource :environment, :find_by => :path
  load_and_authorize_resource :course, :through => :environment, :find_by => :path
  load_and_authorize_resource :user, :through => :environment, :find_by => :login

  def index
    @courses = @user.user_course_associations.
      where(:course_id => @environment.courses).
      includes(:course => [{ :spaces => :user_space_associations }])
    @environment_membership = @user.user_environment_associations.
      where(:environment_id => @environment.id,:user_id => @user.id).first

    respond_to do |format|
      format.html do
        render :template => "roles/show"
      end
    end
  end

  def update
    role = Role.find(params[:role]).id

    if @course && @environment # mudando papel num curso especifico
      @course.change_role(@user, role) unless @user.environment_admin?(@course)
    else
      if role == Role[:environment_admin]
        @environment.courses.each { |c| c.join(@user) }
      end
      @environment.change_role @user, role
    end

    respond_to do |format|
      format.html { redirect_to environment_user_roles_path(@environment) }
      format.js { render(:update) { |page| page.reload } }
    end
  end

end
