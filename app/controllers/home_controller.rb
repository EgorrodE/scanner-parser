class HomeController < ApplicationController
  def index
    @path = '~'
  end

  def upload_data
    @path = File.expand_path(path_params[:path])

    @error = 'Not found' unless File.exists? @path
    @error = 'Not a directory' unless File.directory? @path

    if @error
      render template: 'home/index'
      return
    end

    @arp_response = ArpRecord.upload_data(@path)
    @nmap_response = NmapRecord.upload_data(@path)

    render template: 'home/index'
  end

  private

  def path_params
    params.require(:path).permit(:path)
  end
end
