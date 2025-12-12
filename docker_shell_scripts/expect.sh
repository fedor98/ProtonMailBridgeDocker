#!/usr/bin/expect -f

set timeout 10

spawn hydroxide auth "$env(PROTONMAIL_USER)"

expect_before {
  timeout {
    puts "Timeout waiting for operation"
    exit 1
  }
}

expect {
  "Password:" {
    send "$env(PROTONMAIL_PASS)\n"
  }
}

expect {
  "2FA TOTP code:" {
    send "$env(PROTONMAIL_2FA)\n"
  }
}

expect {
  "Bridge password:" {
    exit 0
  }
}

# Intentionally crash if hydroxide behave unexpectedly
puts "Unexpect output from hydroxide"
exit 1