module Resource
module ResultSet
  # lib/result_sets/get_all_result_sets
  # @return [String] with all result_sets data. Use +JSON.parse string+ to convert it to hash
  def get_all_result_sets
    send_get_request('result_sets/get_all_result_sets', {:user_email => @username, :user_token => @token})
  end

  # lib/result_sets/get_result_set_by_param
  # @return [String] with result_set data. Use +JSON.parse string+ to convert it to hash
  def get_result_set_by_param(param)
    raise('Method result_set get hash with one pair keys and values') unless param.keys.size == 1
    param = {param.keys.first.to_s => param.values.first.to_s}
    send_get_request('result_sets/get_result_sets_by_param', {:user_email => @username, :user_token => @token, :param => param})
  end
  alias_method :get_result_sets_by_param, :get_result_set_by_param

  # lib/result_sets/add_new_result_set
  # @param params [Hash] with result_set data and run id.
  # @return [String] with established data
  # Example:
  # {:result_set => {:name => "ResultSetName",
  #                 :version => "ResultSetVersion",
  #                 :date => "ResultSetDate"},
  # :run_id => 'Run_Id'}
  # => "{"id":6126,"name":"name344658327","date":"date344683020","version":"version344671751","status":null,"run_id":2289,"created_at":"2015-06-03T12:49:18.356Z","updated_at":"2015-06-03T12:49:18.362Z"}"
  # You can change only ResultSetName, ResultSetData and ResultSetVersion (data type - string) and change run_id
  def add_new_result_set(params)
    params.merge!({:commit => 'Create Run'})
    response = send_post_request('result_sets/add_new_result_set', params)
    response.body
  end

  # lib/result_sets/update_result_set
  # @param params [Hash] with result_set data.
  # Example:
  # {:result_set => {:name => "ResultSetName",
  #                 :version => "ResultSetVersion",
  #                 :date => "ResultSetDate"},
  # :id => 'Run_Id'}
  # => "{"id":6179,"name":"name_after_edit278619558","date":"date250119125","version":"version250060107","status":null,"run_id":2330,"created_at":"2015-06-03T14:19:19.261Z","updated_at":"2015-06-03T14:19:19.291Z"}"
  # You can change only ResultSetName, ResultSetData and ResultSetVersion (data type - string) for result_set with any id
  def edit_result_set(params)
    params.merge!({:commit => 'Update Result Set'})
    response = send_post_request('result_sets/update_result_set', params)
    response.body
  end

  # lib/result_sets/delete_result_set
  # @param params [Hash] with result_set id.
  # Example:
  # {:id => "1"}
  # ATTENTION!!! ResultSet and results will be deleted!! Dont use this method inattentively
  def delete_result_set(params)
    send_post_request('result_sets/delete_result_set', params)
  end
end
end
