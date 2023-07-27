module CheckUtils
  def CheckUtils.check_equal(actual, expected, message = "")
    if actual != expected
      raise_error "Check failed! #{message} \n   Actual value: #{actual},\n Expected value: #{expected}"
    end
    puts "Check successful! #{message}"
  end

end