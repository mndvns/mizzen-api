defmodule Test.Utils do
  use ExUnit.Case, async: true


  test "regex should correctly identify an ip" do
    assert Utils.ip? "10.100.3.72"
    refute Utils.ip? "http://facebook.com"
  end

  test "regex should correctly identify a file hash" do
    assert Utils.file_hash? "e18de9577836cc840e980b14c5c8e5c7"
    refute Utils.file_hash? "notAF1L3h4sh"
  end

  test "regex should correctly identify a domain" do
    assert Utils.domain? "www.facebook.com"
    refute Utils.domain? "httpds:/asf.fofo/aaaaa"
  end

  test "should format date from unix to iso8601" do
    assert Utils.format_date(1464096368) == "2016-05-24T13:26:08Z"
    refute Utils.format_date(1464096368) == "2016-XX-24T13:26:08Z"
  end

  test "should format date from ios8601 to unix" do
    assert Utils.parse_date("2016-05-24T13:26:08Z") == 1464096368
    refute Utils.parse_date("2016-05-24T13:26:08Z") == 146409636
  end
end
