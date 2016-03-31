module Resource
module Run
  # api/runs/get_all_runs
  # @return [String] with all runs data. Use +JSON.parse string+ to convert it to hash
  def get_all_runs
    send_get_request('runs/get_all_runs', {:user_email => @username, :user_token => @token})
  end

  # # api/runs/get_runs_by_param
  # # @return [String] with run data. Use +JSON.parse string+ to convert it to hash
  def get_runs_by_param(param)
    raise('Method get_runs_by_param get hash with one pair keys and values') unless param.keys.size == 1
    param = {param.keys.first.to_s => param.values.first.to_s}
    send_get_request('runs/get_runs_by_param', {:user_email => @username, :user_token => @token, :param => param})
  end
  alias_method :get_run_by_param, :get_runs_by_param

  def get_all_result_sets_by_run(param)
    raise('Method get_all_result_sets_by_run get hash with one pair keys and values') unless param.keys.size == 1
    param = {param.keys.first.to_s => param.values.first.to_s}
    send_get_request('runs/get_all_result_sets_by_run', {:user_email => @username, :user_token => @token, :param => param})
  end

  # api/runs/add_new_run
  # @param params [Hash] with run data and product id.
  # @return [String] with established data
  # Example:
  # {:run => {:name => "Run_name",
  #           :version => "Version"}
  # :plan_id = "1"}
  # => "{"id":2102,"name":"Run_name","version":"Version","plan_id":715,"created_at":"2015-06-02T15:10:16.057Z","updated_at":"2015-06-02T15:10:16.063Z"}"
  # You can change only Run_name and Version (data type - string) and change plan_id
  def add_new_run(params)
    params.merge!({:commit => 'Create Run'})
    response = send_post_request('runs/add_new_run', params)
    response.body
  end

  # api/runs/update_run
  # @param params [Hash] with run data.
  # Example:
  # {:plan => {:name => "Run_name",
  #            :version => "Version"}
  # :id => "1"}
  # => "{"id":2260,"name":"name_after_edit192383833","version":"Run_name147672081","plan_id":876,"created_at":"2015-06-03T11:40:51.158Z","updated_at":"2015-06-03T11:40:51.203Z"}"
  # Change  Plan_name and Version (data type - string) for run with any id
  def edit_run(params)
    params.merge!({:commit => 'Update Run'})
    response = send_post_request('runs/update_run', params)
    response.body
  end

  # api/runs/delete_run
  # @param params [Hash] with run id.
  # Example:
  # {:id => "1"}
  # ATTENTION!!! Run, and all its set-results and results will be deleted!! Dont use this method inattentively
  def delete_run(params)
    send_post_request('runs/delete_run', params)
  end
end
end
