defmodule Test.Mizzen.Resource.Vendors.GET do
  use Test.Mizzen.Resource

  test "should respond with a 200" do
    request()
  after conn ->
      conn
      |> assert_status(200)
      |> Test.Mizzen.Resource.assert_json(%{
            "collection" => [%{"href" => "http://www.example.com/vendors/virus_total?domain=&file_hash=&ip="},
                             %{"href" => "http://www.example.com/vendors/malc0de"},
                             %{"href" => "http://www.example.com/vendors/rep_auth"},
                             %{"href" => "http://www.example.com/vendors/sender_base"},
                             %{"href" => "http://www.example.com/vendors/threat_web"}],
            "href" => "http://www.example.com/vendors",
            "meta" => %{
              "is_domain" => nil,
              "is_file_hash" => nil,
              "is_ip" => nil},
            "search" => %{
              "action" => "http://www.example.com/vendors",
              "input" => %{
                "q" => %{
                  "required" => true,
                  "type" => "text",
                  "value" => nil}},
                  "method" => "GET"}})
  end

  test "should respond with an affordance" do
    affordance()
  after conn ->
      conn
      |> Test.Mizzen.Resource.assert_json(%{
            "action" => "http://www.example.com/vendors",
            "href" => "",
            "input" => %{
              "q" => %{
                "required" => true,
                "type" => "text",
                "value" => nil}},
            "method" => "GET"})
  end
end
