class SandboxTest << TestSuite
  def start
    load 'scripts/sandbox.rb'
    @sb = Sandbox.new
  end

  def test_good
    @sb.__process(
  end

  def stop
  end
end
