json.array!(@downloaders) do |downloader|
  json.partial! 'downloaders/downloader', downloader: downloader

  json.path downloader_path( downloader, format: :json )
  # json.url downloader_url( downloader, format: :json )
end
