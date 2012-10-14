require 'spec_helper'

describe ExerciseVisNotification do
  before do
    @exercise = Factory(:complete_exercise)
    @lecture = Factory(:lecture, :lectureable => @exercise)
    @user = Factory(:user)
    @exercise.start_for(@user)
  end

  context "-Result- after update" do

    context "when 'finalized' is set" do
      it "should send a 'exercise_finalized' notification" do
        result = nil
        WebMock.disable_net_connect!
        ActiveRecord::Observer.with_observers(:result_observer) do
          @stub = stub_request(:post,
                               Redu::Application.config.vis_client[:url]).
            with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                              'Content-Type'=>'application/json'}).
                              to_return(:status => 200, :body => "",
                                        :headers => {})


          result = @exercise.finalize_for(@user)
        end
        params = fill_params(@exercise, result)

        a_request(:post, Redu::Application.config.vis_client[:url]).
          with(:body => params,
               :headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                            'Content-Type'=>'application/json'}).should have_been_made
      end
    end

    context "when not finalized" do
      it "should not send any notification" do
        exercise2 = Factory(:complete_exercise)
        lecture2 = Factory(:lecture, :lectureable => exercise2)
        WebMock.disable_net_connect!
        ActiveRecord::Observer.with_observers(:result_observer) do
          @stub = stub_request(:post,
                               Redu::Application.config.vis_client[:url]).
                               with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                                                 'Content-Type'=>'application/json'}).
                                                 to_return(:status => 200, :body => "",
                                                           :headers => {})


          exercise2.start_for(@user)
        end

        a_request(:post, Redu::Application.config.vis_client[:url]).
          with(:headers => {'Authorization'=>['JOjLeRjcK', 'core-team'],
                            'Content-Type'=>'application/json'}).should_not have_been_made
      end
    end

  end

  def fill_params(exercise, result)
    space = exercise.lecture.subject.space
    params = {
      :lecture_id => exercise.lecture.id,
      :subject_id => exercise.lecture.subject.id,
      :space_id => space.id,
      :course_id => space.course.id,
      :user_id => result.user_id,
      :type => "exercise_finalized",
      :grade => result.grade.to_s,
      :status_id => nil,
      :statusable_id => nil,
      :statusable_type => nil,
      :in_response_to_id => nil,
      :in_response_to_type => nil,
      :created_at => result.created_at,
      :updated_at => result.updated_at
    }
  end
end


