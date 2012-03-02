module Api
  class DashboardController < ApiController
    # Requisição default pega o primeiro professor da lista do curso
    def teacher_participation
      # params [:id_course]
      @course = Course.find(params[:id_course])
      @teachers = @course.teachers

      # only if there is teachers
      if @teachers.empty?
        self.generate_erro("Não existem professores neste curso")
      else
        @uca = @teachers.first.get_association_with(@course)
        @participation = TeacherParticipation.new(@uca)
        self.generate_json
      end
    end

    # Interação do usuário
    def teacher_participation_interaction
      @start = params[:time_start].to_date
      @end = params[:time_end].to_date

      if @start > @end
        self.generate_erro("Intervalo de tempo inválido")
      else
        # params [:id_teacher]
        @course = Course.find(params[:id_course])
        @teacher = @course.teachers.find(params[:id_teacher])
        @uca = @teacher.get_association_with(@course)
        @participation = TeacherParticipation.new(@uca)

        # params [:time_start, :time_end] => time (format): "year-month-day"
        @participation.start = params[:time_start].to_date
        @participation.end = params[:time_end].to_date

        # params [:spaces[id's]]
        @spaces = params[:spaces].join(',').split(',')
        @participation.spaces = @uca.course.spaces.find(@spaces)

        self.generate_json
      end
    end

    protected

    def generate_erro(msg)
      @erro = Erro.new(msg)
      respond_to do |format|
        format.json { render :json => @erro.extend(ErroRepresenter)}
        format.any { raise ActionController::RoutingError.new('Not Found') }
      end
    end

    def generate_json
      @participation.generate!
      @participation.extend(TeacherParticipationRepresenter)

      respond_to do |format|
        format.json { render :json => @participation }
        format.any { raise ActionController::RoutingError.new('Not Found') }
      end
    end
  end
end
