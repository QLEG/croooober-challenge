require 'net/http'
require 'json'
require 'time'

def convert_unixtime_to_time_obj(unixtime)
  Time.at(unixtime / 1000.0)
end

# 初回リクエスト用データのセットとリクエスト送信 - - - - - - - - - -
base_uri = 'http://challenge.z2o.cloud'
uri      = URI.parse(base_uri + '/challenges')
http     = Net::HTTP.new(uri.host, uri.port)
params   = {nickname: 'test101'}
headers  = {'Content-Type' => 'application/json'}
response = http.post(uri.path, params.to_json, headers)

# 2回目以降のリクエストに必要なデータのセット - - - - - - - - - - - -
result_in_hash = JSON.parse(response.body)
X_Challenge_Id = result_in_hash['id']
data           = ''
initheader     = {'X-Challenge-Id' => X_Challenge_Id}
activate_time  = convert_unixtime_to_time_obj(result_in_hash['actives_at'])
diff           = 0.0
i              = 1

# 2回目以降のリクエスト送信処理 - - - - - - - - - - - - - - - - - - -
while result_in_hash['actives_at']
  current_time = Time.now
  sleep_time   = convert_unixtime_to_time_obj(result_in_hash['actives_at']) - current_time

  if sleep_time > 0
    sleep(sleep_time - diff)
  else
    puts '呼出予定時刻を過ぎています'
  end

  response       = http.put(uri.path, data, initheader)
  result_in_hash = JSON.parse(response.body)
  
  if result_in_hash['total_diff']
    diff = result_in_hash['total_diff'] / 1000.0 / i
    puts '- 呼び出し回数：' + i.to_s + '回目'
    i    = i + 1
  end
end

# コマンドラインへの結果出力処理 - - - - - - - - - - - - - - - - - - -
puts '- - - - - - - - - - - - - - - - - - - - - - - - - '
puts '[最終結果]' 
puts '- 成功回数: ' + result_in_hash['result']['attempts'].to_s + '回'
puts '- 結果URL:  ' + base_uri + result_in_hash['result']['url']