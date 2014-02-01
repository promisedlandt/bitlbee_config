class String
  # @see http://wiki.bitlbee.org/DecodingPasswords

  # Get the bitlbee password hash for this string
  #
  # @return [String] The bitlbee password hash for this string
  def to_bitlbee_password_hash
    cmd = Mixlib::ShellOut.new(" bitlbee -x hash '#{ self }'")
    cmd.run_command
    cmd.error!
    cmd.stdout.chomp
  end

  # Check whether this string matches a given bitlbee password hash
  #
  # @return [Boolean]
  def matches_bitlbee_password_hash?(hash)
    cmd = Mixlib::ShellOut.new(" bitlbee -x chkhash '#{ hash }' '#{ self }'")
    cmd.run_command
    cmd.exitstatus == 0
  end

  # Encrypt a bitlbee account password
  # Used to encrypt passwords for individual IM accounts with the password of the bitlbee user
  #
  # @param [String] key Key to encrypt with
  # @return [String] The encrypted version of this string
  def encrypt_bitlbee_password(key)
    cmd = Mixlib::ShellOut.new(" bitlbee -x enc '#{ key }' '#{ self }'")
    cmd.run_command
    cmd.error!
    cmd.stdout.chomp
  end

  # Decrypt a bitlbee account password
  # Used to decrypt passwords for individual IM accounts with the password of the bitlbee user
  #
  # @param [String] key Key to decrypt with
  # @return [String] The cleartext version of this string
  def decrypt_bitlbee_password(key)
    cmd = Mixlib::ShellOut.new(" bitlbee -x dec '#{ key }' '#{ self }'")
    cmd.run_command
    cmd.error!
    cmd.stdout.chomp
  end
end
