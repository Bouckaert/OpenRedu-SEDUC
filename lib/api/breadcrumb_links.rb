module Api
  module BreadcrumbLinks
    # Provê links para possibilitar a criação de breadcrumbs
    # - Depende do statusable associado
    extend ActiveSupport::Concern

    included do
      %w(environment course space subject lecture).each do |attr|
        link attr.to_sym do
          assign_vars
          instance = self.send(attr)

          if instance
            { :name => instance.name,
              :href => polymorphic_url([:api, instance]),
              :permalink => self.entity_permalink(instance) }
          end
        end
      end

      # O attributo passa a ser wall, pois "user" é o criador do status
      link :wall do
        if self.statusable.is_a? User
          { :name => self.statusable.display_name,
            :href => polymorphic_url([:api, self.statusable]),
            :permalink => user_url(self.statusable) }
        end
      end
    end

    protected

    attr_reader :environment, :course, :space, :subject, :lecture

    # Atribui as variáveis necessárias aos breadcrumbs de acordo com
    # o statusable
    def assign_vars
      case self.statusable.class.to_s
      when "Space"
        @space ||= self.statusable
        @course ||= space.course
        @environment ||= course.environment
      when "Lecture"
        @lecture ||= self.statusable
        @subject ||= lecture.subject
        @space ||= subject.space
        @course ||= space.course
        @environment ||= course.environment
      end
    end

    # Retorna a url de acordo com a entidade
    def entity_permalink(entity)
      case entity.class.to_s
      when "Environment"
        environment_url(entity)
      when "Course"
        environment_course_url(entity.environment, entity)
      when "Space"
        space_url(entity)
      when "Subject"
        space_subject_url(entity.space, entity)
      when "Lecture"
        space_subject_lecture_url(entity.subject.space, entity.subject, entity)
      end
    end
  end
end
