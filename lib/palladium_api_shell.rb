require_relative 'api'
require 'colorize'
class PalladiumApiShell

  attr_accessor :add_all_suites, :ignore_parameters, :suites_to_add, :search_plan_by_substring, :in_debug

  # Main class fo working with palladium
  # Need to authorization for use. #params must contains :host, :login and :token for it.
  # :host - is a palladium address, like 'palladium.com'
  # :login - is a email for singin, like 'palladium@gmail.com'
  # :token - is secret key for api. You can take in in palladium settings.
  # Use secure method authorization: create hide folder and 3 files in it: not_host, not_login and not_token.
  # Write login in not_login file, host in not_host file and token in not_token file. Path to folder take from argument :path, like '/.palladium'
  # Hackers cant rob you then.
  # #params must contains :product_name, :plan_name and :run_name for write result
  # use param debug: true if you want to see all logs in terminal
  def initialize(params)
    if !params[:path].nil?
      get_params_from_folder params[:path]
    elsif !((params[:host] || params[:login] || params[:token]).nil?)
      @host, @login, @token  = params[:host], params[:login], params[:token]
    else
      raise("Cant find login, host and token files and arguments. See params: host = #{params[:host]}, login = #{params[:login]}, token = #{params[:token]}, @path = #{params[:path]}")
    end
    @debug = params[:debug] unless params[:debug].nil?
    init_api_obj(params[:host], params[:login], params[:token])
    @product = get_product_data_by_name(params[:product_name])
    @plan = get_products_plan_by_name(params[:plan_name])
    if @plan.nil?
      print_to_log 'Try to create new plan because plan is nil'
      @plan = create_new_plan(params[:plan_name], '0', @product.keys.first)
    end
    @run = get_plans_run_by_name(params[:run_name])
    if @run.nil?
      @run = create_new_run(params[:run_name], '0', @plan.keys.first)
    end
  end

  def init_api_obj(host, login, token)
    @api = Api.new(host, login, token)
    print_to_log 'Init @api obj'
  end

  def create_new_plan(plan_name, version, product_id)
    plan = @api.add_new_plan({:plan => {:name => plan_name, :version => "#{version}"}, :product_id => product_id})
    print_to_log "Create new plan: #{plan}"
    JSON.parse(plan)
  end

  def create_new_run(run_name, version, plan_id)
    run = @api.add_new_run({:run => {:name => run_name, :version => version}, :plan_id => plan_id})
    print_to_log "Create new run: #{run}"
    JSON.parse(run)
  end

  def get_params_from_folder(path)
    if File.exist?("#{path}/not_host") && File.exist?("#{path}/not_login") && File.exist?("#{path}/not_token")
      @host = File.read("#{path}/not_host").delete("\n")
      @login = File.read("#{path}/not_token")
      @token = File.read(Dir.home + '/.testrail/not_token').delete("\n")
    elsif File.exist?("#{path}/host") && File.exist?("#{path}/login") && File.exist?("#{path}/token")
      puts 'Attention!! You use not secure method!! Rename secret files with "not_" prefix'
      @host = File.read("#{path}/host").delete("\n")
      @login = File.read("#{path}/login").delete("\n")
      @token = File.read("#{path}/token").delete("\n")
    end
  end

  def add_plan_to_product(product_name, plan_name)
    product_data = @api.get_products_by_param({name: product_name})
    product_id = JSON.parse(product_data).keys.first
    plan_data = @api.add_new_plan({:plan => {:name => plan_name,
                                 :version => '0'},
                       :product_id => product_id})
    run_data = @api.add_new_run({:run => {:name => JSON.parse(plan_data)['name'],
                                          :version => '0.0.0.0'},
                                 :plan_id => JSON.parse(plan_data)['id']})
    {run_data:JSON.parse(run_data)['id']}
  end

  def add_new_status_if_its_not_found(result)
    status_id = nil
    JSON.parse(@api.get_all_statuses).each do | key, value |
      status_id = key if value['name'] == result
    end
    status_id = @api.add_new_status({:status => {:name => "#{result}", :color => "#FFFFFF"}}) if status_id.nil?
    JSON.parse(status_id)['id']
  end

  def add_result(result_set_description, result, comment)
    status_id = add_new_status_if_its_not_found(result)
    status_id = JSON.parse(status_id)['id']
    @result_set = get_runs_result_set_by_name(result_set_description)
    if @result_set.nil?
      @result_set = @api.add_new_result_set({:result_set => {:name => result_set_description,
                                                             :version => '0.0.0',
                                                             :date => Time.now},
                                             :status_id => status_id,
                                             :run_id => @run.keys.first})
      @result_set = JSON.parse(@result_set)
    end
    response = @api.add_new_result({:result => {:message => comment,
                                                :author => 'API'},
                                    :result_set_id => @result_set.keys.first,
                                    :status_id => status_id})
    raise("Status with id #{status_id} is not found. Create it or make active") unless JSON.parse(response)['status_id'].to_s == status_id
    @last_case = example.description
    if @api.uri.port.nil?
      "#{@api.uri.scheme}://#{@api.uri.host}/result_sets/#{JSON.parse(response)['result_set_id']}/results"
    else
      "#{@api.uri.scheme}://#{@api.uri.host}:#{@api.uri.port}/result_sets/#{JSON.parse(response)['result_set_id']}/results"
    end
  end

  def get_product_data_by_name(product_name)
    product_data = @api.get_products_by_param({name: product_name})
    print_to_log 'Get product data by name'
    JSON.parse(product_data)
  end

  def get_products_plan_by_name(plan_name)
    plans = @api.get_all_plans_by_product({:id => @product.keys.first})
    plans = JSON.parse(plans)
    unless plans.empty?
      plans.each_pair do |key, value|
        if value['name'] == plan_name
          print_to_log "Get products plan by name. Plans: #{{key => value}}"
          return {key => value}
        end
      end
    end
    print_to_log "Get products plan by name. Plans not found"
    nil
  end

  def get_plans_run_by_name(run_name)
    runs = @api.get_all_runs_by_plan({:id => @plan.keys.first})
    runs = JSON.parse(runs)
    unless runs.empty?
      runs.each_pair do |key, value|
        if value['name'] == run_name
          print_to_log "Get plans run by name. Run: #{{key => value}}"
          return {key => value}
        end
      end
    end
    print_to_log "Get plans run by name. Runs not found"
    nil
  end

  def get_string_elements_from_array(array, parameter, full_equality = false)
    array.select { |element| full_equality ? element == parameter : element.include?(parameter) }
  end

  def get_runs_result_set_by_name(result_set_name)
    result_sets = @api.get_all_result_sets_by_run({:id => @run.keys.first})
    result_sets = JSON.parse(result_sets)
    unless result_sets.empty?
      result_sets.each_pair do |key, value|
        if value['name'] == result_set_name
          return {key => value}
        end
      end
    end
    nil
  end

  def print_to_log(message)
    return if @debug.nil?
    puts "Palladium Api: #{message}".colorize(:blue)
  end
end