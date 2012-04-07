['httparty', 'yaml', 'right_aws', 'sinatra/base', 'json'].each {|r| require r }
Dir["models/**/*.rb"].sort.each {|file| require_relative file if file.include?(".rb") }

class Web < Sinatra::Base

  get '/sqs' do
    erb :base
  end

  get '/status' do
    erb :gauges
  end

  get '/data/:env/status.json' do
    content_type :json
    status 200
    cloudkick_status_hash(params[:env]).to_json
  end

  get '/data/:env/sqs.json' do
    content_type :json
    status 200
    queue_data_hash(params[:env]||'prod').to_json
  end

  private

  def cloudkick_status_hash env
    CloudkickWrapper.new.updated_status_hash_for_all_nodes_of env
  end

  def queue_data_for env
    queues = Queue.new.list
    queues.select {|queue| queue.name.downcase.include?(env)}
  end

  def queue_data_hash env
    queue_data_for(env).inject({}) {|hash,queue| hash[queue.name] = queue.size; hash}
  end

end
