module Resource
module Status
  # lib/statuses/get_all_statuses
  # @return [String] with all results data. Use +JSON.parse string+ to convert it to hash
  def get_all_statuses
    send_get_request('statuses/get_all_statuses', {:user_email => @username, :user_token => @token})
  end

  # lib/statuses/get_statuses_by_param
  # @return [String] with status data. Use +JSON.parse string+ to convert it to hash
  def get_statuses_by_param(param)
    raise('Method get_statuses_by_param get hash with one pair keys and values') unless param.keys.size == 1
    param = {param.keys.first.to_s => param.values.first.to_s}
    send_get_request('statuses/get_statuses_by_param', {:user_email => @username, :user_token => @token, :param => param})
  end

  # lib/status/add_new_status
  # @param params [Hash] with status data
  # @return [String] with established data
  # Example:
  # {:status => {:name => "Name",
  #              :color => "#FFFFFF"}
  # => "{"id":14,"name":"name206272718","color":"#FF0000","main_status":false,"created_at":"2015-06-08T11:41:04.217Z","updated_at":"2015-06-08T11:41:04.217Z"}"
  # You can change only Name and #FF0000 (data type - string) and change Result_set_id
  def add_new_status(params)
    params.merge!({:commit => 'Create Status'})
    response = send_post_request('/statuses/add_new_status', params)
    response.body
  end

  # lib/statuses/update_status
  # @param params [Hash] with status data.
  # Example:
  # {:status => {:name => "Name",
  #              :color => "#FF0000"},
  #  :id => 'id'}
  # => "{"id":32,"name":"name_after_edit246765131","color":"#FF000","main_status":false,"created_at":"2015-06-08T12:46:29.219Z","updated_at":"2015-06-08T12:46:29.261Z"}"
  # You can change only Name and #FF0000 (data type - string) for statuses with any id
  def edit_status(params)
    params.merge!({:commit => 'Update Status'})
    response = send_post_request('statuses/update_status', params)
    response.body
  end

  # lib/statuses/delete_status
  # @param params [Hash] with status id.
  # Example:
  # {:id => "1"}
  # ATTENTION!!! Status will be deleted!! Dont use this method inattentively
  def delete_status(params)
    send_post_request('statuses/delete_status', params)
  end
end
end
