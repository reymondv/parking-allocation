class EntryPointController < ApplicationController

  def index
  end

  def entry_points
    @entry_points = EntryPoint.all_entry_points
    
    respond_to do |format|
      format.html 
      format.json { render json: @entry_points }
    end
  end
end