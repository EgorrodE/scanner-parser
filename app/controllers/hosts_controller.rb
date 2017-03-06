class HostsController < ApplicationController
  before_action :set_params, only: :show

  def index
    @hosts = Host.all
  end

  def show
    @host = Host.find(params[:id])
    @date_from = params[:q][:date_from]
    @date_to   = params[:q][:date_to]
    @presence_bounds = @host.presence_bounds(@date_from, @date_to)
  end

  private
  def set_params
    params[:q] ||= { 
      "date_from" => DateTime.now.beginning_of_month - 1.month, 
      "date_to" => DateTime.now.end_of_month
    }
    params[:q][:date_from] ||= DateTime.now.beginning_of_month - 1.month
    params[:q][:date_to] ||= DateTime.now.end_of_month
  end
end
