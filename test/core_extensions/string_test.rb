require "helper"

describe String do
  describe "#to_bitlbee_password_hash" do
    it "shells out to bitlbee" do
      shellout = mocked_shellout
      Mixlib::ShellOut.stubs(:new).returns(shellout)
      shellout.expects(:run_command)

      "test".to_bitlbee_password_hash
    end
  end

  describe "#matches_bitlbee_password_hash?" do
    it "shells out to bitlbee" do
      shellout = mocked_shellout
      Mixlib::ShellOut.stubs(:new).returns(shellout)
      shellout.expects(:run_command)

      "test".matches_bitlbee_password_hash?("123456")
    end
  end

  describe "#encrypt_bitlbee_password" do
    it "shells out to bitlbee" do
      shellout = mocked_shellout
      Mixlib::ShellOut.stubs(:new).returns(shellout)
      shellout.expects(:run_command)

      "test".encrypt_bitlbee_password("key")
    end
  end

  describe "#decrypt_bitlbee_password" do
    it "shells out to bitlbee" do
      shellout = mocked_shellout
      Mixlib::ShellOut.stubs(:new).returns(shellout)
      shellout.expects(:run_command)

      "test".decrypt_bitlbee_password("key")
    end
  end
end
