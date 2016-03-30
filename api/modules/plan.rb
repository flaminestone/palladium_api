module Resource
module Plan
  # api/plans/get_plans_by_param
  # @return [String] with all plans data. Use +JSON.parse string+ to convert it to hash
  def get_all_plans
    send_get_request('plans/get_plans', {:user_email => @username, :user_token => @token})
  end

  # api/plans/get_plans_by_param
  # @return [String] with plans data. Use +JSON.parse string+ to convert it to hash
  def get_plans_by_param(param)
    raise('Method get_plans_by_param get hash with one pair keys and values') unless param.keys.size == 1
    param = {param.keys.first.to_s => param.values.first.to_s}
    send_get_request('plans/get_plans_by_param', {:user_email => @username, :user_token => @token, :param => param})
  end
  alias_method :get_plan_by_param, :get_plans_by_param

  # api/plans/add_new_plan
  # @param params [Hash] with plan data and product id.
  # Example:
  # {:plan => {:name => "Plan_name",
  #               :version => "Version"}
  # :product_id = "1"}
  # => "{"id":850,"name":"Plan_name247119597","version":"Plan_version247137883","product_id":609,"created_at":"2015-06-03T10:41:02.257Z","updated_at":"2015-06-03T10:41:02.263Z"}"
  # You can change only Plan_name and Version (data type - string) and change product_id
  def add_new_plan(params)
    params.merge!({:commit => 'Create Plan'})
    response = send_post_request('plans/add_new_plan', params)
    response.body
  end

  # api/plan/get_all_runs_by_plan
  # @param param [Hash] with plan id
  # Example:
  # {:id => plan_id}
  # You can change only plan_id (data type - string)
  def get_all_runs_by_plan(param)
    raise('Method get_all_runs_by_plan get hash with one pair keys and values') unless param.keys.size == 1
    param = {param.keys.first.to_s => param.values.first.to_s}
    send_get_request('plans/get_all_runs_by_plan', {:user_email => @username, :user_token => @token, :param => param})
  end

  # api/plans/update_plan
  # @param params [Hash] with product data.
  # Example:
  # {:plan => {:name => "Plan_name",
  #            :version => "Version"}
  # :id => "1"}
  # => "{"id":852,"name":"name_after_edit882457614","version":null,"product_id":610,"created_at":"2015-06-03T10:41:32.824Z","updated_at":"2015-06-03T10:41:32.893Z"}"
  # Change  Plan_name and Version (data type - string) for plan with any id
  def edit_plan(params)
    params.merge!({:commit => 'Update Plan'})
    response = send_post_request('plans/update_plan', params)
    response.body
  end

  # api/plans/delete_plan
  # @param params [Hash] with plan id.
  # Example:
  # {:id => "1"}
  # ATTENTION!!! Plan, and all its runs, set-results and results will be deleted!! Dont use this method inattentively
  def delete_plan(params)
    send_post_request('plans/delete_plan', params)
  end
end
end
