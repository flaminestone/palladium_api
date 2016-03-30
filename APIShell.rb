require_relative '../../api/api'
class APIShell

  attr_accessor :add_all_suites, :ignore_parameters, :suites_to_add, :search_plan_by_substring, :in_debug

  def initialize(product_name, plan_name, run_name)
    @api = Api.new('localhost:8080', 'flamine@list.ru', 'hq7MTSB6JPSr31UX6kpN')
    # @in_debug = RspecHelper.debug?
    # if @in_debug
    #   LoggerHelper.print_to_log 'Do not initialize Palladium, because spec run in debug'
    #   return
    # end
    # LoggerHelper.print_to_log 'Begin initializing Palladium...'
    @product = get_product_data_by_name(product_name)
    @product = JSON.parse(@product)

    @plan = get_products_plan_by_name(plan_name)
    if @plan.nil?
      @plan = @api.add_new_plan({:plan => {:name => plan_name,
                                           :version => '0'},
                                 :product_id => @product.keys.first})
      @plan = JSON.parse(@plan)
    end
    @run = get_plans_run_by_name(run_name)
    if @run.nil?
      @run = @api.add_new_run({:run => {:name => run_name,
                                        :version => '0'},
                               :plan_id => @plan.keys.first})
      @run = JSON.parse(@run)
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

  def add_result(example)
    comment = ''
    exception = example.exception
    custom_fields = {}
    # custom_fields.merge!(custom_js_error: WebDriver.web_console_error) unless WebDriver.web_console_error.nil?
    case
      when @ignore_parameters && (ignored_hash = ignore_case?(example.metadata))
        comment += "\nTest ignored by #{ ignored_hash }"
        result = 'Blocked'
      when example.pending
        result, comment = parse_pending_comment(example.execution_result[:pending_message])
        example.set_custom_exception(comment) if result == :failed
      when exception.to_s.include?('got:'), exception.to_s.include?('expected:')
        result = 'Failed'
        comment += "\n" + exception.to_s.gsub('got:', "got:\n").gsub('expected:', "expected:\n")
      when exception.to_s.include?('to return'), exception.to_s.include?('expected')
        result = 'Failed'
        comment += "\n" + exception.to_s.gsub('to return ', "to return:\n").gsub(', got ', "\ngot:\n")
      when exception.to_s.include?('Service Unavailable')
        result = 'Service_unavailable'
        comment += "\n" + exception.to_s
      when exception.nil?
        case
          when @last_case == example.description
            result = 'Passed_2'
          when custom_fields.key?(:custom_js_error)
            result = 'Js_error'
          else
            result = 'Passed'
        end
        comment += "\nOk"
      else
        result = :aborted
        comment += "\n" + exception.to_s
        lines = StringHelper.get_string_elements_from_array(exception.backtrace, 'RubymineProjects')
        lines.each_with_index { |e, i| lines[i] = e.to_s.sub(/.*RubymineProjects\//, '').gsub('`', " '") }
        custom_fields.merge!(custom_autotest_error_line: lines.join("\r\n"))
    end

    status_id = @api.get_statuses_by_param({name:result})
    status_id = JSON.parse(status_id).keys.first
    @result_set = get_runs_result_set_by_name(example.metadata[:description])

    if @result_set.nil?
      @result_set = @api.add_new_result_set({:result_set => {:name => example.metadata[:description],
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
    @api.get_products_by_param({name: product_name})
  end

  def get_products_plan_by_name(plan_name)
    plans = @api.get_all_plans_by_product({:id => @product.keys.first})
    plans = JSON.parse(plans)
    unless plans.empty?
      plans.each_pair do |key, value|
        if value['name'] == plan_name
          return {key => value}
        end
      end
    end
    nil
  end

  def get_plans_run_by_name(run_name)
    runs = @api.get_all_runs_by_plan({:id => @plan.keys.first})
    runs = JSON.parse(runs)
    unless runs.empty?
      runs.each_pair do |key, value|
        if value['name'] == run_name
          return {key => value}
        end
      end
    end
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
end