module Shared
class QuestionsController < ApplicationController
  include Shared::Closeables::Close
  include Shared::Deletables::Destroy
  include Shared::Editables::Update
  include Shared::Searchables::Search
  include Shared::Votables::Vote
  include Shared::Watchables::Watch

  include Shared::Events::Dispatch
  include Shared::Markdown::Process
  include Shared::Watchings::Register

  default_tab :recent,  only: :index
  default_tab :results, only: :search

  before_action :authenticate_user!

  def index
    if params[:category]
      @category = Shared::Category.find(params[:category])
      @context = @category.id
    end

    @questions = case params[:tab].to_sym
                 when :unanswered then Shared::Question.in_context(@context).unanswered.by_votes
                 when :answered   then Shared::Question.in_context(@context).answered.by_votes
                 when :solved     then Shared::Question.in_context(@context).solved.by_votes
                 when :favored    then Shared::Question.in_context(@context).favored.by_votes
                 else Shared::Question.in_context(@context).recent
                 end

    @questions = filter_questions(@questions)
    @questions = @questions.page(params[:page]).per(20)

    initialize_polling
  end

  def new
    @question = Shared::Question.new

    @question.document = University::Document.find(params[:document_id]) if params[:document_id]
    @question.category = Shared::Category.find(params[:category_id]) if params[:category_id]
    @question.category = nil if @question.category && @question.category.children.any?

    respond_to do |format|
      format.html { render :new }
      format.js { render template: "#{Rails.module.downcase}/questions/new" }
    end
  end

  def create
    @question = Shared::Question.new(create_params)

    authorize! :ask, @question

    if @question.save
      process_markdown_for @question do |user|
        dispatch_event :mention, @question, for: user
      end

      # TODO (zbell) refactor: do not compose watchers here
      dispatch_event :create, @question, for: @question.parent.watchers + @question.tags.map(&:watchers).flatten, anonymous: @question.anonymous
      register_watching_for @question

      flash[:notice] = t('question.create.success')

      @params = { unit_id: params[:question][:category_id], id: @question.id, page_url: params[:question][:page_url] }

      return render js: "window.location = '#{mooc.unit_question_url(@params)}'" if params[:question][:unit_view]
      redirect_to shared.question_path(@question)
    else
      # TODO (filip jandura) refactor different types of rendering for mooc/university
      respond_to do |format|
        format.html { render :new }
        format.js { render template: "#{Rails.module.downcase}/questions/new" }
      end
    end
  end

  def show
    @question = Shared::Question.find(params[:id])

    authorize! :view, @question

    @labels  = @question.labels
    @answers = @question.ordered_answers
    @answer  = Shared::Answer.new(question: @question)
    @view    = @question.views.create! viewer: current_user

    @question.increment :views_count

    dispatch_event :create, @view, for: @question.watchers
  end

  def favor
    @question = Shared::Question.find(params[:id])

    authorize! :favor, @question

    @favorite = @question.toggle_favoring_by! current_user

    @question.favorites.reload

    dispatch_event dispatch_event_action_for(@favorite), @favorite, for: @question.watchers
  end

  def suggest
    @questions = Shared::Question.in_context(@context).where('questions.id = ? or questions.title like ?', params[:q].to_i, "#{params[:q]}%")

    render json: @questions, root: false
  end

  private

  helper_method :filter_questions

  def initialize_polling
    unless params[:poll]
      session[:poll] = Rails.env_type.development? ? false : true if session[:poll].nil?

      return @poll = params[:poll] = session[:poll]
    end

    @poll = session[:poll] = params[:poll] == 'true' ? true : false
  end

  def filter_questions(relation)
    relation = relation.tagged_with(params[:tags]) if params[:tags].present?

    relation
  end

  def create_params
    params.require(:question).permit(:title, :text, :category_id, :document_id, :tag_list, :anonymous).merge(author: current_user)
  end

  def update_params
    params.require(:question).permit(:title, :text, :category_id, :tag_list)
  end

  protected

  def destroy_callback(deletable)
    # TODO (filip jandura) move logic to mooc module
    return redirect_to mooc.unit_path(id: @deletable.category.id, page_url: params[:page_url]) if params[:page_url]

    respond_to do |format|
      format.html { redirect_to shared.questions_path, format: :html }
      format.js   { redirect_to university.index_document_questions_path(@deletable.parent), format: :js }
    end
  end
end
end