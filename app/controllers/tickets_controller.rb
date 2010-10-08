class TicketsController < ApplicationController
  before_filter :get_project

  def index
    @tickets = Ticket.all(@project)
  end

  def show
    @ticket = Ticket.find({:project => @project, :id => params[:id]})
  end

  def new
    @ticket = Ticket.new @project, '', '', '', '', ''
  end


  def create
    ticket = Ticket.new @project, params[:name], '', '', '', params[:content]

    message = params[:commit_message]
    if message.empty?
      message = 'Add ticket: ' + params[:name]
    end

    ticket.save! message

    redirect_to ticket_url :id => ticket.id
  end

  def edit
    @ticket = Ticket.find({:project => @project, :id => params[:id]})
  end

  def update
    ticket = Ticket.find({:project => @project, :id => params[:id]})

    message = params[:commit_message]
    if message.empty?
      message = 'Update ticket: ' + ticket.id
    end

    ticket.contents = params[:content]

    ticket.save! message

    redirect_to ticket_url :id => ticket.id
  end

  def destroy
    ticket = Ticket.find({:project => @project, :id => params[:id]})

    message = params[:commit_message].to_s
    if message.empty?
      message = 'Delete ticket: ' + ticket.id
    end

    ticket.destroy! message

    redirect_to tickets_url
  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end
end

