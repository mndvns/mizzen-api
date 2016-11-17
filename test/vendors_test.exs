defmodule Test.Mizzen.Vendors do
  use ExUnit.Case, async: true

  test "malc0de" do
    response = Mizzen.Vendors.Malc0de.get("8.8.8.8")
    assert %{"ASN" => _, "ASN Name" => _, "Country" => _, "Date" => _, "File" => _, "IP" => "8.8.8.8", "MD5" => _} = List.first(response)
  end

   test "rep_auth" do
    response = Mizzen.Vendors.RepAuth.get("facebook.com")
    assert %{"bad_recipients" => _,
             "clean" => _,
             "good_recipients" => _,
             "isp" => _,
             "isp_location" => _,
             "malformed_messages" => _,
             "reputation_score" => _,
             "reverse_dns" => _,
             "spam" => _,
             "suspicious" => _,
             "viruses" => _} = response
   end

   test "sender_base" do
     response = Mizzen.Vendors.SenderBase.get("facebook.com")
     assert %{"email_volume last_day" => _,
              "email_volume_last_month" => _,
              "geolocation" => _,
              "hostname" => _,
              "web_category" => _,
              "web_reputation" => _} = response
   end

   test "threat_web" do
     response = Mizzen.Vendors.ThreatWeb.get("facebook.com")
     assert %{assessment: _,
              average_confidence: _,
              first_seen: _,
              highest_confidence: _,
              last_seen: _,
              record_count: _,
              sources: _} = List.first(response)

   end

   test "virus_total" do
     # response = Mizzen.Vendors.VirusTotal.scan("facebook.com", {false, false, true})
     # assert "foo" = response
     # TODO
   end
end
