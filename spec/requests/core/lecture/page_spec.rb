require 'request_spec_helper'

describe Page do
  let(:user) { Factory(:user) }
  let(:course) { Factory(:course, :plan => Factory(:plan)) }
  let(:space) { Factory(:space, :course => course) }
  let(:subj) { Factory(:subject, :space => space, :finalized => true) }

  before do
    course.join user, Role[:teacher]
    login_as(user)
  end

  context 'Creation', :js => true do
    before do
      visit edit_space_subject_path(space, subj)
      click_on 'Página de texto'
      sleep 2
    end

    context 'when not filling the form properly' do
      it 'show validation errors' do
        click_on 'Adicionar'

        page.should have_content 'não pode ser deixado em branco'
        page.should have_css 'ul.errors_on_field > li', :count => 2
      end
    end

    context 'when filling the form properly' do
      let(:lecture_name) { 'Conceitos básicos' }
      let(:lecture_body) do
        'Lorem ipsum dolor sit amet, consectetur adipisicing elit,' \
        ' sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
      end

      before do
        fill_in 'Título', :with => lecture_name
        within '#new_lecture' do
          evaluate_script  "CKEDITOR.instances[$('.editor').attr('id')]." \
            "setData('#{lecture_body}');"
        end
        click_on 'Adicionar'
      end

      it 'creates the lecture' do
        # Remove o formulário de criação da aula
        page.should have_no_css '#new_lecture'

        verify_item_created(Lecture.last, lecture_name)
        verify_page_show(Lecture.last, { :name => lecture_name,
                                         :body => lecture_body })
      end
    end
  end

  context 'Reuse existent lecture' do
    context 'when user does not have existent lectures', :js => true do
      before do
        visit edit_space_subject_path(space, subj)
        click_on 'Aula já existente'
        sleep 1
      end

      it 'should show error message.' do
        page.should have_content "Você não possui nenhuma aula. Crie uma nova!"
      end
    end

    context 'when user does have existent lectures', :js => true do
      before do
        @my_lectures = 2.times.collect do
          Factory(:lecture, :subject => subj, :owner => user)
        end
        2.times do
          @my_lectures << Factory(:lecture,
                                  :subject => Factory(:subject),
                                  :owner => user)
        end

        visit edit_space_subject_path(space, subj)
        page.execute_script "window.scrollBy(0,10000)"
        click_on 'Aula já existente'
      end

      it 'should list lectures created by user and accept their reuse' do
        @my_lectures.each do |lecture|
          within '.existent-lectures' do
            page.should have_content lecture.name
          end
        end

        chosen_lecture = @my_lectures.last
        select chosen_lecture.name, :from => 'lecture_id'
        click_on 'Adicionar'

        within '#lectures_index' do
          page.should have_content chosen_lecture.name
        end

        click_on 'Finalizar módulo'
        sleep 3
        page.find('.expand').click
        page.should have_content chosen_lecture.name
      end
    end
  end

  context 'Edition', :js => true do
    let(:lecture) do
      Factory(:lecture, :subject => subj)
    end
    let(:lecture_name) { 'Conceitos introdutórios' }
    let(:lecture_body) { 'Conteúdo modificado.' }

    before do
      lecture.reload
      visit edit_space_subject_path(space, subj)

      within '#resources_list' do
        click_on 'Editar'
        sleep 1
      end

      within '#resources-edition' do
        fill_in 'Título', :with => lecture_name
        evaluate_script "CKEDITOR.instances[$('.editor').attr('id')]." \
          "setData('#{lecture_body}');"

        # Para evitar que o teste falhe por causa da imagem do typekit
        evaluate_script "window.scrollBy(0,500)"
        click_on 'Salvar'
      end
    end

    it 'successfuly edit name and content' do
      # Remove o formulário de criação da aula
      page.should have_no_css '#new_lecture'

      verify_item_created(Lecture.last, lecture_name)
      verify_page_show(Lecture.last, { :name => lecture_name,
                                       :body => lecture_body })
    end
  end

  private
  # Visualiza a página e verifica se o conteúdo foi salvo
  def verify_page_show(lecture, attrs)
    visit space_subject_lecture_path(space, subj, lecture)
    page.should have_content attrs[:name]
    within_frame 'page-iframe' do
      page.should have_content attrs[:body]
    end
  end
end