# -*- encoding : utf-8 -*-
module StatusService
  module AnswerService
    class AnswerPresenter
      delegate :author_name, :author_avatar, :answer_text, :hierarchy_breadcrumbs,
        :original_author, :user, :place, :author, to: :notification

      def initialize(options={})
        @notification = options.delete(:notification)
        @template = options.delete(:template)
      end

      def author_link
        author = notification.author
        render_link(notification.author_name, template.user_url(author))
      end

      def answer_link
        text = "Clique aqui para ver a resposta."
        url = template.status_url(notification.answer)
        render_link(text, url, class: "status-link")
      end

      def action(&block)
        message = "participou da discussão #{place}"
        message = yield(message) if block_given?
        message
      end

      def subject
        action { |message| "#{author_name(short: true)} #{message}" }
      end

      def context(context_template, &block)
        original_template = @template
        @template = context_template
        begin
          yield(self) if block_given?
        ensure
          @template = original_template
        end
      end

      def template
        return @template if @template

        raise \
          "No template defined. You need to pass :template to new or use #context"
      end

      private

      attr_reader :notification

      def render_link(text, path, opts={}, &block)
        template.link_to(text, path, opts, &block)
      end

      def user_is_original_author?
        user == original_author
      end
    end
  end
end
