defmodule Test.Mizzen.Resource.GET do
  use Test.Mizzen.Resource

  test "should respond with a 200" do
    request()
  after conn ->
    conn
    |> assert_status(200)
    |> Test.Mizzen.Resource.assert_json(%{"href" => "http://www.example.com/", "vendors" => %{"action" => "http://www.example.com/vendors", "input" => %{"site" => %{"required" => true, "type" => "text", "value" => nil}}, "method" => "GET"}})
  end

  test "should respond with an affordance" do
    affordance()
  after conn ->
    conn
    |> Test.Mizzen.Resource.assert_json(%{"href" => _})
  end
end
