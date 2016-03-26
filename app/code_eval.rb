def with_captured_stdout
  begin
    old_stdout = $stdout
    $stdout = StringIO.new('','w')
    eval(yield)
    $stdout.string
  ensure
    $stdout = old_stdout
  end
  # $stdout.string
end


def safe_eval(str)
  x = nil
  begin
    x = eval(str)
    y = with_captured_stdout { str }
    z = y.to_s  + "=> "+ x.to_s
    return z
  rescue Exception => error
    x = error.message + "\n" #+ error.backtrace.reduce("") do |str, elem|
      # str += elem + "\n"
      # str
    # end
    return x
  end
end